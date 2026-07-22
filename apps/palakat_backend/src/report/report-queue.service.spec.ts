/**
 * Unit tests for ReportQueueService job claiming and stale-job recovery.
 *
 * Covers the two defects that make the queue unsafe once more than one
 * process can run it, and once a process can die mid-render.
 */

import { Test, TestingModule } from '@nestjs/testing';
import { ReportQueueService } from './report-queue.service';
import { ReportService } from './report.service';
import { PrismaService } from '../prisma.service';
import { PusherBeamsService } from '../notification/pusher-beams.service';
import { RealtimeEmitterService } from '../realtime/realtime-emitter.service';
import { ReportJobStatus } from '../generated/prisma/client';

describe('ReportQueueService', () => {
  let service: ReportQueueService;

  const pendingJob = {
    id: 1,
    status: ReportJobStatus.PROCESSING,
    churchId: 10,
    requestedById: 5,
    params: { type: 'ACTIVITY' },
    progress: 10,
  };

  const mockPrisma: any = {
    reportJob: {
      update: jest.fn().mockResolvedValue({}),
      updateMany: jest.fn().mockResolvedValue({ count: 0 }),
    },
    $queryRaw: jest.fn(),
  };

  const mockReportService: any = {
    generateInternal: jest.fn().mockResolvedValue({ data: { id: 99 } }),
  };

  const mockPusherBeams: any = {
    formatAccountInterest: jest.fn(() => 'account.5'),
    publishToInterests: jest.fn().mockResolvedValue(undefined),
  };

  const mockRealtime: any = { emitToRoom: jest.fn() };

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ReportQueueService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: ReportService, useValue: mockReportService },
        { provide: PusherBeamsService, useValue: mockPusherBeams },
        { provide: RealtimeEmitterService, useValue: mockRealtime },
      ],
    }).compile();

    service = module.get<ReportQueueService>(ReportQueueService);
  });

  describe('claiming', () => {
    it('claims via a single atomic statement, not read-then-write', async () => {
      mockPrisma.$queryRaw.mockResolvedValueOnce([pendingJob]);

      await service.processNextJob();

      expect(mockPrisma.$queryRaw).toHaveBeenCalledTimes(1);
      const sql = mockPrisma.$queryRaw.mock.calls[0][0].join('?');
      expect(sql).toContain('FOR UPDATE SKIP LOCKED');
      expect(sql).toContain('UPDATE "ReportJob"');
    });

    it('does nothing when no job is claimable', async () => {
      mockPrisma.$queryRaw.mockResolvedValueOnce([]);

      await service.processNextJob();

      expect(mockReportService.generateInternal).not.toHaveBeenCalled();
    });

    it('renders once when two callers race for one pending job', async () => {
      // Whichever statement wins claims the row; the loser gets zero rows back.
      mockPrisma.$queryRaw
        .mockResolvedValueOnce([pendingJob])
        .mockResolvedValueOnce([]);

      await Promise.all([service.processNextJob(), service.processNextJob()]);

      expect(mockReportService.generateInternal).toHaveBeenCalledTimes(1);
    });
  });

  describe('stale-job reaper', () => {
    it('fails jobs abandoned in PROCESSING past the cutoff', async () => {
      mockPrisma.reportJob.updateMany.mockResolvedValueOnce({ count: 2 });

      const reaped = await service.reapStaleJobs();

      expect(reaped).toBe(2);
      const arg = mockPrisma.reportJob.updateMany.mock.calls[0][0];
      expect(arg.where.status).toBe(ReportJobStatus.PROCESSING);
      expect(arg.where.updatedAt.lt).toBeInstanceOf(Date);
      expect(arg.data.status).toBe(ReportJobStatus.FAILED);
    });

    it('leaves recently updated PROCESSING jobs alone', async () => {
      await service.reapStaleJobs();

      const cutoff = mockPrisma.reportJob.updateMany.mock.calls[0][0].where
        .updatedAt.lt as Date;
      expect(cutoff.getTime()).toBeLessThan(Date.now());
      expect(Date.now() - cutoff.getTime()).toBeGreaterThan(60_000);
    });

    it('runs on boot, because boot is when jobs get stranded', async () => {
      await service.onModuleInit();

      expect(mockPrisma.reportJob.updateMany).toHaveBeenCalled();
    });

    it('never throws — a failing reaper must not stop the queue', async () => {
      mockPrisma.reportJob.updateMany.mockRejectedValueOnce(new Error('down'));

      await expect(service.reapStaleJobs()).resolves.toBe(0);
    });
  });
});
