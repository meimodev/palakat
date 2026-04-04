import * as PDFDocument from 'pdfkit';
import { PassThrough } from 'stream';

const BRAND_PRIMARY_HEX = '#921573';
const BRAND_SECONDARY_HEX = '#6B1D84';
const BRAND_BORDER_HEX = '#E5C7DD';
const DOCUMENT_PANEL_HEX = '#FBF7FA';
const DOCUMENT_MUTED_HEX = '#64748B';

export type DocumentLetterhead = {
  title?: string | null;
  line1?: string | null;
  line2?: string | null;
  line3?: string | null;
};

export type DocumentMetaRow = {
  label: string;
  value: string;
};

export type DocumentSubTitle = {
  label: string;
  value: string;
};

export type DocumentSection = {
  title?: string;
  lines: string[];
};

function pad2(value: number): string {
  return String(value).padStart(2, '0');
}

function formatDocumentDateTime(date: Date): string {
  return `${pad2(date.getDate())}/${pad2(date.getMonth() + 1)}/${date.getFullYear()} ${pad2(date.getHours())}:${pad2(date.getMinutes())}`;
}

function applyPdfFooter(params: { doc: any; generatedAt: Date }): void {
  const { doc, generatedAt } = params;
  const range =
    typeof doc.bufferedPageRange === 'function'
      ? doc.bufferedPageRange()
      : { start: 0, count: 1 };

  const start = range.start ?? 0;
  const count = range.count ?? 1;
  const documentTotalPages = start + count;

  for (let pageIndex = start; pageIndex < start + count; pageIndex++) {
    if (typeof doc.switchToPage === 'function') {
      doc.switchToPage(pageIndex);
    }

    const pageNumber = pageIndex + 1;
    const leftText = `Dibuat pada: ${formatDocumentDateTime(generatedAt)}`;
    const rightText = `Halaman ${pageNumber} dari ${documentTotalPages}`;

    const leftX = doc.page.margins.left;
    const availableWidth =
      doc.page.width - doc.page.margins.left - doc.page.margins.right;
    const footerY = doc.page.height - doc.page.margins.bottom + 20;

    doc.save();

    doc.fontSize(9).fillColor('#666666');
    const lineHeight = doc.currentLineHeight(true);
    const gap = 12;
    const rightWidth = doc.widthOfString(rightText);
    const leftWidth = Math.max(0, availableWidth - rightWidth - gap);

    doc.text(leftText, leftX, footerY, {
      width: leftWidth,
      height: lineHeight,
      align: 'left',
      lineBreak: false,
      ellipsis: true,
    });

    doc.text(rightText, leftX + availableWidth - rightWidth, footerY, {
      width: rightWidth,
      height: lineHeight,
      align: 'left',
      lineBreak: false,
    });

    doc.restore();
  }
}

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
      .fillColor(BRAND_PRIMARY_HEX)
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
    .strokeColor(BRAND_BORDER_HEX)
    .lineWidth(1)
    .stroke();
  doc.moveDown();
}

function renderDocumentTitleBlock(params: {
  doc: any;
  title: string;
  subtitle?: DocumentSubTitle | null;
}): void {
  const { doc } = params;
  const contentWidth =
    doc.page.width - doc.page.margins.left - doc.page.margins.right;

  doc.font('Helvetica-Bold');
  doc
    .fontSize(20)
    .fillColor(BRAND_PRIMARY_HEX)
    .text(params.title, doc.page.margins.left, doc.y, {
      width: contentWidth,
      align: 'center',
      lineGap: 3,
    });

  if (params.subtitle?.value?.trim()) {
    doc.moveDown(0.25);
    doc.font('Helvetica').fontSize(10.5).fillColor(DOCUMENT_MUTED_HEX);
    doc.text(
      `${params.subtitle.label}: ${params.subtitle.value}`,
      doc.page.margins.left,
      doc.y,
      {
        width: contentWidth,
        align: 'center',
        lineGap: 1.5,
      },
    );
  }

  const dividerWidth = Math.min(220, contentWidth * 0.44);
  const dividerX = doc.page.margins.left + (contentWidth - dividerWidth) / 2;
  const dividerY = doc.y + 8;

  doc
    .moveTo(dividerX, dividerY)
    .lineTo(dividerX + dividerWidth, dividerY)
    .strokeColor(BRAND_BORDER_HEX)
    .lineWidth(1)
    .stroke();

  doc.moveDown(0.8);
  doc.x = doc.page.margins.left;
}

function renderMetaTable(params: {
  doc: any;
  metaRows: DocumentMetaRow[];
}): void {
  const { doc } = params;
  const contentWidth =
    doc.page.width - doc.page.margins.left - doc.page.margins.right;

  const panelPaddingX = 14;
  const panelPaddingY = 12;
  const rowGap = 8;
  const innerWidth = Math.max(0, contentWidth - panelPaddingX * 2);
  const labelWidth = Math.min(132, Math.floor(innerWidth * 0.34));
  const valueWidth = Math.max(0, innerWidth - labelWidth - 10);

  const measuredRows = params.metaRows.map((row) => {
    doc.font('Helvetica').fontSize(10);
    const labelHeight = doc.heightOfString(row.label, {
      width: labelWidth,
      align: 'left',
    });
    doc.font('Helvetica').fontSize(10.5);
    const valueHeight = doc.heightOfString(row.value, {
      width: valueWidth,
      align: 'left',
    });

    return {
      row,
      rowHeight: Math.max(labelHeight, valueHeight),
    };
  });

  const panelHeight =
    panelPaddingY * 2 +
    measuredRows.reduce((sum, item) => sum + item.rowHeight, 0) +
    rowGap * Math.max(0, measuredRows.length - 1);

  const panelX = doc.page.margins.left;
  const panelY = doc.y;

  doc.save();
  doc
    .roundedRect(panelX, panelY, contentWidth, panelHeight, 12)
    .fillAndStroke(DOCUMENT_PANEL_HEX, BRAND_BORDER_HEX);
  doc.restore();

  let cursorY = panelY + panelPaddingY;
  for (const item of measuredRows) {
    const startY = cursorY;

    doc.font('Helvetica').fontSize(10).fillColor(DOCUMENT_MUTED_HEX);
    doc.text(item.row.label, panelX + panelPaddingX, startY, {
      width: labelWidth,
      align: 'left',
      lineGap: 1,
    });

    doc.font('Helvetica-Bold').fontSize(10.5).fillColor('#111827');
    doc.text(
      `: ${item.row.value}`,
      doc.page.margins.left + labelWidth,
      startY,
      {
        width: valueWidth,
        align: 'left',
        lineGap: 1,
      },
    );

    cursorY += item.rowHeight + rowGap;
  }

  doc.y = panelY + panelHeight + 4;
  doc.x = doc.page.margins.left;
}

function renderDocumentSections(params: {
  doc: any;
  sections: DocumentSection[];
}): void {
  const { doc } = params;
  const contentWidth =
    doc.page.width - doc.page.margins.left - doc.page.margins.right;

  for (const section of params.sections ?? []) {
    if (section.title && section.title.trim().length) {
      doc.font('Helvetica-Bold');
      doc
        .fontSize(12)
        .fillColor(BRAND_SECONDARY_HEX)
        .text(section.title, doc.page.margins.left, doc.y, {
          width: contentWidth,
          align: 'left',
          lineGap: 1.5,
        });
      doc.moveDown(0.3);
    }

    doc.font('Helvetica').fontSize(10.75).fillColor('#1F2937');

    let previousWasBlank = false;
    for (const line of section.lines ?? []) {
      const normalizedLine = String(line ?? '');
      const isBlank = !normalizedLine.trim().length;

      if (isBlank) {
        if (!previousWasBlank) {
          doc.moveDown(0.45);
        }
        previousWasBlank = true;
        continue;
      }

      if (/^[-•]\s*/.test(normalizedLine)) {
        doc.text(
          normalizedLine.replace(/^[-•]\s*/, '• '),
          doc.page.margins.left,
          doc.y,
          {
            width: contentWidth,
            indent: 16,
            paragraphGap: 3,
            lineGap: 2.25,
            align: 'left',
          },
        );
      } else {
        doc.text(normalizedLine, doc.page.margins.left, doc.y, {
          width: contentWidth,
          align: 'justify',
          paragraphGap: 4,
          lineGap: 2.25,
        });
      }

      previousWasBlank = false;
    }

    doc.moveDown(0.85);
  }

  doc.x = doc.page.margins.left;
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

  doc.save();
  doc
    .roundedRect(leftX, y, blockWidth, blockHeight, 12)
    .fillAndStroke(DOCUMENT_PANEL_HEX, BRAND_BORDER_HEX);
  doc.restore();

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

  doc
    .font('Helvetica-Bold')
    .fontSize(11.5)
    .fillColor(BRAND_PRIMARY_HEX)
    .text('Verifikasi Dokumen', textX, qrY, {
      width: textWidth,
    });

  doc
    .font('Helvetica')
    .fontSize(8.75)
    .fillColor(DOCUMENT_MUTED_HEX)
    .text('Pindai kode QR untuk memverifikasi dokumen ini.', textX, doc.y + 4, {
      width: textWidth,
    });

  doc
    .font('Helvetica-Bold')
    .fontSize(8.75)
    .fillColor('#334155')
    .text(`Kode Verifikasi: ${params.publicId}`, textX, doc.y + 4, {
      width: textWidth,
    });

  doc
    .font('Helvetica')
    .fontSize(8)
    .fillColor('#475569')
    .text(
      `Tautan Verifikasi: /verify/document/${params.publicId}`,
      textX,
      doc.y + 4,
      {
        width: textWidth,
      },
    );

  doc.y = y + blockHeight + 12;
}

export async function renderPdfSignedDocumentBuffer(params: {
  title: string;
  subtitle?: DocumentSubTitle | null;
  name: string;
  accountNumber: string;
  metaRows?: DocumentMetaRow[];
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

  renderDocumentTitleBlock({
    doc,
    title: params.title,
    subtitle: params.subtitle,
  });

  const metaRows =
    params.metaRows && params.metaRows.length > 0
      ? params.metaRows
      : [
          { label: 'Nama Dokumen', value: params.name },
          { label: 'Nomor Dokumen', value: params.accountNumber },
          {
            label: 'Dibuat pada',
            value: formatDocumentDateTime(generatedAt),
          },
        ];

  doc.moveDown(0.2);
  renderMetaTable({ doc, metaRows });

  doc.moveDown(0.5);
  doc.x = doc.page.margins.left;
  renderDocumentSections({ doc, sections: params.sections ?? [] });

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

  applyPdfFooter({ doc, generatedAt });

  doc.end();

  return await finish;
}
