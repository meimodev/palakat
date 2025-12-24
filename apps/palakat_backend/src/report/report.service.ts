import { BadRequestException, Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';
import {
  DocumentInput,
  GeneratedBy,
  Prisma,
  ReportFormat,
  ReportGenerateType,
} from '../generated/prisma/client';
import PDFDocument from 'pdfkit';
import { PassThrough } from 'stream';
import { PrismaService } from '../prisma.service';
import { ReportListQueryDto } from './dto/report-list.dto';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
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
      type === ReportGenerateType.INCOMING_DOCUMENT ||
      type === ReportGenerateType.OUTCOMING_DOCUMENT
        ? (dto.input ??
          (type === ReportGenerateType.INCOMING_DOCUMENT
            ? DocumentInput.INCOME
            : DocumentInput.OUTCOME))
        : dto.input;

    const activityType =
      type === ReportGenerateType.ACTIVITY ? dto.activityType : undefined;

    const financialSubtype =
      type === ReportGenerateType.FINANCIAL
        ? (dto.financialSubtype ?? FinancialReportSubtype.REVENUE)
        : dto.financialSubtype;

    const letterhead = await this.prisma.churchLetterhead.findUnique({
      where: { churchId },
      include: { logoFile: true },
    });

    const logoBuffer = await this.tryDownloadLogoBuffer(
      letterhead?.logoFile ?? undefined,
    );

    const letterheadInfo = letterhead
      ? {
          title: letterhead.title,
          line1: letterhead.line1,
          line2: letterhead.line2,
          line3: letterhead.line3,
        }
      : undefined;

    const title = [
      'Report',
      type,
      type === ReportGenerateType.CONGREGATION
        ? congregationSubtype
        : undefined,
      type === ReportGenerateType.FINANCIAL ? financialSubtype : undefined,
    ]
      .filter((x) => !!x)
      .join(' ');

    let buffer: Buffer | undefined;

    if (
      type === ReportGenerateType.INCOMING_DOCUMENT ||
      type === ReportGenerateType.OUTCOMING_DOCUMENT
    ) {
      const documents = await this.prisma.document.findMany({
        where: {
          churchId,
          input,
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
          file: true,
        },
        orderBy: {
          createdAt: 'desc',
        },
      });

      const sections: TableSection[] = [
        {
          columns: [
            { header: 'Name', key: 'name', weight: 3 },
            { header: 'Account No', key: 'accountNumber', weight: 2 },
            { header: 'Date', key: 'createdAt', weight: 2 },
            { header: 'File', key: 'fileName', weight: 3 },
          ],
          rows: documents.map((d) => {
            const fileName =
              d.file?.originalName ??
              (d.file?.path ? String(d.file.path).split('/').pop() : '') ??
              '';

            return {
              name: d.name,
              accountNumber: d.accountNumber,
              createdAt: d.createdAt,
              fileName,
            };
          }),
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
              { header: 'Name', key: 'name', weight: 3 },
              { header: 'Phone', key: 'phone', weight: 2 },
              { header: 'Email', key: 'email', weight: 3 },
              { header: 'DOB', key: 'dob', weight: 2 },
              { header: 'Column', key: 'column', weight: 2 },
              { header: 'Baptize', key: 'baptize', weight: 1, align: 'center' },
              { header: 'Sidi', key: 'sidi', weight: 1, align: 'center' },
              { header: 'Joined At', key: 'createdAt', weight: 2 },
            ],
            rows: memberships.map((m) => ({
              name: m.account?.name,
              phone: m.account?.phone,
              email: m.account?.email,
              dob: m.account?.dob,
              column: m.column?.name ?? '',
              baptize: m.baptize,
              sidi: m.sidi,
              createdAt: m.createdAt,
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
            });
    }

    const lines: string[] = [
      `Church ID: ${churchId}`,
      startDate ? `Start: ${new Date(startDate).toISOString()}` : 'Start: -',
      endDate ? `End: ${new Date(endDate).toISOString()}` : 'End: -',
      '',
      'This report is a generated artifact.',
    ];

    if (input) {
      lines.splice(1, 0, `Input: ${input}`);
    }

    if (congregationSubtype) {
      lines.push('', `Congregation Subtype: ${congregationSubtype}`);
    }

    if (columnId != null) {
      lines.push(`Column ID: ${columnId}`);
    }

    if (activityType) {
      lines.push(`Activity Type: ${activityType}`);
    }

    if (financialSubtype) {
      lines.push(`Financial Subtype: ${financialSubtype}`);
    }

    if (
      !buffer &&
      (type === ReportGenerateType.INCOMING_DOCUMENT ||
        type === ReportGenerateType.OUTCOMING_DOCUMENT)
    ) {
      const documentsCount = await this.prisma.document.count({
        where: {
          churchId,
          input,
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
      lines.push('', `Documents: ${documentsCount}`);
    }

    if (!buffer && type === ReportGenerateType.CONGREGATION) {
      const membersCount = await this.prisma.membership.count({
        where: {
          churchId,
          ...(columnId != null ? { columnId } : {}),
        },
      });
      lines.push('', `Members: ${membersCount}`);
    }

    if (!buffer && type === ReportGenerateType.ACTIVITY) {
      const activitiesCount = await this.prisma.activity.count({
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
      lines.push('', `Activities: ${activitiesCount}`);
    }

    if (!buffer && type === ReportGenerateType.FINANCIAL) {
      const includeRevenue =
        financialSubtype === FinancialReportSubtype.REVENUE ||
        financialSubtype === FinancialReportSubtype.MUTATION;
      const includeExpense =
        financialSubtype === FinancialReportSubtype.EXPENSE ||
        financialSubtype === FinancialReportSubtype.MUTATION;

      const [revenueAgg, expenseAgg] = await this.prisma.$transaction([
        includeRevenue
          ? this.prisma.revenue.aggregate({
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
              _count: { _all: true },
              _sum: { amount: true },
            })
          : this.prisma.revenue.aggregate({
              where: { id: -1 },
              _count: { _all: true },
              _sum: { amount: true },
            }),
        includeExpense
          ? this.prisma.expense.aggregate({
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
              _count: { _all: true },
              _sum: { amount: true },
            })
          : this.prisma.expense.aggregate({
              where: { id: -1 },
              _count: { _all: true },
              _sum: { amount: true },
            }),
      ]);

      const revenueTotal = includeRevenue ? (revenueAgg._sum.amount ?? 0) : 0;
      const expenseTotal = includeExpense ? (expenseAgg._sum.amount ?? 0) : 0;
      const net = revenueTotal - expenseTotal;

      const revenueCount = includeRevenue ? (revenueAgg._count?._all ?? 0) : 0;
      const expenseCount = includeExpense ? (expenseAgg._count?._all ?? 0) : 0;

      if (financialSubtype === FinancialReportSubtype.REVENUE) {
        lines.push(
          '',
          `Revenue (count): ${revenueCount}`,
          `Revenue (total): ${revenueTotal}`,
        );
      } else if (financialSubtype === FinancialReportSubtype.EXPENSE) {
        lines.push(
          '',
          `Expense (count): ${expenseCount}`,
          `Expense (total): ${expenseTotal}`,
        );
      } else {
        lines.push(
          '',
          `Revenue (count): ${revenueCount}`,
          `Revenue (total): ${revenueTotal}`,
          `Expense (count): ${expenseCount}`,
          `Expense (total): ${expenseTotal}`,
          `Net: ${net}`,
        );
      }
    }

    buffer =
      buffer ??
      (format === ReportFormat.XLSX
        ? await this.renderXlsxBuffer({
            title,
            lines,
            letterhead: letterheadInfo,
          })
        : await this.renderPdfBuffer({
            title,
            lines,
            letterhead: letterheadInfo,
            logoBuffer,
          }));

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
        type,
        format,
        params: reportParams,
        generatedBy: GeneratedBy.SYSTEM,
        churchId,
        fileId: file.id,
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
