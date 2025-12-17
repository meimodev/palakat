import { BadRequestException, Injectable } from '@nestjs/common';
import { Prisma } from '../generated/prisma/client';
import PDFDocument from 'pdfkit';
import { PassThrough } from 'stream';
import { PrismaService } from '../prisma.service';
import { ReportListQueryDto } from './dto/report-list.dto';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import { ReportGenerateDto } from './dto/report-generate.dto';

@Injectable()
export class ReportService {
  constructor(
    private prisma: PrismaService,
    private firebaseAdmin: FirebaseAdminService,
  ) {}

  private async resolveRequesterChurchId(user?: any): Promise<number> {
    const userId = user?.userId;
    if (!userId) {
      throw new BadRequestException('Invalid user');
    }

    const membership = await (this.prisma as any).membership.findUnique({
      where: { accountId: userId },
      select: { churchId: true },
    });

    if (!membership?.churchId) {
      throw new BadRequestException(
        'Account does not have an active membership',
      );
    }

    return membership.churchId;
  }

  private async renderPdfBuffer(params: {
    title: string;
    lines: string[];
  }): Promise<Buffer> {
    const doc = new PDFDocument({
      size: 'A4',
      margin: 48,
      info: {
        Title: params.title,
      },
    });

    const stream = new PassThrough();
    const chunks: Buffer[] = [];

    return await new Promise<Buffer>((resolve, reject) => {
      stream.on('data', (chunk) => chunks.push(Buffer.from(chunk)));
      stream.on('end', () => resolve(Buffer.concat(chunks)));
      stream.on('error', reject);

      doc.pipe(stream);

      doc.fontSize(18).text(params.title, { align: 'left' });
      doc.moveDown(0.5);
      doc
        .fontSize(10)
        .fillColor('#444444')
        .text(`Generated at: ${new Date().toISOString()}`);
      doc.moveDown();

      doc.fillColor('#000000').fontSize(12);
      for (const line of params.lines) {
        doc.text(line);
      }

      doc.end();
    });
  }

  async getReports(query: ReportListQueryDto) {
    const {
      search,
      churchId,
      generatedBy,
      skip,
      take,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = query;

    const where: Prisma.ReportWhereInput = {};

    if (search && search.length >= 3) {
      const keyword = search.toLowerCase();
      where.OR = [{ name: { contains: keyword, mode: 'insensitive' } }];
    }

    if (churchId) {
      where.churchId = churchId;
    }

    if (generatedBy) {
      where.generatedBy = generatedBy;
    }

    const [total, reports] = await this.prisma.$transaction([
      this.prisma.report.count({ where }),
      this.prisma.report.findMany({
        where,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },
        include: {
          church: true,
          file: true,
        },
      }),
    ]);

    return {
      message: 'Reports fetched successfully',
      data: reports,
      total,
    };
  }

  async findOne(id: number) {
    const report = await this.prisma.report.findUniqueOrThrow({
      where: { id },
      include: {
        church: true,
        file: true,
      },
    });
    return {
      message: 'Report fetched successfully',
      data: report,
    };
  }

  async remove(id: number) {
    await this.prisma.report.delete({
      where: { id },
    });
    return {
      message: 'Report deleted successfully',
    };
  }

  async create(createReportDto: Prisma.ReportCreateInput) {
    const report = await this.prisma.report.create({
      data: createReportDto,
    });
    return {
      message: 'Report created successfully',
      data: report,
    };
  }

  async update(id: number, updateReportDto: Prisma.ReportUpdateInput) {
    const report = await this.prisma.report.update({
      where: { id },
      data: updateReportDto,
      include: {
        church: true,
        file: true,
      },
    });
    return {
      message: 'Report updated successfully',
      data: report,
    };
  }

  async generate(dto: ReportGenerateDto, user?: any) {
    const churchId = await this.resolveRequesterChurchId(user);

    const type = (dto as any).type as string;
    const startDate = (dto as any).startDate as Date | undefined;
    const endDate = (dto as any).endDate as Date | undefined;

    const title = `Report ${type}`;

    const lines: string[] = [
      `Church ID: ${churchId}`,
      startDate ? `Start: ${new Date(startDate).toISOString()}` : 'Start: -',
      endDate ? `End: ${new Date(endDate).toISOString()}` : 'End: -',
      '',
      'This report is a generated artifact.',
    ];

    const pdfBuffer = await this.renderPdfBuffer({ title, lines });
    const sizeInKB = Number((pdfBuffer.length / 1024).toFixed(2));

    const bucketName = process.env.FIREBASE_STORAGE_BUCKET;
    if (!bucketName) {
      throw new BadRequestException(
        'FIREBASE_STORAGE_BUCKET is not configured',
      );
    }

    const now = new Date();
    const stamp = now.toISOString().replace(/[-:]/g, '').replace(/\..+$/, '');
    const objectName = `SYSTEM_${type}_${stamp}.pdf`;
    const path = `churches/${churchId}/reports/${objectName}`;

    const bucket = this.firebaseAdmin.bucket(bucketName);
    await bucket.file(path).save(pdfBuffer, {
      contentType: 'application/pdf',
      metadata: {
        metadata: {
          churchId: String(churchId),
          reportType: String(type),
        },
      },
    });

    const file = await (this.prisma as any).fileManager.create({
      data: {
        provider: 'FIREBASE_STORAGE',
        bucket: bucketName,
        path,
        sizeInKB,
        contentType: 'application/pdf',
        originalName: objectName,
        churchId,
      },
    });

    const report = await this.prisma.report.create({
      data: {
        name: title,
        generatedBy: 'SYSTEM' as any,
        churchId,
        fileId: file.id,
      },
      include: {
        church: true,
        file: true,
      },
    } as any);

    return {
      message: 'Report generated',
      data: report,
    };
  }
}
