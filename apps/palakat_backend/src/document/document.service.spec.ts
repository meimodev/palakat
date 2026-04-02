import { Test, TestingModule } from '@nestjs/testing';
import * as QRCode from 'qrcode';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import { DocumentInput } from '../generated/prisma/client';
import { PrismaService } from '../prisma.service';
import { renderPdfSignedDocumentBuffer } from './document-renderer';
import { DocumentService } from './document.service';

jest.mock('./document-renderer', () => ({
  renderPdfSignedDocumentBuffer: jest.fn(),
}));

jest.mock(
  'src/utils',
  () => ({
    buildGmimLetterhead: jest.fn(() => ({
      title: 'GEREJA MASEHI INJILI di MINAHASA',
      line1: 'Jemaat GMIM Test Church',
      line2: 'Manado 0431-123456 test@example.com',
    })),
    getGmimLogoBuffer: jest.fn(() => Buffer.from('logo')),
  }),
  { virtual: true },
);

jest.mock('qrcode', () => ({
  toBuffer: jest.fn(),
}));

describe('DocumentService', () => {
  let service: DocumentService;

  const mockPrismaService = {
    membership: {
      findUnique: jest.fn(),
    },
    document: {
      findUniqueOrThrow: jest.fn(),
    },
    church: {
      findUnique: jest.fn(),
    },
    $queryRaw: jest.fn(),
    $transaction: jest.fn(),
  };

  const save = jest.fn();
  const mockFirebaseAdminService = {
    bucket: jest.fn(() => ({
      name: 'test-bucket',
      file: jest.fn(() => ({
        save,
      })),
    })),
  };

  const mockedQrCodeToBuffer = QRCode.toBuffer as jest.Mock;
  const mockedRenderPdfSignedDocumentBuffer =
    renderPdfSignedDocumentBuffer as jest.Mock;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DocumentService,
        { provide: PrismaService, useValue: mockPrismaService },
        { provide: FirebaseAdminService, useValue: mockFirebaseAdminService },
      ],
    }).compile();

    service = module.get<DocumentService>(DocumentService);

    jest.clearAllMocks();

    process.env.PUBLIC_BASE_URL = 'http://localhost:3000';
    jest.useFakeTimers().setSystemTime(new Date('2026-04-01T08:00:00.000Z'));

    mockedQrCodeToBuffer.mockResolvedValue(Buffer.from('qr-code'));
    mockedRenderPdfSignedDocumentBuffer.mockResolvedValue(Buffer.from('pdf'));
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('assigns composed outcome account numbers for newly generated outcome documents', async () => {
    const createdDocument = {
      id: 7,
      name: 'Surat Keterangan Jemaat',
      churchId: 1,
      accountNumber: 'GMIM-MANADO/2026/IV/43',
      input: DocumentInput.OUTCOME,
      church: { id: 1 },
      file: null,
    };

    const updatedDocument = {
      ...createdDocument,
      fileId: 9,
      publicId: 'generated-public-id',
      verifyTokenHash: 'new-token-hash',
      fileSha256: 'generated-file-sha',
    };

    const tx = {
      church: {
        update: jest.fn().mockResolvedValue({
          documentAccountNumber: 43,
          documentPrefixAccountNumber: 'GMIM-MANADO',
        }),
      },
      document: {
        update: jest.fn().mockResolvedValue(updatedDocument),
        create: jest.fn().mockResolvedValue(createdDocument),
      },
      fileManager: {
        create: jest.fn().mockResolvedValue({ id: 9 }),
      },
      $executeRaw: jest.fn().mockResolvedValue(1),
    };

    mockPrismaService.membership.findUnique.mockResolvedValue({ churchId: 1 });
    mockPrismaService.church.findUnique.mockResolvedValue({
      name: 'GMIM Test Church',
      phoneNumber: '0431-123456',
      email: 'test@example.com',
      location: { name: 'Manado' },
    });
    mockPrismaService.$queryRaw.mockResolvedValueOnce([
      {
        id: 7,
        certificateType: 'suratKeteranganJemaat',
        certificateTitle: 'Surat Keterangan Jemaat',
      },
    ]);
    mockPrismaService.$transaction.mockImplementation(async (callback) =>
      callback(tx),
    );

    const result = await service.generate(
      {
        name: 'Surat Keterangan Jemaat',
        input: DocumentInput.OUTCOME,
        certificateType: 'suratKeteranganJemaat',
        certificateTitle: 'Surat Keterangan Jemaat',
      },
      { userId: 10 },
    );

    expect(tx.church.update).toHaveBeenCalledTimes(1);
    expect(tx.document.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          name: 'Surat Keterangan Jemaat',
          accountNumber: 'GMIM-MANADO/2026/IV/43',
          input: DocumentInput.OUTCOME,
        }),
        include: { church: true, file: true },
      }),
    );
    expect(mockedRenderPdfSignedDocumentBuffer).toHaveBeenCalledWith(
      expect.objectContaining({
        accountNumber: 'GMIM-MANADO/2026/IV/43',
        name: 'Surat Keterangan Jemaat',
      }),
    );
    expect(result.data.accountNumber).toBe('GMIM-MANADO/2026/IV/43');
  });

  it('preserves existing outcome account numbers when regenerating numbered documents', async () => {
    const existingDocument = {
      id: 5,
      name: 'Surat Kredensi',
      churchId: 1,
      accountNumber: '42',
      input: DocumentInput.OUTCOME,
      verifyTokenHash: 'existing-token-hash',
      church: { id: 1 },
      file: null,
    };

    const updatedDocument = {
      ...existingDocument,
      fileId: 9,
      publicId: 'generated-public-id',
      verifyTokenHash: 'new-token-hash',
      fileSha256: 'generated-file-sha',
    };

    const tx = {
      church: {
        update: jest.fn(),
      },
      document: {
        update: jest.fn().mockResolvedValue(updatedDocument),
        create: jest.fn(),
      },
      fileManager: {
        create: jest.fn().mockResolvedValue({ id: 9 }),
      },
      $executeRaw: jest.fn().mockResolvedValue(1),
    };

    mockPrismaService.membership.findUnique.mockResolvedValue({ churchId: 1 });
    mockPrismaService.document.findUniqueOrThrow.mockResolvedValue(
      existingDocument,
    );
    mockPrismaService.$queryRaw
      .mockResolvedValueOnce([
        {
          id: 5,
          certificateType: 'suratKredensi',
          certificateTitle: 'Surat Kredensi',
        },
      ])
      .mockResolvedValueOnce([
        {
          id: 5,
          certificateType: 'suratKredensi',
          certificateTitle: 'Surat Kredensi',
        },
      ]);
    mockPrismaService.church.findUnique.mockResolvedValue({
      name: 'GMIM Test Church',
      phoneNumber: '0431-123456',
      email: 'test@example.com',
      location: { name: 'Manado' },
    });
    mockPrismaService.$transaction.mockImplementation(async (callback) =>
      callback(tx),
    );

    const result = await service.generate(
      { id: 5, regenerate: true },
      { userId: 10 },
    );

    expect(tx.church.update).not.toHaveBeenCalled();
    expect(tx.document.create).not.toHaveBeenCalled();
    expect(mockedRenderPdfSignedDocumentBuffer).toHaveBeenCalledWith(
      expect.objectContaining({
        accountNumber: '42',
        name: 'Surat Kredensi',
      }),
    );
    expect(tx.document.update).toHaveBeenCalledTimes(1);
    expect(tx.document.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: 5 },
        data: expect.objectContaining({
          fileId: 9,
          publicId: expect.any(String),
          verifyTokenHash: expect.any(String),
          fileSha256: expect.any(String),
        }),
        include: { church: true, file: true },
      }),
    );
    expect(
      tx.document.update.mock.calls[0][0].data.accountNumber,
    ).toBeUndefined();
    expect(result.data.accountNumber).toBe('42');
  });
});
