import PDFDocument = require('pdfkit');
import { PassThrough } from 'stream';

export type DocumentLetterhead = {
  title?: string | null;
  line1?: string | null;
  line2?: string | null;
  line3?: string | null;
};

export type DocumentSection = {
  title?: string;
  lines: string[];
};

function renderPdfLetterhead(params: {
  doc: any;
  letterhead?: DocumentLetterhead;
  logoBuffer?: Buffer;
}): void {
  const { doc } = params;

  const headerLines = [
    params.letterhead?.title,
    params.letterhead?.line1,
    params.letterhead?.line2,
    params.letterhead?.line3,
  ].filter((x) => !!x && String(x).trim().length) as string[];

  if (!headerLines.length && !params.logoBuffer?.length) return;

  const headerStartY = doc.y;
  const logoBoxSize = 72;
  let logoRendered = false;

  if (params.logoBuffer?.length) {
    try {
      doc.image(params.logoBuffer, doc.x, headerStartY, {
        fit: [logoBoxSize, logoBoxSize],
      });
      logoRendered = true;
    } catch {}
  }

  const textX = logoRendered ? doc.x + logoBoxSize + 12 : doc.x;
  const textWidth = doc.page.width - doc.page.margins.right - textX;

  if (headerLines.length) {
    doc
      .fontSize(14)
      .fillColor('#000000')
      .text(headerLines[0] ?? '', textX, headerStartY, {
        align: 'left',
        width: textWidth,
      });

    doc.fontSize(10).fillColor('#222222');
    for (const line of headerLines.slice(1)) {
      doc.text(line, textX, doc.y, {
        width: textWidth,
      });
    }
  }

  const contentBottomY = Math.max(
    doc.y,
    headerStartY + (logoRendered ? logoBoxSize : 0),
  );
  doc.y = contentBottomY;

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

function renderQrBlock(params: {
  doc: any;
  qrPngBuffer: Buffer;
  publicId: string;
}): void {
  const { doc } = params;

  const blockPadding = 12;
  const qrSize = 96;
  const blockHeight = Math.max(qrSize, 72) + blockPadding * 2;

  const leftX = doc.page.margins.left;
  const rightX = doc.page.width - doc.page.margins.right;
  const blockWidth = rightX - leftX;

  const y = doc.y;

  doc
    .rect(leftX, y, blockWidth, blockHeight)
    .strokeColor('#DDDDDD')
    .lineWidth(1)
    .stroke();

  const qrX = leftX + blockPadding;
  const qrY = y + blockPadding;

  try {
    doc.image(params.qrPngBuffer, qrX, qrY, {
      width: qrSize,
      height: qrSize,
    });
  } catch (e) {
    doc
      .rect(qrX, qrY, qrSize, qrSize)
      .strokeColor('#FF4D4F')
      .lineWidth(1)
      .stroke();
    doc
      .fontSize(7)
      .fillColor('#FF4D4F')
      .text('QR render failed', qrX + 6, qrY + 6, {
        width: qrSize - 12,
      });
    doc
      .fontSize(6)
      .fillColor('#FF4D4F')
      .text(String((e as any)?.message ?? e ?? ''), qrX + 6, doc.y + 2, {
        width: qrSize - 12,
        height: qrSize - 12,
      });
  }

  const textX = qrX + qrSize + 12;
  const textWidth = rightX - blockPadding - textX;

  doc.fontSize(11).fillColor('#000000').text('Verification', textX, qrY, {
    width: textWidth,
  });

  doc
    .fontSize(9)
    .fillColor('#333333')
    .text('Scan the QR code to verify this document.', textX, doc.y + 4, {
      width: textWidth,
    });

  doc
    .fontSize(9)
    .fillColor('#333333')
    .text(`Verification Code: ${params.publicId}`, textX, doc.y + 4, {
      width: textWidth,
    });

  doc
    .fontSize(8)
    .fillColor('#666666')
    .text(`QR Payload: /verify/document/${params.publicId}`, textX, doc.y + 4, {
      width: textWidth,
    });

  doc.y = y + blockHeight + 12;
}

export async function renderPdfSignedDocumentBuffer(params: {
  title: string;
  name: string;
  accountNumber: string;
  sections: DocumentSection[];
  letterhead?: DocumentLetterhead;
  logoBuffer?: Buffer;
  qrPngBuffer: Buffer;
  publicId: string;
  generatedAt?: Date;
}): Promise<Buffer> {
  const generatedAt = params.generatedAt ?? new Date();

  const doc = new PDFDocument({
    size: 'A4',
    bufferPages: true,
    margins: { top: 48, left: 48, right: 48, bottom: 72 },
    info: {
      Title: params.title,
    },
  });

  const stream = new PassThrough();
  const chunks: Buffer[] = [];

  const finish = new Promise<Buffer>((resolve, reject) => {
    stream.on('data', (chunk) => chunks.push(Buffer.from(chunk)));
    stream.on('end', () => resolve(Buffer.concat(chunks)));
    stream.on('error', reject);
  });

  doc.pipe(stream);

  const renderPageHeader = () => {
    renderPdfLetterhead({
      doc,
      letterhead: params.letterhead,
      logoBuffer: params.logoBuffer,
    });
  };

  renderPageHeader();

  doc.fontSize(18).fillColor('#000000').text(params.title, { align: 'left' });
  doc.moveDown(0.75);

  doc
    .fontSize(11)
    .fillColor('#000000')
    .text(`Name: ${params.name}`, { align: 'left' });
  doc
    .fontSize(11)
    .fillColor('#000000')
    .text(`Account Number: ${params.accountNumber}`, { align: 'left' });

  doc
    .fontSize(9)
    .fillColor('#666666')
    .text(`Generated at: ${generatedAt.toISOString()}`, { align: 'left' });

  doc.moveDown();

  for (const section of params.sections ?? []) {
    if (section.title && section.title.trim().length) {
      doc.fontSize(12).fillColor('#000000').text(section.title);
      doc.moveDown(0.5);
    }

    doc.fontSize(10).fillColor('#222222');
    for (const line of section.lines ?? []) {
      doc.text(String(line ?? ''), {
        align: 'left',
      });
    }

    doc.moveDown();
  }

  const bottomLimit = doc.page.height - doc.page.margins.bottom;
  const blockHeightEstimate = 96 + 12 * 2 + 12;
  if (doc.y + blockHeightEstimate > bottomLimit) {
    doc.addPage();
    doc.y = doc.page.margins.top;
    renderPageHeader();
  }

  renderQrBlock({
    doc,
    qrPngBuffer: params.qrPngBuffer,
    publicId: params.publicId,
  });

  doc.end();

  return await finish;
}
