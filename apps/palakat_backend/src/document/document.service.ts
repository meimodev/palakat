import {
  BadRequestException,
  ConflictException,
  Injectable,
} from '@nestjs/common';
import { createHash, randomBytes, randomUUID } from 'crypto';
import { DocumentInput, Prisma } from '../generated/prisma/client';
import { PrismaService } from '../prisma.service';
import { DocumentListQueryDto } from './dto/document-list.dto';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import * as QRCode from 'qrcode';
import {
  renderPdfSignedDocumentBuffer,
  type DocumentSection,
} from './document-renderer';
import { buildGmimLetterhead, getGmimLogoBuffer } from 'src/utils';

type DocumentMetadataRow = {
  id: number;
  certificateType: string | null;
  certificateTitle: string | null;
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
          activity: true,
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
        activity: true,
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
          activity: true,
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
            include: { church: true, file: true },
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
                include: { church: true, file: true },
              })
            : document
          : await tx.document.create({
              data: {
                name: newName,
                accountNumber,
                input: resolvedInput,
                church: { connect: { id: churchId } },
              } as any,
              include: { church: true, file: true },
            });

        if (!created.name || !created.name.trim()) {
          throw new BadRequestException('name is required');
        }
        if (!created.accountNumber || !created.accountNumber.trim()) {
          throw new BadRequestException('accountNumber is required');
        }

        const pdfBuffer = await renderPdfSignedDocumentBuffer({
          title,
          name: created.name,
          accountNumber: created.accountNumber,
          sections: normalizedSections,
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
          include: { church: true, file: true },
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
