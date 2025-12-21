import { BadRequestException, Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import { Prisma, ReportFormat } from '../generated/prisma/client';
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
    letterhead?: {
      title?: string | null;
      line1?: string | null;
      line2?: string | null;
      line3?: string | null;
    };
    logoBuffer?: Buffer;
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

      const headerLines = [
        params.letterhead?.title,
        params.letterhead?.line1,
        params.letterhead?.line2,
        params.letterhead?.line3,
      ].filter((x) => !!x && String(x).trim().length) as string[];

      if (headerLines.length || params.logoBuffer?.length) {
        const headerStartY = doc.y;

        if (params.logoBuffer?.length) {
          try {
            doc.image(params.logoBuffer, doc.x, headerStartY, { width: 72 });
          } catch {
            // ignore invalid image buffer
          }
        }

        const textX = params.logoBuffer?.length ? doc.x + 84 : doc.x;
        doc
          .fontSize(14)
          .fillColor('#000000')
          .text(headerLines[0] ?? '', textX, headerStartY, { align: 'left' });

        doc.fontSize(10).fillColor('#222222');
        for (const line of headerLines.slice(1)) {
          doc.text(line, textX);
        }

        doc.moveDown(0.5);
        const ruleY = doc.y;
        doc
          .moveTo(doc.page.margins.left, ruleY)
          .lineTo(doc.page.width - doc.page.margins.right, ruleY)
          .strokeColor('#DDDDDD')
          .lineWidth(1)
          .stroke();
        doc.moveDown();
      }

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

  private async renderXlsxBuffer(params: {
    title: string;
    lines: string[];
    letterhead?: {
      title?: string | null;
      line1?: string | null;
      line2?: string | null;
      line3?: string | null;
    };
  }): Promise<Buffer> {
    // eslint-disable-next-line @typescript-eslint/no-var-requires
    const ExcelJS = require('exceljs');

    const workbook = new ExcelJS.Workbook();
    workbook.creator = 'Palakat';
    workbook.created = new Date();

    const sheet = workbook.addWorksheet('Report');

    const headerLines = [
      params.letterhead?.title,
      params.letterhead?.line1,
      params.letterhead?.line2,
      params.letterhead?.line3,
    ].filter((x) => !!x && String(x).trim().length) as string[];

    for (const line of headerLines) {
      sheet.addRow([line]);
    }

    if (headerLines.length) {
      sheet.addRow([]);
    }

    sheet.addRow([params.title]);
    sheet.addRow([`Generated at: ${new Date().toISOString()}`]);
    sheet.addRow([]);

    for (const line of params.lines) {
      sheet.addRow([line]);
    }

    const buffer = (await workbook.xlsx.writeBuffer()) as ArrayBuffer;
    return Buffer.from(buffer);
  }

  private async tryDownloadLogoBuffer(
    logoFile?: {
      bucket?: string;
      path?: string;
    } | null,
  ): Promise<Buffer | undefined> {
    if (!logoFile?.bucket || !logoFile?.path) return;

    try {
      const bucket = this.firebaseAdmin.bucket(logoFile.bucket);
      const object = bucket.file(logoFile.path);
      if (typeof object.download !== 'function') return;
      const [buf] = await object.download();
      return buf as Buffer;
    } catch {
      return;
    }
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

    const type = dto.type;
    const format = dto.format ?? ReportFormat.PDF;
    const startDate = dto.startDate;
    const endDate = dto.endDate;

    const letterhead = await this.prisma.churchLetterhead.findUnique({
      where: { churchId },
      include: { logoFile: true },
    });

    const logoBuffer = await this.tryDownloadLogoBuffer(
      (letterhead as any)?.logoFile,
    );

    const title = `Report ${type}`;

    const lines: string[] = [
      `Church ID: ${churchId}`,
      startDate ? `Start: ${new Date(startDate).toISOString()}` : 'Start: -',
      endDate ? `End: ${new Date(endDate).toISOString()}` : 'End: -',
      '',
      'This report is a generated artifact.',
    ];

    const buffer =
      format === ReportFormat.XLSX
        ? await this.renderXlsxBuffer({
            title,
            lines,
            letterhead: letterhead as any,
          })
        : await this.renderPdfBuffer({
            title,
            lines,
            letterhead: letterhead as any,
            logoBuffer,
          });

    const sizeInKB = Number((buffer.length / 1024).toFixed(2));

    const bucket = this.firebaseAdmin.bucket();
    const bucketName = bucket.name as string;

    const now = new Date();
    const stamp = now.toISOString().replace(/[-:]/g, '').replace(/\..+$/, '');
    const ext = format === ReportFormat.XLSX ? 'xlsx' : 'pdf';
    const objectName = `SYSTEM_${type}_${stamp}_${randomUUID().slice(0, 8)}.${ext}`;
    const path = `churches/${churchId}/reports/${objectName}`;

    const contentType =
      format === ReportFormat.XLSX
        ? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        : 'application/pdf';

    await bucket.file(path).save(buffer, {
      contentType,
      metadata: {
        metadata: {
          churchId: String(churchId),
          reportType: String(type),
          reportFormat: String(format),
        },
      },
    });

    const file = await (this.prisma as any).fileManager.create({
      data: {
        provider: 'FIREBASE_STORAGE',
        bucket: bucketName,
        path,
        sizeInKB,
        contentType,
        originalName: objectName,
        churchId,
      },
    });

    const report = await this.prisma.report.create({
      data: {
        name: title,
        type: type as any,
        format: format as any,
        params: {
          startDate: startDate?.toISOString(),
          endDate: endDate?.toISOString(),
        } as any,
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
