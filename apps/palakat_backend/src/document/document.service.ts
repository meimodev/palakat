import {
  BadRequestException,
  ConflictException,
  Injectable,
} from '@nestjs/common';
import { createHash, randomBytes, randomUUID } from 'crypto';
import {
  ApprovalStatus,
  DocumentInput,
  Prisma,
} from '../generated/prisma/client';
import { PrismaService } from '../prisma.service';
import { DocumentListQueryDto } from './dto/document-list.dto';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import * as QRCode from 'qrcode';
import {
  renderPdfSignedDocumentBuffer,
  type DocumentMetaRow,
  type DocumentSubTitle,
  type DocumentSection,
} from './document-renderer';
import { buildGmimLetterhead, getGmimLogoBuffer } from '../utils';

type DocumentMetadataRow = {
  id: number;
  certificateType: string | null;
  certificateTitle: string | null;
};

type SuratKeteranganJemaatActivityNote = {
  certificateType?: string;
  subjectMembership?: {
    membershipId?: number;
    name?: string;
    churchName?: string;
    columnName?: string;
  };
};

type SuratKredensiDescription = {
  purpose: string | null;
  effectiveFrom: string | null;
  effectiveTo: string | null;
  members: string[];
};

type CertificateRenderData = {
  metaRows: DocumentMetaRow[];
  sections: DocumentSection[];
  subtitle?: DocumentSubTitle | null;
};

@Injectable()
export class DocumentService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly firebaseAdmin: FirebaseAdminService,
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

  private sha256Hex(input: string | Buffer): string {
    return createHash('sha256').update(input).digest('hex');
  }

  private resolvePublicBaseUrl(): string {
    const base = process.env.PUBLIC_BASE_URL;
    if (base && base.trim().length) return base.trim().replace(/\/$/, '');

    const port = process.env.PORT || '3000';
    return `http://localhost:${port}`;
  }

  private async getDocumentMetadataMap(
    documentIds: number[],
  ): Promise<Map<number, Omit<DocumentMetadataRow, 'id'>>> {
    if (documentIds.length === 0) {
      return new Map();
    }

    const rows = await this.prisma.$queryRaw<DocumentMetadataRow[]>`
      SELECT "id", "certificateType", "certificateTitle"
      FROM "Document"
      WHERE "id" IN (${Prisma.join(documentIds)})
    `;

    return new Map(
      rows.map((row) => [
        row.id,
        {
          certificateType: row.certificateType,
          certificateTitle: row.certificateTitle,
        },
      ]),
    );
  }

  private async getDocumentMetadata(
    documentId: number,
  ): Promise<Omit<DocumentMetadataRow, 'id'> | null> {
    const metadataMap = await this.getDocumentMetadataMap([documentId]);
    return metadataMap.get(documentId) ?? null;
  }

  private withDocumentMetadata<T extends { id: number }>(
    document: T,
    metadata?: Omit<DocumentMetadataRow, 'id'> | null,
  ) {
    return {
      ...document,
      certificateType: metadata?.certificateType ?? null,
      certificateTitle: metadata?.certificateTitle ?? null,
    };
  }

  private async persistDocumentMetadata(
    documentId: number,
    metadata: {
      certificateType?: string | null;
      certificateTitle?: string | null;
    },
    db: Prisma.TransactionClient | PrismaService = this.prisma,
  ): Promise<void> {
    await db.$executeRaw`
      UPDATE "Document"
      SET
        "certificateType" = ${metadata.certificateType ?? null},
        "certificateTitle" = ${metadata.certificateTitle ?? null}
      WHERE "id" = ${documentId}
    `;
  }

  private normalizeMetadataValue(value: unknown): string | null | undefined {
    if (value === undefined) {
      return undefined;
    }

    if (value === null) {
      return null;
    }

    if (typeof value === 'object' && value !== null && 'set' in value) {
      return this.normalizeMetadataValue(
        (value as { set?: unknown | null }).set,
      );
    }

    const normalized = String(value).trim();
    return normalized.length > 0 ? normalized : null;
  }

  private getDocumentActivityInclude() {
    return {
      column: {
        select: {
          id: true,
          name: true,
        },
      },
      supervisor: {
        select: {
          id: true,
          church: {
            select: {
              id: true,
              name: true,
            },
          },
          column: {
            select: {
              id: true,
              name: true,
            },
          },
          account: {
            select: {
              id: true,
              name: true,
              phone: true,
              dob: true,
            },
          },
        },
      },
      approvers: {
        select: {
          id: true,
          membershipId: true,
          activityId: true,
          status: true,
          createdAt: true,
          updatedAt: true,
          membership: {
            select: {
              id: true,
              account: {
                select: {
                  id: true,
                  name: true,
                  phone: true,
                  dob: true,
                },
              },
            },
          },
        },
      },
    } satisfies Prisma.ActivityInclude;
  }

  private normalizeTextValue(value: unknown): string | null {
    if (typeof value !== 'string') {
      return null;
    }

    const normalized = value.trim();
    return normalized.length > 0 ? normalized : null;
  }

  private parseJsonObject(
    value: string | null | undefined,
  ): Record<string, any> | null {
    if (!value || !value.trim()) {
      return null;
    }

    try {
      const parsed = JSON.parse(value);
      return parsed && typeof parsed === 'object' && !Array.isArray(parsed)
        ? (parsed as Record<string, any>)
        : null;
    } catch {
      return null;
    }
  }

  private parseSuratKeteranganJemaatActivityNote(
    note: string | null | undefined,
  ): SuratKeteranganJemaatActivityNote | null {
    const parsed = this.parseJsonObject(note);
    if (!parsed) {
      return null;
    }

    const subjectMembership =
      parsed.subjectMembership && typeof parsed.subjectMembership === 'object'
        ? parsed.subjectMembership
        : null;

    return {
      certificateType: this.normalizeTextValue(parsed.certificateType),
      subjectMembership: subjectMembership
        ? {
            membershipId:
              typeof subjectMembership.membershipId === 'number'
                ? subjectMembership.membershipId
                : undefined,
            name: this.normalizeTextValue(subjectMembership.name),
            churchName: this.normalizeTextValue(subjectMembership.churchName),
            columnName: this.normalizeTextValue(subjectMembership.columnName),
          }
        : undefined,
    };
  }

  private parseSuratKredensiDescription(
    description: string | null | undefined,
  ): SuratKredensiDescription {
    const fallback: SuratKredensiDescription = {
      purpose: null,
      effectiveFrom: null,
      effectiveTo: null,
      members: [],
    };

    if (!description || !description.trim()) {
      return fallback;
    }

    const blocks = description
      .split(/\r?\n\s*\r?\n/g)
      .map((block) => block.trim())
      .filter((block) => block.length > 0);

    if (blocks.length === 0) {
      return fallback;
    }

    const result: SuratKredensiDescription = {
      ...fallback,
      purpose: blocks[0]
        ?.split(/\r?\n/g)
        .map((line) => line.trim())
        .filter((line) => line.length > 0)
        .join(' '),
    };

    for (const block of blocks.slice(1)) {
      const lines = block
        .split(/\r?\n/g)
        .map((line) => line.trim())
        .filter((line) => line.length > 0);
      if (lines.length === 0) {
        continue;
      }

      const heading = lines[0].toLowerCase();
      if (
        heading.includes('tanggal efektif') ||
        heading.includes('effective date')
      ) {
        for (const line of lines.slice(1)) {
          const normalized = line.toLowerCase();
          const separatorIndex = line.indexOf(':');
          const value =
            separatorIndex >= 0
              ? this.normalizeTextValue(line.substring(separatorIndex + 1))
              : this.normalizeTextValue(line);
          if (!value) {
            continue;
          }

          if (
            normalized.startsWith('dari:') ||
            normalized.startsWith('from:')
          ) {
            result.effectiveFrom = value;
          } else if (
            normalized.startsWith('sampai:') ||
            normalized.startsWith('to:')
          ) {
            result.effectiveTo = value;
          }
        }
        continue;
      }

      if (heading.includes('anggota') || heading.includes('members')) {
        result.members = lines
          .slice(1)
          .map((line) => line.replace(/^[-•]\s*/, '').trim())
          .filter((line) => line.length > 0);
      }
    }

    return result;
  }

  private formatIndonesianDate(value: Date): string {
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

    return `${value.getDate()} ${months[value.getMonth()] ?? ''} ${value.getFullYear()}`.trim();
  }

  private buildSuratKeteranganJemaatRenderData(params: {
    activity: any;
    church: {
      name: string | null;
    } | null;
    documentName: string;
    accountNumber: string;
  }): CertificateRenderData {
    const activityNote = this.parseSuratKeteranganJemaatActivityNote(
      params.activity?.note,
    );
    const subjectName =
      activityNote?.subjectMembership?.name ??
      this.normalizeTextValue(params.documentName) ??
      '-';
    const churchName =
      activityNote?.subjectMembership?.churchName ??
      this.normalizeTextValue(params.church?.name) ??
      this.normalizeTextValue(params.activity?.supervisor?.church?.name) ??
      '-';
    const columnName =
      activityNote?.subjectMembership?.columnName ??
      this.normalizeTextValue(params.activity?.column?.name) ??
      this.normalizeTextValue(params.activity?.supervisor?.column?.name) ??
      '-';

    return {
      subtitle: {
        label: 'Atas Nama',
        value: subjectName,
      },
      metaRows: [
        { label: 'Nomor Dokumen', value: params.accountNumber },
        { label: 'Nama Anggota', value: subjectName },
        { label: 'Gereja', value: churchName },
        { label: 'Kolom', value: columnName },
      ],
      sections: [
        {
          lines: [
            'Yang bertanda tangan di bawah ini menerangkan bahwa:',
            '',
            `Nama: ${subjectName}`,
            `Gereja: ${churchName}`,
            `Kolom: ${columnName}`,
            '',
            `${subjectName} adalah benar anggota jemaat yang terdaftar pada ${churchName} dan berada dalam ${columnName}.`,
            'Surat keterangan ini dibuat untuk dipergunakan sebagaimana mestinya.',
          ],
        },
      ],
    };
  }

  private buildSuratKredensiRenderData(params: {
    activity: any;
    church: {
      name: string | null;
    } | null;
    accountNumber: string;
  }): CertificateRenderData {
    const parsed = this.parseSuratKredensiDescription(
      params.activity?.description,
    );
    const churchName = this.normalizeTextValue(params.church?.name) ?? '-';
    const purpose = parsed.purpose ?? 'pelayanan yang ditetapkan gereja';
    const effectiveFrom =
      parsed.effectiveFrom ??
      (params.activity?.date instanceof Date
        ? this.formatIndonesianDate(params.activity.date)
        : null) ??
      '-';
    const effectiveTo = parsed.effectiveTo ?? effectiveFrom;
    const members =
      parsed.members.length > 0
        ? parsed.members
        : [params.activity?.title ?? '-'];

    return {
      subtitle: {
        label: 'Keperluan',
        value: purpose,
      },
      metaRows: [
        { label: 'Nomor Dokumen', value: params.accountNumber },
        { label: 'Gereja', value: churchName },
        { label: 'Berlaku Mulai', value: effectiveFrom },
        { label: 'Berlaku Sampai', value: effectiveTo },
      ],
      sections: [
        {
          lines: [
            'Yang bertanda tangan di bawah ini menyatakan bahwa:',
            '',
            `${churchName} memberikan izin atau kredensi untuk ${purpose}.`,
            `Kredensi ini berlaku sejak ${effectiveFrom} sampai dengan ${effectiveTo}.`,
            '',
            'Kredensi ini diberikan kepada:',
            ...members.map((member) => `- ${member}`),
            '',
            'Surat kredensi ini dibuat untuk dipergunakan sebagaimana mestinya.',
          ],
        },
      ],
    };
  }

  private buildCertificateRenderData(params: {
    certificateType: string | null;
    activity: any;
    church: {
      name: string | null;
    } | null;
    documentName: string;
    accountNumber: string;
  }): CertificateRenderData | null {
    switch (params.certificateType) {
      case 'suratKeteranganJemaat':
        return this.buildSuratKeteranganJemaatRenderData(params);
      case 'suratKredensi':
        return this.buildSuratKredensiRenderData(params);
      default:
        return null;
    }
  }

  async getDocuments(query: DocumentListQueryDto) {
    const {
      search,
      churchId,
      skip,
      take,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = query;

    const where: Prisma.DocumentWhereInput = {};

    if (search && search.length >= 3) {
      const keyword = search.toLowerCase();
      where.OR = [
        { accountNumber: { contains: keyword, mode: 'insensitive' } },
      ];
    }

    if (churchId) {
      where.churchId = churchId;
    }

    const [total, documents] = await this.prisma.$transaction([
      this.prisma.document.count({ where }),
      this.prisma.document.findMany({
        where,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },
        include: {
          church: true,
          file: true,
          activity: {
            include: this.getDocumentActivityInclude(),
          },
        },
      }),
    ]);

    const metadataMap = await this.getDocumentMetadataMap(
      documents.map((document) => document.id),
    );

    return {
      message: 'Documents fetched successfully',
      data: documents.map((document) =>
        this.withDocumentMetadata(document, metadataMap.get(document.id)),
      ),
      total,
    };
  }

  async findOne(id: number) {
    const document = await this.prisma.document.findUniqueOrThrow({
      where: { id },
      include: {
        church: true,
        file: true,
        activity: {
          include: this.getDocumentActivityInclude(),
        },
      },
    });
    const metadata = await this.getDocumentMetadata(document.id);
    return {
      message: 'Document fetched successfully',
      data: this.withDocumentMetadata(document, metadata),
    };
  }

  async remove(id: number) {
    await this.prisma.document.delete({
      where: { id },
    });
    return {
      message: 'Document deleted successfully',
    };
  }

  async create(
    createDocumentDto: Prisma.DocumentCreateInput & { activityId?: number },
  ) {
    const payload: any = { ...createDocumentDto };
    if (payload.activityId) {
      payload.activity = { connect: { id: payload.activityId } };
      delete payload.activityId;
    }
    const document = await this.prisma.document.create({
      data: payload,
    });
    return {
      message: 'Document created successfully',
      data: document,
    };
  }

  async update(id: number, updateDocumentDto: Prisma.DocumentUpdateInput) {
    const payload: any = { ...updateDocumentDto };
    const hasCertificateType = Object.prototype.hasOwnProperty.call(
      payload,
      'certificateType',
    );
    const hasCertificateTitle = Object.prototype.hasOwnProperty.call(
      payload,
      'certificateTitle',
    );
    const certificateType = hasCertificateType
      ? payload.certificateType
      : undefined;
    const certificateTitle = hasCertificateTitle
      ? payload.certificateTitle
      : undefined;

    delete payload.certificateType;
    delete payload.certificateTitle;

    const document = await this.prisma.$transaction(async (tx) => {
      const updatedDocument = await tx.document.update({
        where: { id },
        data: payload,
        include: {
          church: true,
          file: true,
          activity: {
            include: this.getDocumentActivityInclude(),
          },
        },
      });

      if (hasCertificateType || hasCertificateTitle) {
        const existingMetadata = await this.getDocumentMetadata(id);
        await this.persistDocumentMetadata(
          id,
          {
            certificateType: hasCertificateType
              ? this.normalizeMetadataValue(certificateType)
              : (existingMetadata?.certificateType ?? null),
            certificateTitle: hasCertificateTitle
              ? this.normalizeMetadataValue(certificateTitle)
              : (existingMetadata?.certificateTitle ?? null),
          },
          tx,
        );
      }

      return updatedDocument;
    });

    const metadata = await this.getDocumentMetadata(document.id);
    return {
      message: 'Document updated successfully',
      data: this.withDocumentMetadata(document, metadata),
    };
  }

  private resolveDocumentInput(value: unknown): DocumentInput {
    return String(value).trim().toUpperCase() === DocumentInput.OUTCOME
      ? DocumentInput.OUTCOME
      : DocumentInput.INCOME;
  }

  private hasAssignedOutcomeAccountNumber(value: string | null | undefined) {
    return (value?.trim().length ?? 0) > 0;
  }

  private toRomanMonth(month: number): string {
    const romanMonths = [
      'I',
      'II',
      'III',
      'IV',
      'V',
      'VI',
      'VII',
      'VIII',
      'IX',
      'X',
      'XI',
      'XII',
    ];
    const romanMonth = romanMonths[month - 1];
    if (!romanMonth) {
      throw new BadRequestException('Invalid document generation month');
    }
    return romanMonth;
  }

  private composeOutcomeAccountNumber(
    prefix: string,
    counter: number,
    issuedAt: Date,
  ): string {
    const normalizedPrefix = prefix.trim();
    if (!normalizedPrefix) {
      throw new BadRequestException(
        'documentPrefixAccountNumber is required for auto-numbered outcome documents',
      );
    }

    return `${normalizedPrefix}/${issuedAt.getFullYear()}/${this.toRomanMonth(
      issuedAt.getMonth() + 1,
    )}/${counter}`;
  }

  async generate(dto: any, user?: any) {
    const churchId = await this.resolveRequesterChurchId(user);

    const inputId = dto?.id;
    const regenerate = dto?.regenerate === true;

    const document =
      typeof inputId === 'number'
        ? await this.prisma.document.findUniqueOrThrow({
            where: { id: inputId },
            include: {
              church: true,
              file: true,
              activity: {
                include: this.getDocumentActivityInclude(),
              },
            },
          })
        : null;

    const persistedMetadata = document?.id
      ? await this.getDocumentMetadata(document.id)
      : null;

    if (document && document.churchId !== churchId) {
      throw new BadRequestException('Invalid church context');
    }

    if (document?.verifyTokenHash && !regenerate) {
      throw new ConflictException('Document already generated');
    }

    if (document) {
      if (!document.activity) {
        throw new BadRequestException('Document is not linked to any activity');
      }

      const approvers = document.activity.approvers ?? [];
      const isApproved =
        approvers.length > 0 &&
        approvers.every(
          (approver) => approver.status === ApprovalStatus.APPROVED,
        );

      if (!isApproved) {
        throw new BadRequestException(
          'Document activity must be approved before generating document',
        );
      }
    }

    const newName = dto?.name != null ? String(dto.name) : '';
    const newAccountNumber =
      dto?.accountNumber != null ? String(dto.accountNumber) : '';
    const resolvedInput = this.resolveDocumentInput(
      document?.input ?? dto?.input,
    );
    const shouldAutoAssignAccountNumber =
      resolvedInput === DocumentInput.OUTCOME;

    if (!document) {
      if (!newName.trim()) {
        throw new BadRequestException('name is required');
      }
      if (!shouldAutoAssignAccountNumber && !newAccountNumber.trim()) {
        throw new BadRequestException('accountNumber is required');
      }
    }

    const requestedCertificateType =
      typeof dto?.certificateType === 'string' &&
      dto.certificateType.trim().length
        ? dto.certificateType.trim()
        : null;
    const requestedCertificateTitle =
      typeof dto?.certificateTitle === 'string' &&
      dto.certificateTitle.trim().length
        ? dto.certificateTitle.trim()
        : null;
    const certificateType =
      requestedCertificateType ?? persistedMetadata?.certificateType ?? null;
    const certificateTitle =
      requestedCertificateTitle ?? persistedMetadata?.certificateTitle ?? null;
    const title = String(
      dto?.title ?? certificateTitle ?? document?.name ?? newName,
    );
    const sections = (
      Array.isArray(dto?.sections) ? dto.sections : []
    ) as any[];
    const normalizedSections: DocumentSection[] = sections
      .map((s) => ({
        title: s?.title != null ? String(s.title) : undefined,
        lines: Array.isArray(s?.lines)
          ? s.lines.map((x: any) => String(x))
          : [],
      }))
      .filter((s) => (s.title && s.title.trim().length) || s.lines.length);

    const publicId = randomUUID();
    const token = randomBytes(32).toString('base64url');
    const verifyTokenHash = this.sha256Hex(token);

    const baseUrl = this.resolvePublicBaseUrl();
    let verificationUrl: string;
    try {
      const u = new URL(`/verify/document/${publicId}`, baseUrl);
      u.searchParams.set('t', token);
      verificationUrl = u.toString();
    } catch {
      throw new BadRequestException('PUBLIC_BASE_URL is invalid');
    }

    const qrPngBuffer = await QRCode.toBuffer(verificationUrl, {
      type: 'png',
      errorCorrectionLevel: 'M',
      margin: 1,
      width: 256,
    });

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

    const logoBuffer = getGmimLogoBuffer();

    const updated = await this.prisma.$transaction(
      async (tx) => {
        const issuedAt = new Date();
        let accountNumber = document?.accountNumber ?? newAccountNumber;
        const shouldAssignOutcomeAccountNumber =
          shouldAutoAssignAccountNumber &&
          (!document ||
            !this.hasAssignedOutcomeAccountNumber(document?.accountNumber));

        if (shouldAssignOutcomeAccountNumber) {
          const updatedChurch = await (tx as any).church.update({
            where: { id: churchId },
            data: {
              documentAccountNumber: {
                increment: 1,
              },
            },
            select: {
              documentAccountNumber: true,
              documentPrefixAccountNumber: true,
            },
          });
          accountNumber = this.composeOutcomeAccountNumber(
            updatedChurch.documentPrefixAccountNumber ?? '',
            updatedChurch.documentAccountNumber,
            issuedAt,
          );
        }

        const created = document
          ? shouldAssignOutcomeAccountNumber
            ? await tx.document.update({
                where: { id: document.id },
                data: {
                  accountNumber,
                },
                include: {
                  church: true,
                  file: true,
                  activity: {
                    include: this.getDocumentActivityInclude(),
                  },
                },
              })
            : document
          : await tx.document.create({
              data: {
                name: newName,
                accountNumber,
                input: resolvedInput,
                church: { connect: { id: churchId } },
              } as any,
              include: {
                church: true,
                file: true,
                activity: {
                  include: this.getDocumentActivityInclude(),
                },
              },
            });

        if (!created.name || !created.name.trim()) {
          throw new BadRequestException('name is required');
        }
        if (!created.accountNumber || !created.accountNumber.trim()) {
          throw new BadRequestException('accountNumber is required');
        }

        const certificateRenderData = certificateType
          ? this.buildCertificateRenderData({
              certificateType,
              activity: created.activity,
              church,
              documentName: created.name,
              accountNumber: created.accountNumber,
            })
          : null;

        const pdfBuffer = await renderPdfSignedDocumentBuffer({
          title,
          subtitle: certificateRenderData?.subtitle,
          name: created.name,
          accountNumber: created.accountNumber,
          metaRows: certificateRenderData?.metaRows,
          sections: certificateRenderData?.sections ?? normalizedSections,
          letterhead: church?.name
            ? buildGmimLetterhead({
                churchName: church.name,
                locationName: church.location?.name,
                phoneNumber: church.phoneNumber,
                email: church.email,
              })
            : undefined,
          logoBuffer,
          qrPngBuffer,
          publicId,
        });

        const fileSha256 = this.sha256Hex(pdfBuffer);
        const sizeInKB = Number((pdfBuffer.length / 1024).toFixed(2));

        const bucket = this.firebaseAdmin.bucket();
        const bucketName = bucket.name as string;

        const now = new Date();
        const stamp = now
          .toISOString()
          .replace(/[-:]/g, '')
          .replace(/\..+$/, '');
        const objectName = `DOCUMENT_${publicId}_${stamp}.pdf`;
        const path = `churches/${churchId}/documents/${objectName}`;
        const contentType = 'application/pdf';

        await bucket.file(path).save(pdfBuffer, {
          contentType,
          metadata: {
            metadata: {
              churchId: String(churchId),
              documentId: String(created.id),
              publicId: String(publicId),
            },
          },
        });

        const file = await tx.fileManager.create({
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

        const updatedDocument = await tx.document.update({
          where: { id: created.id },
          data: {
            fileId: file.id,
            publicId,
            verifyTokenHash,
            fileSha256,
          } as any,
          include: {
            church: true,
            file: true,
            activity: {
              include: this.getDocumentActivityInclude(),
            },
          },
        });

        await this.persistDocumentMetadata(
          created.id,
          {
            certificateType,
            certificateTitle:
              certificateTitle ?? (certificateType ? title : null),
          },
          tx,
        );

        return updatedDocument;
      },
      {
        maxWait: 5000,
        timeout: 30000,
      },
    );

    const metadata = await this.getDocumentMetadata(updated.id);

    return {
      message: 'Document generated',
      data: this.withDocumentMetadata(updated, metadata),
      verificationUrl,
    };
  }
}
