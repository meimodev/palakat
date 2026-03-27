import { BadRequestException, Injectable } from '@nestjs/common';
import { createHash, randomBytes, randomUUID } from 'crypto';
import {
  ActivityType,
  DocumentInput,
  GeneratedBy,
  ApprovalStatus,
  Prisma,
  ReportFormat,
  ReportGenerateType,
} from '../generated/prisma/client';
import PDFDocument from 'pdfkit';
import * as ExcelJS from 'exceljs';
import { PassThrough } from 'stream';
import { PrismaService } from '../prisma.service';
import { ReportListQueryDto } from './dto/report-list.dto';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import * as QRCode from 'qrcode';
import {
  renderPdfBulletinReportBuffer,
  renderPdfTableReportBuffer,
  renderXlsxBulletinReportBuffer,
  renderXlsxTableReportBuffer,
  type BulletinSection,
  type TableSection,
} from './report-renderer';
import {
  CongregationReportSubtype,
  FinancialReportSubtype,
  ReportGenerateDto,
} from './dto/report-generate.dto';
import { buildGmimLetterhead, getGmimLogoBuffer } from 'src/utils';

@Injectable()
export class ReportService {
  constructor(
    private prisma: PrismaService,
    private firebaseAdmin: FirebaseAdminService,
  ) {}

  private formatIndonesianDate(date?: Date | null): string {
    if (!date) return '';

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    const day = String(date.getUTCDate()).padStart(2, '0');
    const monthName = months[date.getUTCMonth()] ?? '';
    const year = String(date.getUTCFullYear());

    return `${day} ${monthName} ${year}`.trim();
  }

  private sha256Hex(input: string | Buffer): string {
    return createHash('sha256').update(input).digest('hex');
  }

  private formatGeneratedAtForVerifyBlock(date: Date): string {
    const weekdays = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    const weekday = weekdays[date.getDay()] ?? '';
    const day = date.getDate();
    const month = months[date.getMonth()] ?? '';
    const year = date.getFullYear();

    const minutes = String(date.getMinutes()).padStart(2, '0');
    const isPm = date.getHours() >= 12;
    let hours = date.getHours() % 12;
    if (hours === 0) hours = 12;

    return `${weekday}, ${day} ${month} ${year} ${hours}:${minutes} ${
      isPm ? 'PM' : 'AM'
    }`;
  }

  private buildDocumentActivityWhere(
    churchId: number,
    startDate?: Date,
    endDate?: Date,
    input?: DocumentInput,
  ): Prisma.ActivityWhereInput {
    return {
      supervisor: {
        churchId,
      },
      activityType: ActivityType.ANNOUNCEMENT,
      document: input
        ? {
            input,
          }
        : {
            isNot: null,
          },
      approvers: {
        some: {},
        every: {
          status: ApprovalStatus.APPROVED,
        },
      },
      ...(startDate && endDate
        ? {
            date: {
              not: null,
              gte: startDate,
              lte: endDate,
            },
          }
        : {}),
    };
  }

  private resolvePublicBaseUrl(): string {
    const base = process.env.PUBLIC_BASE_URL;
    if (base && base.trim().length) return base.trim().replace(/\/$/, '');

    const port = process.env.PORT || '3000';
    return `http://localhost:${port}`;
  }

  private async resolveRequesterChurchId(user?: any): Promise<number> {
    const userId = user?.userId;
    if (!userId) {
      throw new BadRequestException('Invalid user');
    }

    const membership = await this.prisma.membership.findUnique({
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

  private normalizeReportDate(value?: Date | string): Date | undefined {
    if (value == null) return undefined;

    if (value instanceof Date) {
      if (Number.isNaN(value.getTime())) {
        throw new BadRequestException('Invalid report date range');
      }

      return value;
    }

    const parsed = new Date(value);
    if (Number.isNaN(parsed.getTime())) {
      throw new BadRequestException('Invalid report date range');
    }

    return parsed;
  }

  private buildNoMatchingDataMessage(
    type: ReportGenerateType,
    input?: DocumentInput,
  ): string {
    switch (type) {
      case ReportGenerateType.DOCUMENT:
        return input === DocumentInput.OUTCOME
          ? 'No outgoing document activity data matched the selected report configuration'
          : 'No incoming document activity data matched the selected report configuration';
      case ReportGenerateType.CONGREGATION:
        return 'No congregation data matched the selected report configuration';
      case ReportGenerateType.ACTIVITY:
        return 'No activity data matched the selected report configuration';
      case ReportGenerateType.FINANCIAL:
        return 'No financial data matched the selected report configuration';
      case ReportGenerateType.SERVICES:
        return 'No service data matched the selected report configuration';
    }
  }

  async assertHasMatchingData(
    dto: ReportGenerateDto,
    churchId: number,
  ): Promise<void> {
    if (!dto?.type) {
      throw new BadRequestException('type is required');
    }

    const type = dto.type;
    const startDate = this.normalizeReportDate(dto.startDate as Date | string);
    const endDate = this.normalizeReportDate(dto.endDate as Date | string);

    if ((startDate == null) != (endDate == null)) {
      throw new BadRequestException('Invalid report date range');
    }

    if (startDate && endDate && startDate > endDate) {
      throw new BadRequestException('Invalid report date range');
    }

    const congregationSubtype =
      type === ReportGenerateType.CONGREGATION
        ? (dto.congregationSubtype ?? CongregationReportSubtype.WARTA_JEMAAT)
        : dto.congregationSubtype;

    const columnId =
      type === ReportGenerateType.CONGREGATION ||
      type === ReportGenerateType.ACTIVITY
        ? dto.columnId
        : undefined;

    const input =
      type === ReportGenerateType.DOCUMENT
        ? (dto.input ?? DocumentInput.INCOME)
        : dto.input;

    const activityType =
      type === ReportGenerateType.ACTIVITY ? dto.activityType : undefined;

    const financialSubtype =
      type === ReportGenerateType.FINANCIAL
        ? (dto.financialSubtype ?? FinancialReportSubtype.REVENUE)
        : dto.financialSubtype;

    let matchingCount = 0;

    switch (type) {
      case ReportGenerateType.DOCUMENT:
        matchingCount = await this.prisma.activity.count({
          where: {
            ...this.buildDocumentActivityWhere(
              churchId,
              startDate,
              endDate,
              input,
            ),
          },
        });
        break;
      case ReportGenerateType.CONGREGATION: {
        const membershipBaseWhere: Prisma.MembershipWhereInput = {
          churchId,
          ...(columnId != null ? { columnId } : {}),
          ...(startDate && endDate
            ? {
                createdAt: {
                  gte: startDate,
                  lte: endDate,
                },
              }
            : {}),
        };

        if (congregationSubtype === CongregationReportSubtype.WARTA_JEMAAT) {
          matchingCount = await this.prisma.membership.count({
            where: membershipBaseWhere,
          });
          break;
        }

        if (congregationSubtype === CongregationReportSubtype.HUT_JEMAAT) {
          matchingCount = await this.prisma.membership.count({
            where: {
              ...membershipBaseWhere,
              ...(startDate && endDate
                ? {
                    account: {
                      dob: {
                        gte: startDate,
                        lte: endDate,
                      },
                    },
                  }
                : {}),
            },
          });
          break;
        }

        matchingCount = await this.prisma.membership.count({
          where: membershipBaseWhere,
        });
        break;
      }
      case ReportGenerateType.ACTIVITY:
        matchingCount = await this.prisma.activity.count({
          where: {
            supervisor: {
              churchId,
            },
            ...(columnId != null ? { columnId } : {}),
            ...(activityType ? { activityType } : {}),
            ...(startDate && endDate
              ? {
                  date: {
                    gte: startDate,
                    lte: endDate,
                  },
                }
              : {}),
          },
        });
        break;
      case ReportGenerateType.FINANCIAL:
        if (financialSubtype === FinancialReportSubtype.REVENUE) {
          matchingCount = await this.prisma.revenue.count({
            where: {
              churchId,
              ...(startDate && endDate
                ? {
                    createdAt: {
                      gte: startDate,
                      lte: endDate,
                    },
                  }
                : {}),
            },
          });
          break;
        }

        if (financialSubtype === FinancialReportSubtype.EXPENSE) {
          matchingCount = await this.prisma.expense.count({
            where: {
              churchId,
              ...(startDate && endDate
                ? {
                    createdAt: {
                      gte: startDate,
                      lte: endDate,
                    },
                  }
                : {}),
            },
          });
          break;
        }

        const [cashAccountsCount, cashMutationsCount] =
          await this.prisma.$transaction([
            this.prisma.cashAccount.count({
              where: { churchId },
            }),
            this.prisma.cashMutation.count({
              where: {
                churchId,
                ...(startDate && endDate
                  ? {
                      happenedAt: {
                        gte: startDate,
                        lte: endDate,
                      },
                    }
                  : {}),
              },
            }),
          ]);
        matchingCount = Math.max(cashAccountsCount, cashMutationsCount);
        break;
      case ReportGenerateType.SERVICES:
        throw new BadRequestException(
          'Report generation for SERVICES is not supported yet',
        );
    }

    if (matchingCount <= 0) {
      throw new BadRequestException(
        this.buildNoMatchingDataMessage(type, input),
      );
    }
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
    qrPngBuffer?: Buffer;
    publicId?: string;
    churchName?: string;
    generatedAt?: Date;
  }): Promise<Buffer> {
    const generatedAt = params.generatedAt ?? new Date();
    const doc = new PDFDocument({
      size: 'A4',
      margin: 48,
      bufferPages: true,
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
        .text(`Generated at: ${generatedAt.toISOString()}`);
      doc.moveDown();

      doc.fillColor('#000000').fontSize(12);
      for (const line of params.lines) {
        doc.text(line);
      }

      if (params.qrPngBuffer && params.publicId) {
        doc.moveDown();

        const availableWidth =
          doc.page.width - doc.page.margins.left - doc.page.margins.right;
        const padding = 10;
        const qrSize = 96;
        const boxHeight = qrSize + padding * 2;

        const bottomLimit = doc.page.height - doc.page.margins.bottom;
        if (doc.y + boxHeight + 12 > bottomLimit) {
          doc.addPage();
        }

        const range =
          typeof doc.bufferedPageRange === 'function'
            ? doc.bufferedPageRange()
            : { start: 0, count: 1 };
        const totalPages = (range.start ?? 0) + (range.count ?? 1);

        const x = doc.page.margins.left;
        const y = doc.y;

        doc
          .rect(x, y, availableWidth, boxHeight)
          .strokeColor('#DDDDDD')
          .lineWidth(1)
          .stroke();

        const qrX = x + padding;
        const qrY = y + padding;
        try {
          doc.image(params.qrPngBuffer, qrX, qrY, {
            width: qrSize,
            height: qrSize,
          });
        } catch {}

        const textX = qrX + qrSize + 12;
        const textWidth = Math.max(0, x + availableWidth - padding - textX);

        const churchName = (params.churchName ?? '').trim();
        const generatedLabel = `Generated: ${this.formatGeneratedAtForVerifyBlock(
          generatedAt,
        )}`;
        const pagesLabel = `Total pages: ${totalPages}`;

        doc.fontSize(11).fillColor('#0f172a');
        doc.text(churchName || 'Report verification', textX, qrY, {
          width: textWidth,
          lineBreak: false,
          ellipsis: true,
        });

        doc.fontSize(8).fillColor('#475569');
        doc.text(generatedLabel, textX, doc.y + 6, {
          width: textWidth,
        });
        doc.text(pagesLabel, textX, doc.y + 2, {
          width: textWidth,
        });

        doc.fontSize(8).fillColor('#64748b');
        doc.text(`/verify/report/${params.publicId}`, textX, doc.y + 8, {
          width: textWidth,
        });
        doc.text(`Code: ${params.publicId}`, textX, doc.y + 2, {
          width: textWidth,
        });

        doc.y = y + boxHeight + 12;
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
    logoBuffer?: Buffer;
  }): Promise<Buffer> {
    const detectXlsxImageExtension = (
      buffer: Buffer,
    ): 'png' | 'jpeg' | undefined => {
      if (buffer.length >= 8) {
        if (
          buffer[0] === 0x89 &&
          buffer[1] === 0x50 &&
          buffer[2] === 0x4e &&
          buffer[3] === 0x47 &&
          buffer[4] === 0x0d &&
          buffer[5] === 0x0a &&
          buffer[6] === 0x1a &&
          buffer[7] === 0x0a
        ) {
          return 'png';
        }
      }

      if (buffer.length >= 3) {
        if (buffer[0] === 0xff && buffer[1] === 0xd8 && buffer[2] === 0xff) {
          return 'jpeg';
        }
      }

      return;
    };

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

    const logoExt = params.logoBuffer
      ? detectXlsxImageExtension(params.logoBuffer)
      : undefined;
    const hasLogo = !!logoExt && !!params.logoBuffer?.length;

    const headerRowsCount = hasLogo
      ? Math.max(headerLines.length, 4)
      : headerLines.length;
    for (let i = 0; i < headerRowsCount; i++) {
      const line = headerLines[i] ?? '';
      const row = sheet.addRow([line]);
      if (hasLogo) {
        if (i < 4) row.height = 18;
        row.getCell(1).alignment = {
          vertical: 'middle',
          indent: 12,
        };
      }
    }

    if (headerRowsCount) {
      sheet.addRow([]);
    }

    if (hasLogo && logoExt && params.logoBuffer) {
      try {
        const imageOptions: any = {
          buffer: params.logoBuffer,
          extension: logoExt,
        };
        const imageId = workbook.addImage(imageOptions);
        sheet.addImage(imageId, {
          tl: { col: 0, row: 0 },
          ext: { width: 72, height: 72 },
        });
      } catch {
        // ignore
      }
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

  async getReports(query: ReportListQueryDto, user?: any) {
    const {
      search,
      churchId,
      generatedBy,
      createdById,
      mine,
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

    if (createdById) {
      where.createdById = createdById;
    }

    if (mine && user?.userId) {
      where.createdById = user.userId;
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
    return this.generateInternal(dto, user?.userId, churchId);
  }

  async generateInternal(
    dto: ReportGenerateDto,
    userId: number,
    churchId: number,
  ) {
    const type = dto.type;
    const format = dto.format ?? ReportFormat.PDF;
    const startDate = dto.startDate;
    const endDate = dto.endDate;

    const congregationSubtype =
      type === ReportGenerateType.CONGREGATION
        ? (dto.congregationSubtype ?? CongregationReportSubtype.WARTA_JEMAAT)
        : dto.congregationSubtype;

    const columnId =
      type === ReportGenerateType.CONGREGATION ||
      type === ReportGenerateType.ACTIVITY
        ? dto.columnId
        : undefined;

    const input = dto.input ?? DocumentInput.INCOME;

    const activityType =
      type === ReportGenerateType.ACTIVITY ? dto.activityType : undefined;

    const financialSubtype =
      type === ReportGenerateType.FINANCIAL
        ? (dto.financialSubtype ?? FinancialReportSubtype.REVENUE)
        : dto.financialSubtype;

    await this.assertHasMatchingData(
      {
        type,
        format,
        input,
        startDate,
        endDate,
        congregationSubtype,
        columnId,
        activityType,
        financialSubtype,
      },
      churchId,
    );

    const church = await this.prisma.church.findUnique({
      where: { id: churchId },
      select: {
        name: true,
        phoneNumber: true,
        email: true,
        location: {
          select: {
            name: true,
          },
        },
      },
    });
    const churchName = church?.name ?? undefined;

    const letterheadInfo = church?.name
      ? buildGmimLetterhead({
          churchName: church.name,
          locationName: church.location?.name,
          phoneNumber: church.phoneNumber,
          email: church.email,
        })
      : undefined;
    const logoBuffer = getGmimLogoBuffer();

    const isDocumentReport = type === ReportGenerateType.DOCUMENT;

    const title = isDocumentReport
      ? input === DocumentInput.OUTCOME
        ? 'Laporan Dokumen Keluar'
        : 'Laporan Dokumen Masuk'
      : [
          'Report',
          type,
          type === ReportGenerateType.CONGREGATION
            ? congregationSubtype
            : undefined,
          type === ReportGenerateType.FINANCIAL ? financialSubtype : undefined,
        ]
          .filter((x) => !!x)
          .join(' ');

    const generatedAt = new Date();

    const signPdf = format === ReportFormat.PDF;
    let publicId: string | undefined;
    let verifyTokenHash: string | undefined;
    let qrPngBuffer: Buffer | undefined;

    if (signPdf) {
      publicId = randomUUID();
      const token = randomBytes(32).toString('base64url');
      verifyTokenHash = this.sha256Hex(token);

      const baseUrl = this.resolvePublicBaseUrl();
      let verificationUrl: string;
      try {
        const u = new URL(`/verify/report/${publicId}`, baseUrl);
        u.searchParams.set('t', token);
        verificationUrl = u.toString();
      } catch {
        throw new BadRequestException('PUBLIC_BASE_URL is invalid');
      }

      qrPngBuffer = await QRCode.toBuffer(verificationUrl, {
        type: 'png',
        errorCorrectionLevel: 'M',
        margin: 1,
        width: 256,
      });
    }

    let buffer: Buffer | undefined;

    if (type === ReportGenerateType.DOCUMENT) {
      const activities = await this.prisma.activity.findMany({
        where: this.buildDocumentActivityWhere(
          churchId,
          startDate,
          endDate,
          input,
        ),
        include: {
          file: true,
          document: true,
        },
        orderBy: [{ date: 'desc' }, { createdAt: 'desc' }],
      });

      const sections: TableSection[] = [
        {
          columns: [
            { header: 'Title', key: 'title', weight: 3 },
            { header: 'Description', key: 'description', weight: 4 },
            { header: 'No', key: 'no', weight: 2 },
            { header: 'Date', key: 'date', weight: 2 },
            { header: 'File', key: 'fileName', weight: 3 },
          ],
          rows: activities.map((activity) => {
            const fileName =
              activity.file?.originalName ??
              (activity.file?.path
                ? String(activity.file.path).split('/').pop()
                : '') ??
              '';

            return {
              title: activity.title,
              description: activity.description ?? '',
              no: activity.document?.accountNumber ?? '',
              date: this.formatIndonesianDate(activity.date),
              fileName,
            };
          }),
        },
      ];

      buffer =
        format === ReportFormat.XLSX
          ? await renderXlsxTableReportBuffer({
              title,
              titleAlign: 'center',
              sections,
              letterhead: letterheadInfo,
              logoBuffer,
            })
          : await renderPdfTableReportBuffer({
              title,
              titleAlign: 'center',
              sections,
              letterhead: letterheadInfo,
              logoBuffer,
              generatedAt,
              qrPngBuffer,
              publicId,
              churchName,
            });
    }

    if (type === ReportGenerateType.FINANCIAL) {
      if (financialSubtype === FinancialReportSubtype.REVENUE) {
        const revenues = await this.prisma.revenue.findMany({
          where: {
            churchId,
            ...(startDate && endDate
              ? {
                  createdAt: {
                    gte: startDate,
                    lte: endDate,
                  },
                }
              : {}),
          },
          include: {
            financialAccountNumber: true,
            activity: true,
          },
          orderBy: {
            createdAt: 'desc',
          },
        });

        const sections: TableSection[] = [
          {
            columns: [
              { header: 'Date', key: 'createdAt', weight: 2 },
              { header: 'Account No', key: 'accountNumber', weight: 2 },
              { header: 'Amount', key: 'amount', weight: 2, align: 'right' },
              { header: 'Payment', key: 'paymentMethod', weight: 1 },
              { header: 'Fin. Account', key: 'finAccount', weight: 2 },
              { header: 'Description', key: 'description', weight: 3 },
              { header: 'Activity', key: 'activity', weight: 3 },
            ],
            rows: revenues.map((r) => ({
              createdAt: r.createdAt,
              accountNumber: r.accountNumber,
              amount: r.amount,
              paymentMethod: r.paymentMethod,
              finAccount: r.financialAccountNumber?.accountNumber ?? '',
              description: r.financialAccountNumber?.description ?? '',
              activity: r.activity?.title ?? '',
            })),
          },
        ];

        buffer =
          format === ReportFormat.XLSX
            ? await renderXlsxTableReportBuffer({
                title,
                sections,
                letterhead: letterheadInfo,
                logoBuffer,
              })
            : await renderPdfTableReportBuffer({
                title,
                sections,
                letterhead: letterheadInfo,
                logoBuffer,
                generatedAt,
                qrPngBuffer,
                publicId,
                churchName,
              });
      } else if (financialSubtype === FinancialReportSubtype.EXPENSE) {
        const expenses = await this.prisma.expense.findMany({
          where: {
            churchId,
            ...(startDate && endDate
              ? {
                  createdAt: {
                    gte: startDate,
                    lte: endDate,
                  },
                }
              : {}),
          },
          include: {
            financialAccountNumber: true,
            activity: true,
          },
          orderBy: {
            createdAt: 'desc',
          },
        });

        const sections: TableSection[] = [
          {
            columns: [
              { header: 'Date', key: 'createdAt', weight: 2 },
              { header: 'Account No', key: 'accountNumber', weight: 2 },
              { header: 'Amount', key: 'amount', weight: 2, align: 'right' },
              { header: 'Payment', key: 'paymentMethod', weight: 1 },
              { header: 'Fin. Account', key: 'finAccount', weight: 2 },
              { header: 'Description', key: 'description', weight: 3 },
              { header: 'Activity', key: 'activity', weight: 3 },
            ],
            rows: expenses.map((e) => ({
              createdAt: e.createdAt,
              accountNumber: e.accountNumber,
              amount: e.amount,
              paymentMethod: e.paymentMethod,
              finAccount: e.financialAccountNumber?.accountNumber ?? '',
              description: e.financialAccountNumber?.description ?? '',
              activity: e.activity?.title ?? '',
            })),
          },
        ];

        buffer =
          format === ReportFormat.XLSX
            ? await renderXlsxTableReportBuffer({
                title,
                sections,
                letterhead: letterheadInfo,
                logoBuffer,
              })
            : await renderPdfTableReportBuffer({
                title,
                sections,
                letterhead: letterheadInfo,
                logoBuffer,
                generatedAt,
                qrPngBuffer,
                publicId,
                churchName,
              });
      } else {
        const accounts = await this.prisma.cashAccount.findMany({
          where: { churchId },
          orderBy: { name: 'asc' },
        });

        const accountById = new Map(accounts.map((a) => [a.id, a]));

        const mutationsAll = await this.prisma.cashMutation.findMany({
          where: {
            churchId,
            ...(endDate
              ? {
                  happenedAt: {
                    lte: endDate,
                  },
                }
              : {}),
          },
          include: {
            fromAccount: true,
            toAccount: true,
          },
          orderBy: [{ happenedAt: 'asc' }, { id: 'asc' }],
        });

        const rangeMutations =
          startDate && endDate
            ? mutationsAll.filter(
                (m) => m.happenedAt >= startDate && m.happenedAt <= endDate,
              )
            : mutationsAll;

        const beforeStart = startDate
          ? mutationsAll.filter((m) => m.happenedAt < startDate)
          : [];

        const sumIn = (items: typeof mutationsAll) => {
          const map = new Map<number, number>();
          for (const m of items) {
            if (m.toAccountId != null) {
              map.set(m.toAccountId, (map.get(m.toAccountId) ?? 0) + m.amount);
            }
          }
          return map;
        };

        const sumOut = (items: typeof mutationsAll) => {
          const map = new Map<number, number>();
          for (const m of items) {
            if (m.fromAccountId != null) {
              map.set(
                m.fromAccountId,
                (map.get(m.fromAccountId) ?? 0) + m.amount,
              );
            }
          }
          return map;
        };

        const inBefore = sumIn(beforeStart);
        const outBefore = sumOut(beforeStart);
        const inRange = sumIn(rangeMutations);
        const outRange = sumOut(rangeMutations);

        const positionRows = accounts.map((a) => {
          const opening =
            (a.openingBalance ?? 0) +
            (startDate
              ? (inBefore.get(a.id) ?? 0) - (outBefore.get(a.id) ?? 0)
              : 0);
          const totalIn = inRange.get(a.id) ?? 0;
          const totalOut = outRange.get(a.id) ?? 0;
          const net = totalIn - totalOut;
          const closing = opening + net;

          return {
            account: a.name,
            currency: a.currency,
            opening,
            totalIn,
            totalOut,
            net,
            closing,
          };
        });

        const cashPositionSection: TableSection = {
          title: 'Cash Position',
          columns: [
            { header: 'Account', key: 'account', weight: 3 },
            { header: 'Currency', key: 'currency', weight: 1 },
            { header: 'Opening', key: 'opening', weight: 2, align: 'right' },
            { header: 'In', key: 'totalIn', weight: 2, align: 'right' },
            { header: 'Out', key: 'totalOut', weight: 2, align: 'right' },
            { header: 'Net', key: 'net', weight: 2, align: 'right' },
            { header: 'Closing', key: 'closing', weight: 2, align: 'right' },
          ],
          rows: positionRows,
        };

        const ledgerRows = rangeMutations.map((m) => {
          const fromName =
            m.fromAccount?.name ??
            (m.fromAccountId != null
              ? (accountById.get(m.fromAccountId)?.name ??
                `Account ${m.fromAccountId}`)
              : '-');

          const toName =
            m.toAccount?.name ??
            (m.toAccountId != null
              ? (accountById.get(m.toAccountId)?.name ??
                `Account ${m.toAccountId}`)
              : '-');

          return {
            happenedAt: m.happenedAt,
            type: m.type,
            reference: m.referenceType ?? 'MANUAL',
            from: fromName,
            to: toName,
            amount: m.amount,
            note: m.note ?? '',
          };
        });

        const buildLedgerSection = (params: {
          title: string;
          rows: typeof ledgerRows;
        }): TableSection => ({
          title: params.title,
          columns: [
            { header: 'Date', key: 'happenedAt', weight: 2 },
            { header: 'Type', key: 'type', weight: 1 },
            { header: 'Ref', key: 'reference', weight: 1 },
            { header: 'From', key: 'from', weight: 2 },
            { header: 'To', key: 'to', weight: 2 },
            { header: 'Amount', key: 'amount', weight: 2, align: 'right' },
            { header: 'Note', key: 'note', weight: 4 },
          ],
          rows: params.rows,
        });

        const revenueLedger = ledgerRows.filter(
          (r) => r.reference === 'REVENUE',
        );
        const expenseLedger = ledgerRows.filter(
          (r) => r.reference === 'EXPENSE',
        );
        const otherLedger = ledgerRows.filter(
          (r) => r.reference !== 'REVENUE' && r.reference !== 'EXPENSE',
        );

        const sections: TableSection[] = [
          cashPositionSection,
          buildLedgerSection({
            title: 'Mutations - Revenue',
            rows: revenueLedger,
          }),
          buildLedgerSection({
            title: 'Mutations - Expense',
            rows: expenseLedger,
          }),
          buildLedgerSection({
            title: 'Mutations - Other',
            rows: otherLedger,
          }),
        ].filter((s) => (s.rows?.length ?? 0) > 0);

        buffer =
          format === ReportFormat.XLSX
            ? await renderXlsxTableReportBuffer({
                title,
                sections,
                letterhead: letterheadInfo,
                logoBuffer,
              })
            : await renderPdfTableReportBuffer({
                title,
                sections,
                letterhead: letterheadInfo,
                logoBuffer,
                generatedAt,
                qrPngBuffer,
                publicId,
                churchName,
              });
      }
    }

    if (type === ReportGenerateType.CONGREGATION) {
      const membershipBaseWhere: Prisma.MembershipWhereInput = {
        churchId,
        ...(columnId != null ? { columnId } : {}),
        ...(startDate && endDate
          ? {
              createdAt: {
                gte: startDate,
                lte: endDate,
              },
            }
          : {}),
      };

      if (congregationSubtype === CongregationReportSubtype.WARTA_JEMAAT) {
        const [totalMembers, baptizeMembers, sidiMembers] =
          await this.prisma.$transaction([
            this.prisma.membership.count({
              where: membershipBaseWhere,
            }),
            this.prisma.membership.count({
              where: {
                ...membershipBaseWhere,
                baptize: true,
              },
            }),
            this.prisma.membership.count({
              where: {
                ...membershipBaseWhere,
                sidi: true,
              },
            }),
          ]);

        const summaryLines: string[] = [
          `Church ID: ${churchId}`,
          startDate
            ? `Start: ${new Date(startDate).toISOString()}`
            : 'Start: -',
          endDate ? `End: ${new Date(endDate).toISOString()}` : 'End: -',
          columnId != null ? `Column ID: ${columnId}` : 'Column: All',
          '',
          `Total members: ${totalMembers}`,
          `Baptized: ${baptizeMembers}`,
          `Sidi: ${sidiMembers}`,
        ];

        const sections: BulletinSection[] = [
          {
            title: 'Summary',
            lines: summaryLines,
          },
        ];

        if (columnId == null) {
          const grouped = await this.prisma.membership.groupBy({
            by: ['columnId'],
            where: membershipBaseWhere,
            _count: { _all: true },
          });

          const columnIds = grouped
            .map((g) => g.columnId)
            .filter((id): id is number => typeof id === 'number');

          if (columnIds.length) {
            const columns = await this.prisma.column.findMany({
              where: { id: { in: columnIds } },
              select: { id: true, name: true },
            });
            const nameById = new Map(columns.map((c) => [c.id, c.name]));

            const breakdownLines = grouped
              .filter((g) => typeof g.columnId === 'number')
              .sort((a, b) => (a.columnId ?? 0) - (b.columnId ?? 0))
              .map((g) => {
                const id = g.columnId as number;
                const name = nameById.get(id) ?? `Column ${id}`;
                return `${name}: ${g._count._all}`;
              });

            if (breakdownLines.length) {
              sections.push({
                title: 'By Column',
                lines: breakdownLines,
              });
            }
          }
        }

        buffer =
          format === ReportFormat.XLSX
            ? await renderXlsxBulletinReportBuffer({
                title,
                sections,
                letterhead: letterheadInfo,
                logoBuffer,
              })
            : await renderPdfBulletinReportBuffer({
                title,
                sections,
                letterhead: letterheadInfo,
                logoBuffer,
                generatedAt,
                qrPngBuffer,
                publicId,
                churchName,
              });
      } else if (congregationSubtype === CongregationReportSubtype.HUT_JEMAAT) {
        const where: Prisma.MembershipWhereInput = {
          ...membershipBaseWhere,
          ...(startDate && endDate
            ? {
                account: {
                  dob: {
                    gte: startDate,
                    lte: endDate,
                  },
                },
              }
            : {}),
        };

        const memberships = await this.prisma.membership.findMany({
          where,
          include: {
            account: true,
            column: true,
          },
          orderBy: [{ account: { dob: 'asc' } }, { account: { name: 'asc' } }],
        });

        const sections: TableSection[] = [
          {
            columns: [
              { header: 'Name', key: 'name', weight: 3 },
              { header: 'DOB', key: 'dob', weight: 2 },
              { header: 'Phone', key: 'phone', weight: 2 },
              { header: 'Email', key: 'email', weight: 3 },
              { header: 'Column', key: 'column', weight: 2 },
              { header: 'Baptize', key: 'baptize', weight: 1, align: 'center' },
              { header: 'Sidi', key: 'sidi', weight: 1, align: 'center' },
            ],
            rows: memberships.map((m) => ({
              name: m.account?.name,
              dob: m.account?.dob,
              phone: m.account?.phone,
              email: m.account?.email,
              column: m.column?.name ?? '',
              baptize: m.baptize,
              sidi: m.sidi,
            })),
          },
        ];

        buffer =
          format === ReportFormat.XLSX
            ? await renderXlsxTableReportBuffer({
                title,
                sections,
                letterhead: letterheadInfo,
                logoBuffer,
              })
            : await renderPdfTableReportBuffer({
                title,
                sections,
                letterhead: letterheadInfo,
                logoBuffer,
                generatedAt,
                qrPngBuffer,
                publicId,
                churchName,
              });
      } else {
        const memberships = await this.prisma.membership.findMany({
          where: membershipBaseWhere,
          include: {
            account: true,
            column: true,
          },
          orderBy: [{ account: { name: 'asc' } }],
        });

        const sections: TableSection[] = [
          {
            columns: [
              { header: 'nama', key: 'nama', weight: 4 },
              { header: 'telepon', key: 'telepon', weight: 2 },
              { header: 'lahir', key: 'lahir', weight: 2 },
              { header: 'jenis', key: 'jenis', weight: 2 },
              { header: 'menikah', key: 'menikah', weight: 1, align: 'center' },
              { header: 'baptis', key: 'baptis', weight: 1, align: 'center' },
              { header: 'sidi', key: 'sidi', weight: 1, align: 'center' },
              { header: 'kolom', key: 'kolom', weight: 2 },
              {
                header: 'terhubung aplikasi',
                key: 'terhubungAplikasi',
                weight: 2,
                align: 'center',
              },
            ],
            rows: memberships.map((m) => ({
              nama: m.account?.name,
              telepon: m.account?.phone,
              lahir: this.formatIndonesianDate(m.account?.dob),
              jenis:
                m.account?.gender === 'MALE'
                  ? 'Laki-laki'
                  : m.account?.gender === 'FEMALE'
                    ? 'perempuan'
                    : '',
              menikah: m.account?.maritalStatus === 'MARRIED',
              kolom: m.column?.name ?? '',
              baptis: m.baptize,
              sidi: m.sidi,
              terhubungAplikasi: m.account?.claimed === true,
            })),
          },
        ];

        buffer =
          format === ReportFormat.XLSX
            ? await renderXlsxTableReportBuffer({
                title,
                sections,
                letterhead: letterheadInfo,
                logoBuffer,
              })
            : await renderPdfTableReportBuffer({
                title,
                sections,
                letterhead: letterheadInfo,
                logoBuffer,
                generatedAt,
                layout: 'landscape',
                qrPngBuffer,
                publicId,
                churchName,
              });
      }
    }

    if (type === ReportGenerateType.ACTIVITY) {
      const where: Prisma.ActivityWhereInput = {
        supervisor: {
          churchId,
        },
        ...(columnId != null ? { columnId } : {}),
        ...(activityType ? { activityType } : {}),
        ...(startDate && endDate
          ? {
              date: {
                gte: startDate,
                lte: endDate,
              },
            }
          : {}),
      };

      const activities = await this.prisma.activity.findMany({
        where,
        include: {
          column: true,
          supervisor: {
            include: {
              account: true,
            },
          },
        },
        orderBy: [{ date: 'desc' }, { createdAt: 'desc' }],
      });

      const sections: TableSection[] = [
        {
          columns: [
            { header: 'Date', key: 'date', weight: 2 },
            { header: 'Type', key: 'activityType', weight: 1 },
            { header: 'Title', key: 'title', weight: 4 },
            { header: 'Column', key: 'column', weight: 2 },
            { header: 'Supervisor', key: 'supervisor', weight: 2 },
            { header: 'Note', key: 'note', weight: 3 },
          ],
          rows: activities.map((a) => ({
            date: a.date,
            activityType: a.activityType,
            title: a.title,
            column: a.column?.name ?? '',
            supervisor: a.supervisor?.account?.name ?? '',
            note: a.note ?? '',
          })),
        },
      ];

      buffer =
        format === ReportFormat.XLSX
          ? await renderXlsxTableReportBuffer({
              title,
              sections,
              letterhead: letterheadInfo,
              logoBuffer,
            })
          : await renderPdfTableReportBuffer({
              title,
              sections,
              letterhead: letterheadInfo,
              logoBuffer,
              generatedAt,
              qrPngBuffer,
              publicId,
              churchName,
            });
    }

    if (!buffer) {
      throw new BadRequestException(
        `Report generation for ${type} is not supported yet`,
      );
    }

    const fileSha256 = signPdf ? this.sha256Hex(buffer) : undefined;

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
          reportPublicId: publicId ? String(publicId) : '',
          reportInput: input ? String(input) : '',
          reportCongregationSubtype: congregationSubtype
            ? String(congregationSubtype)
            : '',
          reportColumnId: columnId != null ? String(columnId) : '',
          reportActivityType: activityType ? String(activityType) : '',
          reportFinancialSubtype: financialSubtype
            ? String(financialSubtype)
            : '',
        },
      },
    });

    const file = await this.prisma.fileManager.create({
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

    const reportParams = (() => {
      const params: Record<string, unknown> = {};
      if (input != null) params.input = input;
      if (congregationSubtype != null)
        params.congregationSubtype = congregationSubtype;
      if (columnId != null) params.columnId = columnId;
      if (activityType != null) params.activityType = activityType;
      if (financialSubtype != null) params.financialSubtype = financialSubtype;
      if (startDate) params.startDate = startDate.toISOString();
      if (endDate) params.endDate = endDate.toISOString();

      return Object.keys(params).length
        ? (params as Prisma.InputJsonValue)
        : undefined;
    })();

    const report = await this.prisma.report.create({
      data: {
        name: title,
        type: isDocumentReport ? ReportGenerateType.DOCUMENT : type,
        format,
        params: reportParams,
        generatedBy: GeneratedBy.SYSTEM,
        churchId,
        fileId: file.id,
        createdById: userId ?? null,
        publicId,
        verifyTokenHash,
        fileSha256,
      },
      include: {
        church: true,
        file: true,
      },
    });

    return {
      message: 'Report generated',
      data: report,
    };
  }
}
