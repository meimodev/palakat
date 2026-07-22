import {
  Injectable,
  Logger,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
  Inject,
  forwardRef,
  OnModuleInit,
} from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../prisma.service';
import { ReportService } from './report.service';
import { PusherBeamsService } from '../notification/pusher-beams.service';
import { RealtimeEmitterService } from '../realtime/realtime-emitter.service';
import {
  Prisma,
  DocumentInput,
  ReportJobStatus,
  NotificationType,
  ReportGenerateType,
  ReportFormat,
} from '../generated/prisma/client';
import { ReportGenerateDto } from './dto/report-generate.dto';
import { ReportJobListQueryDto } from './dto/report-job-list.dto';

/** A job left in PROCESSING for longer than this is assumed abandoned. */
const STALE_JOB_MS = 15 * 60 * 1000;

@Injectable()
export class ReportQueueService implements OnModuleInit {
  private readonly logger = new Logger(ReportQueueService.name);
  private isProcessing = false;
  private lastAttemptedAt?: string;
  private lastCompletedAt?: string;
  private lastFailedAt?: string;
  private lastErrorMessage?: string;

  constructor(
    private prisma: PrismaService,
    private reportService: ReportService,
    private pusherBeams: PusherBeamsService,
    @Inject(forwardRef(() => RealtimeEmitterService))
    private realtime: RealtimeEmitterService,
  ) {}

  async getHealthSnapshot() {
    const [pending, processing, failed, oldestPending] =
      await this.prisma.$transaction([
        this.prisma.reportJob.count({
          where: { status: ReportJobStatus.PENDING },
        }),
        this.prisma.reportJob.count({
          where: { status: ReportJobStatus.PROCESSING },
        }),
        this.prisma.reportJob.count({
          where: { status: ReportJobStatus.FAILED },
        }),
        this.prisma.reportJob.findFirst({
          where: { status: ReportJobStatus.PENDING },
          orderBy: { createdAt: 'asc' },
          select: { createdAt: true },
        }),
      ]);

    return {
      pending,
      processing,
      failed,
      isProcessing: this.isProcessing,
      lastAttemptedAt: this.lastAttemptedAt,
      lastCompletedAt: this.lastCompletedAt,
      lastFailedAt: this.lastFailedAt,
      lastErrorMessage: this.lastErrorMessage,
      oldestPendingAt: oldestPending?.createdAt?.toISOString(),
    };
  }

  private async resolveRequesterChurchId(user?: any): Promise<number> {
    const userId = user?.userId;
    if (!userId) {
      throw new BadRequestException('Invalid user');
    }

    const membership = await this.prisma.membership.findUnique({
      where: { accountId: userId },
      select: {
        churchId: true,
        column: {
          select: {
            churchId: true,
          },
        },
      },
    });

    const churchId = membership?.churchId ?? membership?.column?.churchId;
    if (!churchId) {
      throw new BadRequestException(
        'Account does not have an active membership',
      );
    }

    return churchId;
  }

  async createJob(dto: ReportGenerateDto, user: any) {
    const churchId = await this.resolveRequesterChurchId(user);
    const userId = user?.userId;

    if (!userId) {
      throw new BadRequestException('Invalid user');
    }

    await this.reportService.assertHasMatchingData(dto, churchId);

    const job = await this.prisma.reportJob.create({
      data: {
        type: dto.type,
        format: dto.format ?? ReportFormat.PDF,
        params: dto as any,
        status: ReportJobStatus.PENDING,
        progress: 0,
        churchId,
        requestedById: userId,
      },
      include: {
        church: true,
        requestedBy: {
          select: {
            id: true,
            name: true,
            phone: true,
          },
        },
      },
    });

    this.logger.log(`Report job ${job.id} created for user ${userId}`);

    try {
      this.realtime.emitToRoom(`account.${userId}`, 'reportJob.created', {
        data: job,
      });
    } catch {}

    return {
      message: 'Report generation queued',
      data: job,
    };
  }

  async getMyJobs(query: ReportJobListQueryDto, user: any) {
    const userId = user?.userId;
    if (!userId) {
      throw new BadRequestException('Invalid user');
    }

    const {
      status,
      skip,
      take,
      page = 1,
      pageSize = 10,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = query;

    const where: Prisma.ReportJobWhereInput = {
      requestedById: userId,
      ...(status ? { status } : {}),
    };

    const [total, jobs] = await this.prisma.$transaction([
      this.prisma.reportJob.count({ where }),
      this.prisma.reportJob.findMany({
        where,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },
        include: {
          church: true,
          report: {
            include: {
              file: true,
            },
          },
        },
      }),
    ]);

    const totalPages = Math.ceil(total / pageSize);
    const currentPage = page;

    return {
      message: 'Report jobs fetched successfully',
      data: jobs,
      pagination: {
        page: currentPage,
        pageSize,
        total,
        totalPages,
        hasNext: currentPage < totalPages,
        hasPrev: currentPage > 1,
      },
    };
  }

  async getJobStatus(jobId: number, user: any) {
    const userId = user?.userId;
    if (!userId) {
      throw new BadRequestException('Invalid user');
    }

    const job = await this.prisma.reportJob.findUnique({
      where: { id: jobId },
      include: {
        church: true,
        report: {
          include: {
            file: true,
          },
        },
      },
    });

    if (!job) {
      throw new NotFoundException(`Report job ${jobId} not found`);
    }

    if (job.requestedById !== userId) {
      throw new ForbiddenException('You are not authorized to view this job');
    }

    return {
      message: 'Report job fetched successfully',
      data: job,
    };
  }

  async cancelJob(jobId: number, user: any) {
    const userId = user?.userId;
    if (!userId) {
      throw new BadRequestException('Invalid user');
    }

    const job = await this.prisma.reportJob.findUnique({
      where: { id: jobId },
    });

    if (!job) {
      throw new NotFoundException(`Report job ${jobId} not found`);
    }

    if (job.requestedById !== userId) {
      throw new ForbiddenException('You are not authorized to cancel this job');
    }

    if (job.status !== ReportJobStatus.PENDING) {
      throw new BadRequestException('Only pending jobs can be cancelled');
    }

    await this.prisma.reportJob.delete({
      where: { id: jobId },
    });

    return {
      message: 'Report job cancelled successfully',
    };
  }

  /**
   * A restart mid-render leaves a job in PROCESSING with nothing to recover it.
   * Boot is exactly when that happened, so sweep before serving anything.
   */
  async onModuleInit(): Promise<void> {
    await this.reapStaleJobs();
  }

  /**
   * Fail jobs abandoned in PROCESSING — the process that claimed them is gone.
   *
   * ponytail: fails rather than requeues. Requeue-once needs an `attempts`
   * column, and without one a job that reliably crashes the process would loop
   * forever. A visible FAILED beats an invisible spinner; the user re-requests.
   */
  @Cron(CronExpression.EVERY_30_MINUTES)
  async reapStaleJobs(): Promise<number> {
    const cutoff = new Date(Date.now() - STALE_JOB_MS);
    try {
      const { count } = await this.prisma.reportJob.updateMany({
        where: {
          status: ReportJobStatus.PROCESSING,
          updatedAt: { lt: cutoff },
        },
        data: {
          status: ReportJobStatus.FAILED,
          errorMessage: 'Abandoned while processing — the worker did not finish',
        },
      });

      if (count > 0) {
        this.logger.warn(`Reaped ${count} stale report job(s)`);
      }
      return count;
    } catch (e: any) {
      this.logger.error(`Stale-job reaper failed: ${e?.message ?? e}`, e?.stack);
      return 0;
    }
  }

  /**
   * Claim one PENDING job atomically, so two instances cannot render the same
   * report twice. SKIP LOCKED makes concurrent claimers take different rows
   * rather than queue behind each other.
   */
  private async claimNextJob(): Promise<any | undefined> {
    const rows = await this.prisma.$queryRaw<any[]>`
      UPDATE "ReportJob"
      SET status = 'PROCESSING'::"ReportJobStatus",
          progress = 10,
          "updatedAt" = NOW()
      WHERE id = (
        SELECT id FROM "ReportJob"
        WHERE status = 'PENDING'::"ReportJobStatus"
        ORDER BY "createdAt" ASC
        LIMIT 1
        FOR UPDATE SKIP LOCKED
      )
      RETURNING *
    `;
    return rows?.[0];
  }

  @Cron(CronExpression.EVERY_10_SECONDS)
  async processQueue() {
    if (this.isProcessing) {
      return;
    }

    this.isProcessing = true;
    try {
      await this.processNextJob();
    } finally {
      this.isProcessing = false;
    }
  }

  async processNextJob(): Promise<void> {
    const job = await this.claimNextJob();

    if (!job) {
      return;
    }

    this.logger.log(`Processing report job ${job.id}`);
    this.lastAttemptedAt = new Date().toISOString();
    this.lastErrorMessage = undefined;

    try {
      this.realtime.emitToRoom(
        `account.${job.requestedById}`,
        'reportJob.updated',
        {
          data: {
            id: job.id,
            status: ReportJobStatus.PROCESSING,
            progress: 10,
          },
        },
      );
    } catch {}

    try {
      // Validate and convert params to ReportGenerateDto
      if (
        !job.params ||
        typeof job.params !== 'object' ||
        Array.isArray(job.params)
      ) {
        throw new Error('Invalid job params: expected object');
      }

      const params = job.params as unknown as ReportGenerateDto;

      // Ensure required fields are present
      if (!params.type) {
        throw new Error('Missing required field: type');
      }

      // Convert date strings back to Date objects (JSON serialization loses Date type)
      if (params.startDate && typeof params.startDate === 'string') {
        params.startDate = new Date(params.startDate);
      }
      if (params.endDate && typeof params.endDate === 'string') {
        params.endDate = new Date(params.endDate);
      }

      const result = await this.reportService.generateInternal(
        params,
        job.requestedById,
        job.churchId,
      );

      const report = result.data;

      await this.prisma.reportJob.update({
        where: { id: job.id },
        data: {
          status: ReportJobStatus.COMPLETED,
          progress: 100,
          reportId: report.id,
          completedAt: new Date(),
        },
      });

      try {
        this.realtime.emitToRoom(
          `account.${job.requestedById}`,
          'reportJob.updated',
          {
            data: {
              id: job.id,
              status: ReportJobStatus.COMPLETED,
              progress: 100,
              reportId: report.id,
              completedAt: new Date(),
            },
          },
        );
        this.realtime.emitToRoom(
          `account.${job.requestedById}`,
          'report.ready',
          {
            data: report,
            jobId: job.id,
          },
        );
      } catch {}

      this.logger.log(
        `Report job ${job.id} completed, report ${report.id} created`,
      );
      this.lastCompletedAt = new Date().toISOString();

      await this.notifyReportReady(job, report);
    } catch (error) {
      this.logger.error(
        `Report job ${job.id} failed: ${error.message}`,
        error.stack,
      );

      await this.prisma.reportJob.update({
        where: { id: job.id },
        data: {
          status: ReportJobStatus.FAILED,
          errorMessage: error.message || 'Unknown error',
        },
      });
      this.lastFailedAt = new Date().toISOString();
      this.lastErrorMessage = error.message || 'Unknown error';

      try {
        this.realtime.emitToRoom(
          `account.${job.requestedById}`,
          'reportJob.updated',
          {
            data: {
              id: job.id,
              status: ReportJobStatus.FAILED,
              errorMessage: error.message || 'Unknown error',
            },
          },
        );
      } catch {}

      await this.notifyReportFailed(job, error.message || 'Unknown error');
    }
  }

  private formatReportType(
    type: ReportGenerateType,
    params?: Record<string, unknown> | null,
  ): string {
    switch (type) {
      case ReportGenerateType.DOCUMENT:
        return String(params?.input).toUpperCase() === DocumentInput.OUTCOME
          ? 'Outgoing Document'
          : 'Incoming Document';
      case ReportGenerateType.CONGREGATION:
        return 'Congregation';
      case ReportGenerateType.SERVICES:
        return 'Services';
      case ReportGenerateType.ACTIVITY:
        return 'Activity';
      case ReportGenerateType.FINANCIAL:
        return 'Financial';
      default:
        return String(type);
    }
  }

  private async notifyReportReady(job: any, report: any): Promise<void> {
    try {
      const interest = this.pusherBeams.formatAccountInterest(
        job.requestedById,
      );
      const reportTypeName = this.formatReportType(
        job.type,
        (report?.params as Record<string, unknown> | null | undefined) ??
          (job?.params as Record<string, unknown> | null | undefined) ??
          null,
      );

      await this.prisma.notification.create({
        data: {
          title: 'Report Ready',
          body: `Your ${reportTypeName} report is ready for download`,
          type: NotificationType.REPORT_READY,
          recipient: interest,
          isRead: false,
        },
      });

      await this.pusherBeams.publishToInterests([interest], {
        title: 'Report Ready',
        body: `Your ${reportTypeName} report is ready`,
        deepLink: `/reports/${report.id}`,
        data: {
          type: 'REPORT_READY',
          reportId: report.id,
          reportJobId: job.id,
          reportName: report.name,
        },
      });

      this.logger.log(`Notification sent for completed job ${job.id}`);
    } catch (error) {
      this.logger.error(
        `Failed to send notification for job ${job.id}: ${error.message}`,
        error.stack,
      );
    }
  }

  private async notifyReportFailed(
    job: any,
    errorMessage: string,
  ): Promise<void> {
    try {
      const interest = this.pusherBeams.formatAccountInterest(
        job.requestedById,
      );
      const reportTypeName = this.formatReportType(
        job.type,
        (job?.params as Record<string, unknown> | null | undefined) ?? null,
      );

      await this.prisma.notification.create({
        data: {
          title: 'Report Failed',
          body: `Your ${reportTypeName} report could not be generated`,
          type: NotificationType.REPORT_FAILED,
          recipient: interest,
          isRead: false,
        },
      });

      await this.pusherBeams.publishToInterests([interest], {
        title: 'Report Failed',
        body: `Your ${reportTypeName} report could not be generated`,
        deepLink: `/report-jobs`,
        data: {
          type: 'REPORT_FAILED',
          reportJobId: job.id,
          error: errorMessage,
        },
      });

      this.logger.log(`Failure notification sent for job ${job.id}`);
    } catch (error) {
      this.logger.error(
        `Failed to send failure notification for job ${job.id}: ${error.message}`,
        error.stack,
      );
    }
  }
}
