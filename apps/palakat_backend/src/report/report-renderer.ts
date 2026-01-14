import PDFDocument = require('pdfkit');
import { PassThrough } from 'stream';
import * as ExcelJS from 'exceljs';

export type ReportLetterhead = {
  title?: string | null;
  line1?: string | null;
  line2?: string | null;
  line3?: string | null;
};

export type TableColumnSpec = {
  header: string;
  key: string;
  weight?: number;
  align?: 'left' | 'center' | 'right';
};

export type TableRow = Record<string, unknown>;

export type TableSection = {
  title?: string;
  columns: TableColumnSpec[];
  rows: TableRow[];
};

export type BulletinSection = {
  title?: string;
  lines: string[];
};

function formatGeneratedAtForFooter(date: Date): string {
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

function detectXlsxImageExtension(buffer: Buffer): 'png' | 'jpeg' | undefined {
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
    const leftText = `Generated at: ${formatGeneratedAtForFooter(generatedAt)}`;
    const rightText = `Page ${pageNumber} of ${documentTotalPages} pages`;

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
  letterhead?: ReportLetterhead;
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
    } catch {
      // ignore
    }
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

function renderPdfVerifyBlock(params: {
  doc: any;
  qrPngBuffer: Buffer;
  publicId: string;
  churchName?: string;
  generatedAt: Date;
  totalPages: number;
}): number {
  const { doc } = params;

  const availableWidth =
    doc.page.width - doc.page.margins.left - doc.page.margins.right;

  const padding = 10;
  const qrSize = 96;
  const minTextHeight = 40;
  const boxHeight = Math.max(qrSize, minTextHeight) + padding * 2;

  const x = doc.page.margins.left;
  const y = doc.y;

  doc.save();
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
  const textWidth = Math.max(0, x + availableWidth - padding - textX);

  const churchName = (params.churchName ?? '').trim();
  const generatedLabel = `Generated: ${formatGeneratedAtForFooter(
    params.generatedAt,
  )}`;
  const pagesLabel = `Total pages: ${params.totalPages}`;

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
  doc.text(`Verify: /verify/report/${params.publicId}`, textX, doc.y + 8, {
    width: textWidth,
  });
  doc.text(`Code: ${params.publicId}`, textX, doc.y + 2, {
    width: textWidth,
  });

  doc.restore();
  return boxHeight;
}

function formatPdfCellValue(value: unknown): string {
  if (value == null) return '';
  if (value instanceof Date) return value.toISOString();
  if (typeof value === 'number') return String(value);
  if (typeof value === 'boolean') return value ? 'Yes' : 'No';
  return String(value);
}

function buildColumnWidths(params: {
  pageWidth: number;
  marginsLeft: number;
  marginsRight: number;
  columns: TableColumnSpec[];
}): number[] {
  const availableWidth =
    params.pageWidth - params.marginsLeft - params.marginsRight;

  const weights = params.columns.map((c) =>
    c.weight && c.weight > 0 ? c.weight : 1,
  );
  const total = weights.reduce((a, b) => a + b, 0) || 1;

  return weights.map((w) => (availableWidth * w) / total);
}

export async function renderPdfTableReportBuffer(params: {
  title: string;
  sections: TableSection[];
  letterhead?: ReportLetterhead;
  logoBuffer?: Buffer;
  generatedAt?: Date;
  qrPngBuffer?: Buffer;
  publicId?: string;
  churchName?: string;
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
  doc.moveDown();

  for (const section of params.sections) {
    if (section.title && section.title.trim().length) {
      doc.fontSize(12).fillColor('#000000').text(section.title);
      doc.moveDown(0.5);
    }

    const columns = section.columns;
    const colWidths = buildColumnWidths({
      pageWidth: doc.page.width,
      marginsLeft: doc.page.margins.left,
      marginsRight: doc.page.margins.right,
      columns,
    });

    const padding = 4;
    const headerFontSize = 10;
    const bodyFontSize = 9;

    const renderTableHeader = (y: number) => {
      let x = doc.page.margins.left;

      doc.fontSize(headerFontSize).fillColor('#000000');

      const headerHeight = headerFontSize + padding * 2 + 2;
      for (let i = 0; i < columns.length; i++) {
        const col = columns[i];
        const w = colWidths[i];

        doc.rect(x, y, w, headerHeight).fillAndStroke('#F2F2F2', '#DDDDDD');
        doc.fillColor('#000000').text(col.header, x + padding, y + padding, {
          width: w - padding * 2,
          align: col.align ?? 'left',
        });

        x += w;
      }

      return y + headerHeight;
    };

    let y = doc.y;
    y = renderTableHeader(y);

    doc.fontSize(bodyFontSize).fillColor('#000000');

    for (const row of section.rows) {
      const cells = columns.map((c) => formatPdfCellValue(row[c.key]));

      let rowHeight = bodyFontSize + padding * 2 + 2;
      for (let i = 0; i < columns.length; i++) {
        const w = colWidths[i] - padding * 2;
        const h = doc.heightOfString(cells[i] ?? '', { width: w });
        rowHeight = Math.max(rowHeight, h + padding * 2 + 2);
      }

      const bottomLimit = doc.page.height - doc.page.margins.bottom;
      if (y + rowHeight > bottomLimit) {
        doc.addPage();
        doc.y = doc.page.margins.top;
        renderPageHeader();
        y = doc.y;
        if (section.title && section.title.trim().length) {
          doc.fontSize(12).fillColor('#000000').text(section.title);
          doc.moveDown(0.5);
          y = doc.y;
        }
        y = renderTableHeader(y);
        doc.fontSize(bodyFontSize).fillColor('#000000');
      }

      let x = doc.page.margins.left;
      for (let i = 0; i < columns.length; i++) {
        const col = columns[i];
        const w = colWidths[i];

        doc
          .rect(x, y, w, rowHeight)
          .strokeColor('#DDDDDD')
          .lineWidth(0.5)
          .stroke();

        doc
          .fillColor('#000000')
          .text(cells[i] ?? '', x + padding, y + padding, {
            width: w - padding * 2,
            align: col.align ?? 'left',
          });

        x += w;
      }

      y += rowHeight;
    }

    doc.y = y + 12;
  }

  if (params.qrPngBuffer && params.publicId) {
    const blockHeight = 96 + 10 * 2;
    const bottomLimit = doc.page.height - doc.page.margins.bottom;
    if (doc.y + blockHeight + 12 > bottomLimit) {
      doc.addPage();
      doc.y = doc.page.margins.top;
      renderPageHeader();
    }

    const range =
      typeof doc.bufferedPageRange === 'function'
        ? doc.bufferedPageRange()
        : { start: 0, count: 1 };
    const totalPages = (range.start ?? 0) + (range.count ?? 1);

    const boxHeight = renderPdfVerifyBlock({
      doc,
      qrPngBuffer: params.qrPngBuffer,
      publicId: params.publicId,
      churchName: params.churchName ?? params.letterhead?.title ?? undefined,
      generatedAt,
      totalPages,
    });
    doc.y = doc.y + boxHeight + 12;
  }

  applyPdfFooter({ doc, generatedAt });
  doc.end();

  return await finish;
}

function formatXlsxCellValue(value: unknown): string | number | Date {
  if (value == null) return '';
  if (value instanceof Date) return value;
  if (typeof value === 'number') return value;
  if (typeof value === 'boolean') return value ? 'Yes' : 'No';
  return String(value);
}

export async function renderXlsxTableReportBuffer(params: {
  title: string;
  sections: TableSection[];
  letterhead?: ReportLetterhead;
  logoBuffer?: Buffer;
  generatedAt?: Date;
}): Promise<Buffer> {
  const generatedAt = params.generatedAt ?? new Date();

  const workbook = new ExcelJS.Workbook();
  workbook.creator = 'Palakat';
  workbook.created = generatedAt;

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
      const imageId = workbook.addImage({
        buffer: params.logoBuffer as any,
        extension: logoExt,
      });
      sheet.addImage(imageId, {
        tl: { col: 0, row: 0 },
        ext: { width: 72, height: 72 },
      });
    } catch {
      // ignore
    }
  }

  const titleRow = sheet.addRow([params.title]);
  titleRow.font = { bold: true, size: 16 };

  sheet.addRow([]);

  sheet.headerFooter = {
    oddFooter: `&LGenerated at: ${formatGeneratedAtForFooter(generatedAt)}&RPage &P of &N`,
    evenFooter: `&LGenerated at: ${formatGeneratedAtForFooter(generatedAt)}&RPage &P of &N`,
  };

  for (const section of params.sections) {
    if (section.title && section.title.trim().length) {
      const sectionRow = sheet.addRow([section.title]);
      sectionRow.font = { bold: true, size: 12 };
      sheet.addRow([]);
    }

    const header = section.columns.map((c) => c.header);
    const headerRow = sheet.addRow(header);

    headerRow.eachCell((cell) => {
      cell.font = { bold: true };
      cell.fill = {
        type: 'pattern',
        pattern: 'solid',
        fgColor: { argb: 'FFF2F2F2' },
      };
      cell.border = {
        top: { style: 'thin', color: { argb: 'FFDDDDDD' } },
        left: { style: 'thin', color: { argb: 'FFDDDDDD' } },
        bottom: { style: 'thin', color: { argb: 'FFDDDDDD' } },
        right: { style: 'thin', color: { argb: 'FFDDDDDD' } },
      };
      cell.alignment = { vertical: 'middle' };
    });

    for (const row of section.rows) {
      const values = section.columns.map((c) =>
        formatXlsxCellValue(row[c.key]),
      );
      const r = sheet.addRow(values);
      r.eachCell((cell, colNumber) => {
        const col = section.columns[colNumber - 1];
        cell.border = {
          top: { style: 'thin', color: { argb: 'FFDDDDDD' } },
          left: { style: 'thin', color: { argb: 'FFDDDDDD' } },
          bottom: { style: 'thin', color: { argb: 'FFDDDDDD' } },
          right: { style: 'thin', color: { argb: 'FFDDDDDD' } },
        };
        cell.alignment = {
          vertical: 'top',
          horizontal: col.align ?? 'left',
          wrapText: true,
        };
      });
    }

    sheet.addRow([]);
  }

  const buffer = (await workbook.xlsx.writeBuffer()) as ArrayBuffer;
  return Buffer.from(buffer);
}

export async function renderPdfBulletinReportBuffer(params: {
  title: string;
  sections: BulletinSection[];
  letterhead?: ReportLetterhead;
  logoBuffer?: Buffer;
  generatedAt?: Date;
  qrPngBuffer?: Buffer;
  publicId?: string;
  churchName?: string;
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
  doc.moveDown();

  const ensureSpace = (height: number) => {
    const bottomLimit = doc.page.height - doc.page.margins.bottom;
    if (doc.y + height > bottomLimit) {
      doc.addPage();
      doc.y = doc.page.margins.top;
      renderPageHeader();
    }
  };

  for (const section of params.sections) {
    if (section.title && section.title.trim().length) {
      ensureSpace(24);
      doc.fontSize(12).fillColor('#000000').text(section.title);
      doc.moveDown(0.5);
    }

    doc.fontSize(11).fillColor('#000000');
    for (const line of section.lines) {
      ensureSpace(16);
      doc.text(line);
    }

    doc.moveDown();
  }

  if (params.qrPngBuffer && params.publicId) {
    const blockHeight = 96 + 10 * 2;
    ensureSpace(blockHeight + 12);

    const range =
      typeof doc.bufferedPageRange === 'function'
        ? doc.bufferedPageRange()
        : { start: 0, count: 1 };
    const totalPages = (range.start ?? 0) + (range.count ?? 1);

    const boxHeight = renderPdfVerifyBlock({
      doc,
      qrPngBuffer: params.qrPngBuffer,
      publicId: params.publicId,
      churchName: params.churchName ?? params.letterhead?.title ?? undefined,
      generatedAt,
      totalPages,
    });
    doc.y = doc.y + boxHeight + 12;
  }

  applyPdfFooter({ doc, generatedAt });
  doc.end();
  return await finish;
}

export async function renderXlsxBulletinReportBuffer(params: {
  title: string;
  sections: BulletinSection[];
  letterhead?: ReportLetterhead;
  logoBuffer?: Buffer;
  generatedAt?: Date;
}): Promise<Buffer> {
  const generatedAt = params.generatedAt ?? new Date();

  const workbook = new ExcelJS.Workbook();
  workbook.creator = 'Palakat';
  workbook.created = generatedAt;

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
      const imageId = workbook.addImage({
        buffer: params.logoBuffer as any,
        extension: logoExt,
      });
      sheet.addImage(imageId, {
        tl: { col: 0, row: 0 },
        ext: { width: 72, height: 72 },
      });
    } catch {
      // ignore
    }
  }

  const titleRow = sheet.addRow([params.title]);
  titleRow.font = { bold: true, size: 16 };

  sheet.addRow([]);

  sheet.headerFooter = {
    oddFooter: `&LGenerated at: ${formatGeneratedAtForFooter(generatedAt)}&RPage &P of &N pages`,
    evenFooter: `&LGenerated at: ${formatGeneratedAtForFooter(generatedAt)}&RPage &P of &N pages`,
  };

  for (const section of params.sections) {
    if (section.title && section.title.trim().length) {
      const sectionRow = sheet.addRow([section.title]);
      sectionRow.font = { bold: true, size: 12 };
    }

    for (const line of section.lines) {
      sheet.addRow([line]);
    }

    sheet.addRow([]);
  }

  const buffer = (await workbook.xlsx.writeBuffer()) as ArrayBuffer;
  return Buffer.from(buffer);
}
