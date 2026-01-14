import { Controller, Get, Header, Param, Query, Res } from '@nestjs/common';
import { createHash, timingSafeEqual } from 'crypto';
import type { Response } from 'express';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import { PrismaService } from '../prisma.service';

function sha256Hex(input: string): string {
  return createHash('sha256').update(input).digest('hex');
}

function safeEqualHex(a: string, b: string): boolean {
  const aBuf = Buffer.from(a, 'hex');
  const bBuf = Buffer.from(b, 'hex');
  if (aBuf.length !== bBuf.length) return false;
  return timingSafeEqual(aBuf, bBuf);
}

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

@Controller('verify')
export class VerifyController {
  constructor(
    private readonly prisma: PrismaService,
    private readonly firebaseAdmin: FirebaseAdminService,
  ) {}

  @Get('document/:publicId')
  @Header('Content-Type', 'text/html; charset=utf-8')
  async verifyDocument(
    @Param('publicId') publicId: string,
    @Query('t') token?: string,
  ): Promise<string> {
    const now = new Date();

    const htmlShell = (params: {
      title: string;
      status: 'valid' | 'invalid' | 'revoked' | 'not_found' | 'error';
      bodyHtml: string;
    }) => {
      const statusColor =
        params.status === 'valid'
          ? '#16a34a'
          : params.status === 'revoked'
            ? '#f97316'
            : params.status === 'not_found'
              ? '#6b7280'
              : '#dc2626';

      return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>${escapeHtml(params.title)}</title>
  <style>
    body { font-family: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif; margin: 0; background: #f8fafc; color: #0f172a; }
    .container { max-width: 720px; margin: 40px auto; padding: 0 16px; }
    .card { background: #ffffff; border: 1px solid #e5e7eb; border-radius: 12px; box-shadow: 0 1px 2px rgba(0,0,0,0.05); overflow: hidden; }
    .header { padding: 20px 20px 12px 20px; border-bottom: 1px solid #e5e7eb; }
    .title { font-size: 18px; font-weight: 700; margin: 0; }
    .subtitle { font-size: 12px; color: #475569; margin: 6px 0 0 0; }
    .status { display: inline-block; margin-top: 12px; padding: 6px 10px; border-radius: 999px; font-size: 12px; font-weight: 700; color: white; background: ${statusColor}; }
    .content { padding: 20px; }
    .kv { display: grid; grid-template-columns: 160px 1fr; gap: 8px 12px; }
    .k { color: #64748b; font-size: 12px; }
    .v { color: #0f172a; font-size: 12px; word-break: break-word; }
    .note { margin-top: 16px; font-size: 12px; color: #475569; }
  </style>
</head>
<body>
  <div class="container">
    <div class="card">
      <div class="header">
        <p class="title">${escapeHtml(params.title)}</p>
        <p class="subtitle">Verified at: ${escapeHtml(now.toISOString())}</p>
        <span class="status">${escapeHtml(params.status.toUpperCase().replace('_', ' '))}</span>
      </div>
      <div class="content">
        ${params.bodyHtml}
      </div>
    </div>
  </div>
</body>
</html>`;
    };

    if (!publicId || !publicId.trim()) {
      return htmlShell({
        title: 'Invalid verification link',
        status: 'invalid',
        bodyHtml: `<div class="note">Invalid verification link.</div>`,
      });
    }

    if (!token || !token.trim()) {
      return htmlShell({
        title: 'Verification token missing',
        status: 'invalid',
        bodyHtml: `<div class="note">The verification token is missing.</div>`,
      });
    }

    try {
      const doc = await (this.prisma as any).document.findUnique({
        where: { publicId },
        include: {
          church: true,
        },
      });

      if (!doc) {
        return htmlShell({
          title: 'Document not found',
          status: 'not_found',
          bodyHtml: `<div class="note">No document exists for this verification code.</div>`,
        });
      }

      const tokenHash = sha256Hex(token);
      const expected = doc.verifyTokenHash as string | null | undefined;

      if (!expected || expected.length !== tokenHash.length) {
        return htmlShell({
          title: 'Invalid verification token',
          status: 'invalid',
          bodyHtml: `<div class="note">The verification token is invalid.</div>`,
        });
      }

      const ok = safeEqualHex(expected, tokenHash);

      if (!ok) {
        return htmlShell({
          title: 'Invalid verification token',
          status: 'invalid',
          bodyHtml: `<div class="note">The verification token is invalid.</div>`,
        });
      }

      if (doc.revokedAt) {
        return htmlShell({
          title: 'Document revoked',
          status: 'revoked',
          bodyHtml: `
<div class="kv">
  <div class="k">Document Name</div><div class="v">${escapeHtml(String(doc.name ?? ''))}</div>
  <div class="k">Account Number</div><div class="v">${escapeHtml(String(doc.accountNumber ?? ''))}</div>
  <div class="k">Church</div><div class="v">${escapeHtml(String(doc.church?.name ?? ''))}</div>
  <div class="k">Revoked At</div><div class="v">${escapeHtml(new Date(doc.revokedAt).toISOString())}</div>
  <div class="k">Reason</div><div class="v">${escapeHtml(String(doc.revokedReason ?? '-'))}</div>
</div>
<div class="note">This document was revoked and should not be considered valid.</div>`,
        });
      }

      return htmlShell({
        title: 'Document verified',
        status: 'valid',
        bodyHtml: `
<div class="kv">
  <div class="k">Document Name</div><div class="v">${escapeHtml(String(doc.name ?? ''))}</div>
  <div class="k">Account Number</div><div class="v">${escapeHtml(String(doc.accountNumber ?? ''))}</div>
  <div class="k">Input</div><div class="v">${escapeHtml(String(doc.input ?? ''))}</div>
  <div class="k">Church</div><div class="v">${escapeHtml(String(doc.church?.name ?? ''))}</div>
  <div class="k">Issued At</div><div class="v">${escapeHtml(new Date(doc.createdAt).toISOString())}</div>
  <div class="k">Verification Code</div><div class="v">${escapeHtml(String(doc.publicId ?? ''))}</div>
</div>
<div class="note">This verification confirms the document exists in the system and has not been revoked.</div>`,
      });
    } catch {
      return htmlShell({
        title: 'Verification error',
        status: 'error',
        bodyHtml: `<div class="note">An unexpected error occurred during verification.</div>`,
      });
    }
  }

  @Get('report/:publicId')
  @Header('Content-Type', 'text/html; charset=utf-8')
  async verifyReport(
    @Param('publicId') publicId: string,
    @Query('t') token?: string,
  ): Promise<string> {
    const now = new Date();

    const htmlShell = (params: {
      title: string;
      status: 'valid' | 'invalid' | 'revoked' | 'not_found' | 'error';
      bodyHtml: string;
    }) => {
      const statusColor =
        params.status === 'valid'
          ? '#16a34a'
          : params.status === 'revoked'
            ? '#f97316'
            : params.status === 'not_found'
              ? '#6b7280'
              : '#dc2626';

      return `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>${escapeHtml(params.title)}</title>
  <style>
    body { font-family: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif; margin: 0; background: #f8fafc; color: #0f172a; }
    .container { max-width: 720px; margin: 40px auto; padding: 0 16px; }
    .card { background: #ffffff; border: 1px solid #e5e7eb; border-radius: 12px; box-shadow: 0 1px 2px rgba(0,0,0,0.05); overflow: hidden; }
    .header { padding: 20px 20px 12px 20px; border-bottom: 1px solid #e5e7eb; }
    .title { font-size: 18px; font-weight: 700; margin: 0; }
    .subtitle { font-size: 12px; color: #475569; margin: 6px 0 0 0; }
    .status { display: inline-block; margin-top: 12px; padding: 6px 10px; border-radius: 999px; font-size: 12px; font-weight: 700; color: white; background: ${statusColor}; }
    .content { padding: 20px; }
    .kv { display: grid; grid-template-columns: 160px 1fr; gap: 8px 12px; }
    .k { color: #64748b; font-size: 12px; }
    .v { color: #0f172a; font-size: 12px; word-break: break-word; }
    .note { margin-top: 16px; font-size: 12px; color: #475569; }
    .actions { margin-top: 18px; }
    .btn { display: inline-block; background: #0f172a; color: #ffffff; text-decoration: none; padding: 10px 12px; border-radius: 10px; font-size: 12px; font-weight: 700; }
    .btn:hover { opacity: 0.92; }
  </style>
</head>
<body>
  <div class="container">
    <div class="card">
      <div class="header">
        <p class="title">${escapeHtml(params.title)}</p>
        <p class="subtitle">Verified at: ${escapeHtml(now.toISOString())}</p>
        <span class="status">${escapeHtml(params.status.toUpperCase().replace('_', ' '))}</span>
      </div>
      <div class="content">
        ${params.bodyHtml}
      </div>
    </div>
  </div>
</body>
</html>`;
    };

    if (!publicId || !publicId.trim()) {
      return htmlShell({
        title: 'Invalid verification link',
        status: 'invalid',
        bodyHtml: `<div class="note">Invalid verification link.</div>`,
      });
    }

    if (!token || !token.trim()) {
      return htmlShell({
        title: 'Verification token missing',
        status: 'invalid',
        bodyHtml: `<div class="note">The verification token is missing.</div>`,
      });
    }

    try {
      const report = await (this.prisma as any).report.findUnique({
        where: { publicId },
        include: {
          church: true,
          file: true,
        },
      });

      if (!report) {
        return htmlShell({
          title: 'Report not found',
          status: 'not_found',
          bodyHtml: `<div class="note">No report exists for this verification code.</div>`,
        });
      }

      const tokenHash = sha256Hex(token);
      const expected = report.verifyTokenHash as string | null | undefined;

      if (!expected || expected.length !== tokenHash.length) {
        return htmlShell({
          title: 'Invalid verification token',
          status: 'invalid',
          bodyHtml: `<div class="note">The verification token is invalid.</div>`,
        });
      }

      const ok = safeEqualHex(expected, tokenHash);

      if (!ok) {
        return htmlShell({
          title: 'Invalid verification token',
          status: 'invalid',
          bodyHtml: `<div class="note">The verification token is invalid.</div>`,
        });
      }

      if (report.revokedAt) {
        return htmlShell({
          title: 'Report revoked',
          status: 'revoked',
          bodyHtml: `
<div class="kv">
  <div class="k">Report Name</div><div class="v">${escapeHtml(String(report.name ?? ''))}</div>
  <div class="k">Type</div><div class="v">${escapeHtml(String(report.type ?? ''))}</div>
  <div class="k">Format</div><div class="v">${escapeHtml(String(report.format ?? ''))}</div>
  <div class="k">Church</div><div class="v">${escapeHtml(String(report.church?.name ?? ''))}</div>
  <div class="k">Revoked At</div><div class="v">${escapeHtml(new Date(report.revokedAt).toISOString())}</div>
  <div class="k">Reason</div><div class="v">${escapeHtml(String(report.revokedReason ?? '-'))}</div>
  <div class="k">Verification Code</div><div class="v">${escapeHtml(String(report.publicId ?? ''))}</div>
</div>
<div class="note">This report was revoked and should not be considered valid.</div>`,
        });
      }

      const downloadHref = `/verify/report/${encodeURIComponent(
        String(report.publicId ?? publicId),
      )}/download?t=${encodeURIComponent(token)}`;

      return htmlShell({
        title: 'Report verified',
        status: 'valid',
        bodyHtml: `
<div class="kv">
  <div class="k">Report Name</div><div class="v">${escapeHtml(String(report.name ?? ''))}</div>
  <div class="k">Type</div><div class="v">${escapeHtml(String(report.type ?? ''))}</div>
  <div class="k">Format</div><div class="v">${escapeHtml(String(report.format ?? ''))}</div>
  <div class="k">Church</div><div class="v">${escapeHtml(String(report.church?.name ?? ''))}</div>
  <div class="k">Issued At</div><div class="v">${escapeHtml(new Date(report.createdAt).toISOString())}</div>
  <div class="k">Verification Code</div><div class="v">${escapeHtml(String(report.publicId ?? ''))}</div>
</div>
${report.file ? `<div class="actions"><a class="btn" href="${escapeHtml(downloadHref)}">Download PDF</a></div>` : ''}
<div class="note">This verification confirms the report exists in the system and has not been revoked.</div>`,
      });
    } catch {
      return htmlShell({
        title: 'Verification error',
        status: 'error',
        bodyHtml: `<div class="note">An unexpected error occurred during verification.</div>`,
      });
    }
  }

  @Get('report/:publicId/download')
  async downloadReport(
    @Param('publicId') publicId: string,
    @Query('t') token: string | undefined,
    @Res() res: Response,
  ): Promise<void> {
    if (!publicId || !publicId.trim()) {
      res.status(400).send('Invalid verification link');
      return;
    }

    if (!token || !token.trim()) {
      res.status(400).send('Verification token missing');
      return;
    }

    try {
      const report = await (this.prisma as any).report.findUnique({
        where: { publicId },
        include: {
          file: true,
        },
      });

      if (!report) {
        res.status(404).send('Report not found');
        return;
      }

      const tokenHash = sha256Hex(token);
      const expected = report.verifyTokenHash as string | null | undefined;
      if (!expected || expected.length !== tokenHash.length) {
        res.status(401).send('Invalid verification token');
        return;
      }

      if (!safeEqualHex(expected, tokenHash)) {
        res.status(401).send('Invalid verification token');
        return;
      }

      if (report.revokedAt) {
        res.status(410).send('Report revoked');
        return;
      }

      const file = report.file;
      if (!file?.bucket || !file?.path) {
        res.status(404).send('Report file not found');
        return;
      }

      const bucket = this.firebaseAdmin.bucket(String(file.bucket));
      const object = bucket.file(String(file.path));
      const expiresInMinutes = 10;
      const expiresAt = new Date(Date.now() + expiresInMinutes * 60 * 1000);
      const [url] = await object.getSignedUrl({
        version: 'v4',
        action: 'read',
        expires: expiresAt,
      });

      res.setHeader('Cache-Control', 'no-store');
      res.redirect(url);
    } catch {
      res.status(500).send('Download error');
    }
  }
}
