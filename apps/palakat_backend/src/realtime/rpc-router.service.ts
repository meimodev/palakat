import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { ModuleRef } from '@nestjs/core';
import { JwtService } from '@nestjs/jwt';
import { randomBytes, randomUUID } from 'crypto';
import { AccountService } from '../account/account.service';
import { ActivitiesService } from '../activity/activity.service';
import { ApprovalRuleService } from '../approval-rule/approval-rule.service';
import { ApproverService } from '../approver/approver.service';
import { AuthService } from '../auth/auth.service';
import { ArticleService } from '../article/article.service';
import { CashAccountService } from '../cash/cash-account.service';
import { CashMutationService } from '../cash/cash-mutation.service';
import { ChurchService } from '../church/church.service';
import { ChurchRequestService } from '../church-request/church-request.service';
import { ColumnService } from '../column/column.service';
import { ChurchLetterheadService } from '../church-letterhead/church-letterhead.service';
import { DocumentService } from '../document/document.service';
import { ExpenseService } from '../expense/expense.service';
import { FileService } from '../file/file.service';
import { FinanceService } from '../finance/finance.service';
import { FinancialAccountNumberService } from '../financial-account-number/financial-account-number.service';
import { LocationService } from '../location/location.service';
import { MembershipService } from '../membership/membership.service';
import { MembershipPositionService } from '../membership-position/membership-position.service';
import { NotificationService } from '../notification/notification.service';
import { PrismaService } from '../prisma.service';
import { ReportQueueService } from '../report/report-queue.service';
import { ReportService } from '../report/report.service';
import { RevenueService } from '../revenue/revenue.service';
import { SongService } from '../song/song.service';
import { SongPartService } from '../song-part/song-part.service';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import { RpcRequest, RpcResponse } from './realtime.types';
import { mapErrorToRpc } from './realtime.utils';
import { RealtimeEmitterService } from './realtime-emitter.service';
import {
  stripKeys,
  transformToIdArrays,
  transformToSetFormat,
} from 'src/utils';

@Injectable()
export class RpcRouterService {
  private readonly MAX_FILE_BYTES = 25 * 1024 * 1024;
  private readonly CHUNK_BYTES = 256 * 1024;
  private readonly MAX_ARTICLE_COVER_BYTES = 5 * 1024 * 1024;
  private readonly uploadSessions = new Map<string, any>();
  private readonly downloadSessions = new Map<string, any>();
  private readonly articleCoverUploadSessions = new Map<string, any>();
  private readonly socketSessionIndex = new Map<
    string,
    { uploads: Set<string>; downloads: Set<string>; articleCovers: Set<string> }
  >();

  constructor(
    private readonly authService: AuthService,
    private readonly jwtService: JwtService,
    private readonly moduleRef: ModuleRef,
  ) {}

  private get articleService(): ArticleService {
    return this.moduleRef.get(ArticleService, { strict: false });
  }

  private get prisma(): PrismaService {
    return this.moduleRef.get(PrismaService, { strict: false });
  }

  private get accountService(): AccountService {
    return this.moduleRef.get(AccountService, { strict: false });
  }

  private get membershipService(): MembershipService {
    return this.moduleRef.get(MembershipService, { strict: false });
  }

  private get financeService(): FinanceService {
    return this.moduleRef.get(FinanceService, { strict: false });
  }

  private get revenueService(): RevenueService {
    return this.moduleRef.get(RevenueService, { strict: false });
  }

  private get expenseService(): ExpenseService {
    return this.moduleRef.get(ExpenseService, { strict: false });
  }

  private get cashAccountService(): CashAccountService {
    return this.moduleRef.get(CashAccountService, { strict: false });
  }

  private get cashMutationService(): CashMutationService {
    return this.moduleRef.get(CashMutationService, { strict: false });
  }

  private get reportService(): ReportService {
    return this.moduleRef.get(ReportService, { strict: false });
  }

  private get reportQueueService(): ReportQueueService {
    return this.moduleRef.get(ReportQueueService, { strict: false });
  }

  private get documentService(): DocumentService {
    return this.moduleRef.get(DocumentService, { strict: false });
  }

  private get fileService(): FileService {
    return this.moduleRef.get(FileService, { strict: false });
  }

  private get notificationService(): NotificationService {
    return this.moduleRef.get(NotificationService, { strict: false });
  }

  private get churchService(): ChurchService {
    return this.moduleRef.get(ChurchService, { strict: false });
  }

  private get columnService(): ColumnService {
    return this.moduleRef.get(ColumnService, { strict: false });
  }

  private get locationService(): LocationService {
    return this.moduleRef.get(LocationService, { strict: false });
  }

  private get membershipPositionService(): MembershipPositionService {
    return this.moduleRef.get(MembershipPositionService, { strict: false });
  }

  private get approvalRuleService(): ApprovalRuleService {
    return this.moduleRef.get(ApprovalRuleService, { strict: false });
  }

  private get approverService(): ApproverService {
    return this.moduleRef.get(ApproverService, { strict: false });
  }

  private get financialAccountNumberService(): FinancialAccountNumberService {
    return this.moduleRef.get(FinancialAccountNumberService, { strict: false });
  }

  private get churchRequestService(): ChurchRequestService {
    return this.moduleRef.get(ChurchRequestService, { strict: false });
  }

  private get churchLetterheadService(): ChurchLetterheadService {
    return this.moduleRef.get(ChurchLetterheadService, { strict: false });
  }

  private get activitiesService(): ActivitiesService {
    return this.moduleRef.get(ActivitiesService, { strict: false });
  }

  private get songService(): SongService {
    return this.moduleRef.get(SongService, { strict: false });
  }

  private get songPartService(): SongPartService {
    return this.moduleRef.get(SongPartService, { strict: false });
  }

  private get firebaseAdmin(): FirebaseAdminService {
    return this.moduleRef.get(FirebaseAdminService, { strict: false });
  }

  private get realtimeEmitter(): RealtimeEmitterService {
    return this.moduleRef.get(RealtimeEmitterService, { strict: false });
  }

  onDisconnect(client: any) {
    const socketId = client?.id as string | undefined;
    if (!socketId) return;
    this.cleanupSocket(socketId);
  }

  private cleanupSocket(socketId: string) {
    const idx = this.socketSessionIndex.get(socketId);
    if (!idx) return;

    for (const uploadId of idx.uploads) {
      const session = this.uploadSessions.get(uploadId);
      try {
        session?.writeStream?.end?.();
      } catch (_) {}
      this.uploadSessions.delete(uploadId);
    }

    for (const downloadId of idx.downloads) {
      const session = this.downloadSessions.get(downloadId);
      try {
        session?.stream?.destroy?.();
      } catch (_) {}
      this.downloadSessions.delete(downloadId);
    }

    for (const uploadId of idx.articleCovers) {
      const session = this.articleCoverUploadSessions.get(uploadId);
      try {
        session?.writeStream?.end?.();
      } catch (_) {}
      this.articleCoverUploadSessions.delete(uploadId);
    }

    this.socketSessionIndex.delete(socketId);
  }

  private trackSocketSession(
    socketId: string,
    type: 'upload' | 'download',
    id: string,
  ) {
    const current =
      this.socketSessionIndex.get(socketId) ??
      ({
        uploads: new Set<string>(),
        downloads: new Set<string>(),
        articleCovers: new Set<string>(),
      } as any);
    if (type === 'upload') current.uploads.add(id);
    else current.downloads.add(id);
    this.socketSessionIndex.set(socketId, current);
  }

  private trackArticleCoverSession(socketId: string, id: string) {
    const current =
      this.socketSessionIndex.get(socketId) ??
      ({
        uploads: new Set<string>(),
        downloads: new Set<string>(),
        articleCovers: new Set<string>(),
      } as any);
    current.articleCovers.add(id);
    this.socketSessionIndex.set(socketId, current);
  }

  private sanitizeFilename(name: string): string {
    const trimmed = (name ?? '').trim();
    if (!trimmed) return 'file';
    return trimmed.replace(/[^a-zA-Z0-9._-]/g, '_').slice(0, 120);
  }

  private buildUploadPath(churchId: number, originalName?: string): string {
    const safe = this.sanitizeFilename(originalName ?? 'file');
    const stamp = new Date().toISOString().replace(/[:.]/g, '-');
    const nonce = randomBytes(6).toString('hex');
    return `churches/${churchId}/uploads/${stamp}_${nonce}_${safe}`;
  }

  private inferImageExt(contentType?: string, originalName?: string): string {
    const name = (originalName ?? '').toLowerCase();
    const extFromName = name.includes('.') ? name.split('.').pop() : undefined;
    const ct = (contentType ?? '').toLowerCase();
    const extFromMime =
      ct === 'image/jpeg'
        ? 'jpg'
        : ct === 'image/png'
          ? 'png'
          : ct === 'image/webp'
            ? 'webp'
            : undefined;
    return (
      (extFromName || extFromMime || 'png').replace(/[^a-z0-9]/g, '') || 'png'
    );
  }

  async dispatch(client: any, request: RpcRequest): Promise<RpcResponse> {
    try {
      const data = await this.handle(client, request);
      return { ok: true, id: request.id, data };
    } catch (e) {
      return { ok: false, id: request.id, error: mapErrorToRpc(e) };
    }
  }

  private requireUserId(client: any): {
    userId: number;
    role?: string;
    aud?: string;
  } {
    const user = client?.data?.user;
    if (!user?.userId) {
      throw new UnauthorizedException('Unauthenticated');
    }
    return user;
  }

  private isPublicSongDbFileId(fileId: number): boolean {
    const raw = process.env.SONG_DB_FILE_ID;
    if (!raw || typeof raw !== 'string') return false;
    const parsed = Number(raw);
    if (!Number.isFinite(parsed)) return false;
    return fileId === parsed;
  }

  private isPublicSongDbFileRecord(file: any): boolean {
    const originalName = (file?.originalName ?? '').toString().trim();
    const rawPath = (file?.path ?? '').toString();
    const normalizedPath = rawPath.replace(/^\/+/, '').trim();
    if (!normalizedPath) return false;
    if (normalizedPath !== 'db/songs.json') return false;
    if (originalName.length > 0 && originalName !== 'songs.json') return false;
    return true;
  }

  private songDbBookId(book: any): string {
    const normalized = (book ?? '').toString().trim().toLowerCase();
    return normalized;
  }

  private songDbBookName(book: any): string {
    const normalized = (book ?? '').toString().trim().toUpperCase();
    switch (normalized) {
      case 'NNBT':
        return 'Nanyikanlah Nyanyian Baru Bagi Tuhan';
      case 'KJ':
        return 'Kidung Jemaat';
      case 'NKB':
        return 'Nanyikanlah Kidung Baru';
      case 'DSL':
        return 'Dua Sahabat Lama';
      default:
        return '';
    }
  }

  private songDbBooks(): Array<{ id: string; name: string }> {
    return [
      { id: 'nnbt', name: this.songDbBookName('NNBT') },
      { id: 'kj', name: this.songDbBookName('KJ') },
      { id: 'nkb', name: this.songDbBookName('NKB') },
      { id: 'dsl', name: this.songDbBookName('DSL') },
    ];
  }

  private normalizeSongDbPartType(raw: any): string {
    const input = (raw ?? '').toString().trim();
    if (!input) return 'VERSE';

    const normalized = input
      .toUpperCase()
      .replace(/\s+/g, '')
      .replace(/[^A-Z0-9]/g, '');
    if (!normalized) return 'VERSE';

    const allowed = new Set([
      'INTRO',
      'OUTRO',
      'VERSE',
      'VERSE1',
      'VERSE2',
      'VERSE3',
      'VERSE4',
      'VERSE5',
      'VERSE6',
      'VERSE7',
      'VERSE8',
      'VERSE9',
      'VERSE10',
      'REFRAIN',
      'PRECHORUS',
      'CHORUS',
      'CHORUS2',
      'CHORUS3',
      'CHORUS4',
      'BRIDGE',
      'HOOK',
    ]);

    if (allowed.has(normalized)) return normalized;

    if (normalized.startsWith('VERSE')) {
      const suffix = normalized.slice('VERSE'.length);
      if (suffix.length > 0 && /^\d+$/.test(suffix)) {
        const type = `VERSE${suffix}`;
        if (allowed.has(type)) return type;
      }
      return 'VERSE';
    }

    if (normalized.startsWith('CHORUS')) {
      const suffix = normalized.slice('CHORUS'.length);
      if (suffix.length > 0 && /^\d+$/.test(suffix)) {
        const type = `CHORUS${suffix}`;
        if (allowed.has(type)) return type;
      }
      return 'CHORUS';
    }

    if (normalized === 'PRECHORUS' || normalized === 'PRECHOR') {
      return 'PRECHORUS';
    }

    return 'VERSE';
  }

  private requireAuthAny(client: any): {
    userId?: number;
    clientId?: string;
    role?: string;
    aud?: string;
  } {
    const u = client?.data?.user;
    if (!u?.userId && !u?.clientId) {
      throw new UnauthorizedException('Unauthenticated');
    }
    return u;
  }

  private requireSuperAdminOrClient(client: any): void {
    const u: any = this.requireAuthAny(client);
    if (u?.clientId) return;
    if (u?.role === 'SUPER_ADMIN') return;
    throw new ForbiddenException('Insufficient role');
  }

  private async resolveMembershipIdForUser(userId: number): Promise<number> {
    const membership = await (this.prisma as any).membership.findUnique({
      where: { accountId: userId },
      select: { id: true },
    });
    if (!membership?.id) {
      throw new BadRequestException('User does not have a membership');
    }
    return membership.id;
  }

  private withPagination<T extends Record<string, any> | undefined>(
    query: T,
  ): T {
    if (!query || typeof query !== 'object') return query;

    const page =
      typeof (query as any).page === 'number' && (query as any).page >= 1
        ? (query as any).page
        : 1;
    const pageSize =
      typeof (query as any).pageSize === 'number' &&
      (query as any).pageSize >= 1
        ? (query as any).pageSize
        : 100;

    if ((query as any).skip === undefined) {
      (query as any).skip = (page - 1) * pageSize;
    }
    if ((query as any).take === undefined) {
      (query as any).take = pageSize;
    }
    return query;
  }

  private toPaginationMeta(query: Record<string, any>, total: number) {
    const page =
      typeof query.page === 'number' && query.page >= 1 ? query.page : 1;
    const pageSize =
      typeof query.pageSize === 'number' && query.pageSize >= 1
        ? query.pageSize
        : 100;
    const totalPages = Math.ceil(total / pageSize);
    return {
      page,
      pageSize,
      total,
      totalPages,
      hasNext: page < totalPages,
      hasPrev: page > 1,
    };
  }

  private normalizePaginatedList(query: Record<string, any>, res: any) {
    if (!res || typeof res !== 'object') return res;

    const { data, total, message, ...rest } = res as any;
    if (Array.isArray(data) && typeof total === 'number') {
      return {
        ...(message ? { message } : {}),
        data,
        pagination: this.toPaginationMeta(query, total),
        ...rest,
      };
    }
    return res;
  }

  private getAuthContext(client: any): any {
    const u = client?.data?.user;
    if (!u) return {};
    if (u.clientId) return { clientId: u.clientId, source: u.source ?? 'ws' };
    if (u.userId) {
      return {
        userId: u.userId,
        role: u.role,
        aud: u.aud,
        source: u.source ?? 'ws',
      };
    }
    return {};
  }

  private async attachTokenToClient(client: any, accessToken: string) {
    if (!accessToken || accessToken.trim().length === 0) {
      throw new BadRequestException('accessToken is required');
    }

    const payload: any = this.jwtService.verify(accessToken);

    if (payload?.clientId) {
      client.data.user = { clientId: payload.clientId, source: 'ws-auth' };
      return { message: 'OK', data: client.data.user };
    }

    if (payload?.sub) {
      client.data.user = {
        userId: payload.sub,
        role: payload?.role,
        aud: payload?.aud,
        source: 'ws-auth',
      };

      try {
        client.join(`user:${payload.sub}`);
        client.join(`account.${payload.sub}`);
      } catch (_) {}

      try {
        const membership = await (this.prisma as any).membership.findUnique({
          where: { accountId: payload.sub },
          select: { id: true, churchId: true },
        });
        if (membership?.id) {
          client.join(`membership.${membership.id}`);
        }
        if (membership?.churchId) {
          client.join(`church.${membership.churchId}`);
        }
      } catch (_) {}
      return { message: 'OK', data: client.data.user };
    }

    throw new UnauthorizedException('Invalid JWT payload');
  }

  private async handle(client: any, request: RpcRequest): Promise<unknown> {
    const action = request.action;
    const payload = (request.payload ?? {}) as any;

    switch (action) {
      case 'ping':
        return { message: 'pong' };

      case 'app.home.get': {
        const user = this.requireUserId(client);
        const membershipId = await this.resolveMembershipIdForUser(user.userId);
        const membershipRes: any =
          await this.membershipService.findOne(membershipId);
        const membership = membershipRes?.data ?? membershipRes;

        const now = new Date();

        const utcDay = now.getUTCDay();
        const daysSinceMonday = (utcDay + 6) % 7;

        const startDate = new Date(
          Date.UTC(
            now.getUTCFullYear(),
            now.getUTCMonth(),
            now.getUTCDate() - daysSinceMonday,
            0,
            0,
            0,
            0,
          ),
        );

        const endDate = new Date(
          Date.UTC(
            startDate.getUTCFullYear(),
            startDate.getUTCMonth(),
            startDate.getUTCDate() + 6,
            23,
            59,
            59,
            999,
          ),
        );

        const query: any = {
          startDate,
          endDate,
          sortBy: 'date',
          sortOrder: 'asc',
          skip: 0,
          take: 250,
        };

        const churchId =
          (membership as any)?.churchId ?? (membership as any)?.church?.id;
        if (typeof churchId === 'number') {
          query.churchId = churchId;
        }

        const activitiesRes: any = await this.activitiesService.findAll(
          query,
          this.getAuthContext(client),
        );
        const activities = Array.isArray(activitiesRes?.data)
          ? activitiesRes.data
          : [];

        const thisWeekActivities = activities.filter(
          (a: any) =>
            a?.activityType === 'EVENT' || a?.activityType === 'SERVICE',
        );
        const thisWeekAnnouncements = activities.filter(
          (a: any) => a?.activityType === 'ANNOUNCEMENT',
        );

        const upcoming = thisWeekActivities
          .filter((a: any) => {
            const date = a?.date ? new Date(a.date) : null;
            if (!date || isNaN(date.getTime())) return false;
            return date.getTime() >= now.getTime();
          })
          .sort(
            (a: any, b: any) =>
              new Date(a.date).getTime() - new Date(b.date).getTime(),
          );

        return {
          message: 'OK',
          data: {
            membership,
            range: {
              startDate: startDate.toISOString(),
              endDate: endDate.toISOString(),
            },
            thisWeekActivities,
            thisWeekAnnouncements,
            nextUpActivity: upcoming.length > 0 ? upcoming[0] : null,
          },
        };
      }

      case 'auth.attach':
        return this.attachTokenToClient(client, payload.accessToken);

      case 'auth.signIn':
        return this.authService.signIn({
          identifier: payload.identifier,
          password: payload.password,
        });

      case 'auth.superAdminSignIn':
        return this.authService.superAdminSignIn({
          phone: payload.phone,
          password: payload.password,
        });

      case 'auth.validatePhone':
        return this.authService.validate(payload.phone);

      case 'auth.refresh': {
        const refreshToken = payload.refreshToken as string;
        if (!refreshToken || refreshToken.trim().length === 0) {
          throw new BadRequestException('refreshToken is required');
        }
        const decoded: any = this.jwtService.verify(refreshToken);
        if (!decoded?.sub) {
          throw new BadRequestException('Invalid refresh token');
        }
        return this.authService.refreshToken(decoded.sub, refreshToken);
      }

      case 'auth.signOut': {
        const user = this.requireUserId(client);
        return this.authService.signOut(user.userId);
      }

      case 'auth.signingClient': {
        const username = payload.username as string;
        const password = payload.password as string;

        const validUsername = process.env.APP_CLIENT_USERNAME;
        const validPassword = process.env.APP_CLIENT_PASSWORD;

        if (!username || !password) {
          throw new BadRequestException('username and password are required');
        }
        if (username !== validUsername || password !== validPassword) {
          throw new UnauthorizedException('Invalid client credentials');
        }

        return this.authService.generateClientToken({
          clientId: username,
        });
      }

      case 'auth.syncClaims': {
        const firebaseIdToken = payload.firebaseIdToken as string;
        return this.authService.syncClaims(firebaseIdToken);
      }

      case 'auth.firebaseSignIn': {
        const firebaseIdToken = payload.firebaseIdToken as string;
        if (!firebaseIdToken || firebaseIdToken.trim().length === 0) {
          throw new BadRequestException('firebaseIdToken is required');
        }
        return this.authService.signInWithFirebaseIdToken(firebaseIdToken);
      }

      case 'auth.firebaseRegister': {
        const firebaseIdToken = payload.firebaseIdToken as string;
        if (!firebaseIdToken || firebaseIdToken.trim().length === 0) {
          throw new BadRequestException('firebaseIdToken is required');
        }

        const { firebaseIdToken: _, ...dto } = (payload ?? {}) as any;
        return this.authService.registerWithFirebaseIdToken(
          firebaseIdToken,
          dto,
        );
      }

      case 'sub.join': {
        this.requireUserId(client);
        const room = payload.room as string;
        if (!room || room.trim().length === 0) {
          throw new BadRequestException('room is required');
        }
        client.join(room);
        return { message: 'OK', data: { room } };
      }

      case 'sub.leave': {
        this.requireUserId(client);
        const room = payload.room as string;
        if (!room || room.trim().length === 0) {
          throw new BadRequestException('room is required');
        }
        client.leave(room);
        return { message: 'OK', data: { room } };
      }

      // ===== Articles (Public) =====
      case 'articles.list': {
        const query = this.withPagination(payload) as any;
        const res: any = await this.articleService.findAllPublic(query);
        return this.normalizePaginatedList(query, res);
      }

      case 'articles.get': {
        const id = payload.id as number;
        if (typeof id !== 'number') {
          throw new BadRequestException('id is required');
        }
        return this.articleService.findOnePublic(id);
      }

      case 'articles.like': {
        const user = this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number') {
          throw new BadRequestException('id is required');
        }
        return this.articleService.like(id, user.userId);
      }

      case 'articles.unlike': {
        const user = this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number') {
          throw new BadRequestException('id is required');
        }
        return this.articleService.unlike(id, user.userId);
      }

      // ===== Articles (Admin) =====
      case 'admin.articles.list': {
        this.requireAuthAny(client);
        const query = this.withPagination(payload) as any;
        const res: any = await this.articleService.findAllAdmin(
          query,
          this.getAuthContext(client),
        );
        return this.normalizePaginatedList(query, res);
      }

      case 'admin.articles.get': {
        this.requireAuthAny(client);
        const id = payload.id as number;
        if (typeof id !== 'number') {
          throw new BadRequestException('id is required');
        }
        return this.articleService.findOneAdmin(
          id,
          this.getAuthContext(client),
        );
      }

      case 'admin.articles.create': {
        this.requireAuthAny(client);
        return this.articleService.create(payload, this.getAuthContext(client));
      }

      case 'admin.articles.update': {
        this.requireAuthAny(client);
        const id = payload.id as number;
        if (typeof id !== 'number') {
          throw new BadRequestException('id is required');
        }
        return this.articleService.update(
          id,
          payload.dto ?? {},
          this.getAuthContext(client),
        );
      }

      case 'admin.articles.cover.upload.init': {
        this.requireSuperAdminOrClient(client);

        if (!this.firebaseAdmin.isConfigured()) {
          throw new BadRequestException('Firebase Storage is not configured');
        }

        const socketId = client?.id as string;
        const id = payload.id as number;
        const sizeBytes = payload.sizeBytes as number;
        const contentType = payload.contentType as string | undefined;
        const originalName = payload.originalName as string | undefined;

        if (typeof id !== 'number') {
          throw new BadRequestException('id is required');
        }
        if (typeof sizeBytes !== 'number' || sizeBytes <= 0) {
          throw new BadRequestException('sizeBytes is required');
        }
        if (sizeBytes > this.MAX_ARTICLE_COVER_BYTES) {
          throw new BadRequestException('File is too large (max 5MB)');
        }
        if (!contentType || !contentType.startsWith('image/')) {
          throw new BadRequestException('Only image uploads are supported');
        }

        const existing = await (this.prisma as any).article.findUnique({
          where: { id },
          select: { id: true },
        });
        if (!existing) {
          throw new BadRequestException('Article not found');
        }

        const ext = this.inferImageExt(contentType, originalName);
        const path = `articles/${id}/cover.${ext}`;
        const token = randomUUID();
        const bucket = this.firebaseAdmin.bucket();
        const fileRef = bucket.file(path);

        const canStream =
          typeof (fileRef as any).createWriteStream === 'function';
        const writeStream = canStream
          ? (fileRef as any).createWriteStream({
              resumable: false,
              metadata: {
                contentType,
                cacheControl: 'public, max-age=31536000',
                metadata: {
                  firebaseStorageDownloadTokens: token,
                },
              },
            })
          : null;

        const uploadId = randomBytes(16).toString('hex');
        this.articleCoverUploadSessions.set(uploadId, {
          uploadId,
          socketId,
          articleId: id,
          sizeBytes,
          receivedBytes: 0,
          contentType,
          originalName,
          path,
          token,
          bucketName: bucket.name as string,
          writeStream,
          buffers: [] as Buffer[],
        });
        this.trackArticleCoverSession(socketId, uploadId);

        return {
          message: 'OK',
          data: {
            uploadId,
            chunkSize: this.CHUNK_BYTES,
            maxBytes: this.MAX_ARTICLE_COVER_BYTES,
          },
        };
      }

      case 'admin.articles.cover.upload.chunk': {
        this.requireSuperAdminOrClient(client);
        const socketId = client?.id as string;
        const uploadId = payload.uploadId as string;
        const dataBase64 = payload.dataBase64 as string;
        if (!uploadId || typeof uploadId !== 'string') {
          throw new BadRequestException('uploadId is required');
        }
        if (!dataBase64 || typeof dataBase64 !== 'string') {
          throw new BadRequestException('dataBase64 is required');
        }

        const session = this.articleCoverUploadSessions.get(uploadId);
        if (!session || session.socketId !== socketId) {
          throw new BadRequestException('Invalid uploadId');
        }

        const buf = Buffer.from(dataBase64, 'base64');
        if (buf.length === 0) {
          throw new BadRequestException('Empty chunk');
        }
        if (buf.length > this.CHUNK_BYTES) {
          throw new BadRequestException('Chunk too large');
        }

        session.receivedBytes += buf.length;
        if (session.receivedBytes > session.sizeBytes) {
          throw new BadRequestException('Received too many bytes');
        }
        if (session.receivedBytes > this.MAX_ARTICLE_COVER_BYTES) {
          throw new BadRequestException('File is too large (max 5MB)');
        }

        if (session.writeStream) {
          const ok = session.writeStream.write(buf);
          if (!ok) {
            await new Promise<void>((resolve, reject) => {
              session.writeStream.once('drain', resolve);
              session.writeStream.once('error', reject);
            });
          }
        } else {
          session.buffers.push(buf);
        }

        return {
          message: 'OK',
          data: {
            receivedBytes: session.receivedBytes,
            totalBytes: session.sizeBytes,
          },
        };
      }

      case 'admin.articles.cover.upload.complete': {
        this.requireSuperAdminOrClient(client);
        const socketId = client?.id as string;
        const uploadId = payload.uploadId as string;
        if (!uploadId || typeof uploadId !== 'string') {
          throw new BadRequestException('uploadId is required');
        }
        const session = this.articleCoverUploadSessions.get(uploadId);
        if (!session || session.socketId !== socketId) {
          throw new BadRequestException('Invalid uploadId');
        }
        if (session.receivedBytes !== session.sizeBytes) {
          throw new BadRequestException('Incomplete upload');
        }

        if (session.writeStream) {
          await new Promise<void>((resolve, reject) => {
            session.writeStream.end();
            session.writeStream.once('finish', resolve);
            session.writeStream.once('error', reject);
          });
        } else {
          const bucket = this.firebaseAdmin.bucket();
          const fileRef = bucket.file(session.path);
          const buffer = Buffer.concat(session.buffers);
          await (fileRef as any).save(buffer, {
            resumable: false,
            metadata: {
              contentType: session.contentType,
              cacheControl: 'public, max-age=31536000',
              metadata: {
                firebaseStorageDownloadTokens: session.token,
              },
            },
          });
        }

        const url = `https://firebasestorage.googleapis.com/v0/b/${session.bucketName}/o/${encodeURIComponent(session.path)}?alt=media&token=${session.token}`;

        const updated = await (this.prisma as any).article.update({
          where: { id: session.articleId },
          data: { coverImageUrl: url },
          select: {
            id: true,
            type: true,
            status: true,
            title: true,
            slug: true,
            excerpt: true,
            content: true,
            coverImageUrl: true,
            publishedAt: true,
            likesCount: true,
            createdAt: true,
            updatedAt: true,
          },
        });

        this.articleCoverUploadSessions.delete(uploadId);
        return { message: 'OK', data: updated };
      }

      case 'admin.articles.cover.upload.abort': {
        this.requireSuperAdminOrClient(client);
        const socketId = client?.id as string;
        const uploadId = payload.uploadId as string;
        if (!uploadId || typeof uploadId !== 'string') {
          throw new BadRequestException('uploadId is required');
        }
        const session = this.articleCoverUploadSessions.get(uploadId);
        if (session && session.socketId === socketId) {
          try {
            session.writeStream?.end?.();
          } catch (_) {}
          this.articleCoverUploadSessions.delete(uploadId);
        }
        return { message: 'OK', data: true };
      }

      case 'admin.articles.publish': {
        this.requireAuthAny(client);
        const id = payload.id as number;
        if (typeof id !== 'number') {
          throw new BadRequestException('id is required');
        }
        return this.articleService.publish(id, this.getAuthContext(client));
      }

      case 'admin.articles.unpublish': {
        this.requireAuthAny(client);
        const id = payload.id as number;
        if (typeof id !== 'number') {
          throw new BadRequestException('id is required');
        }
        return this.articleService.unpublish(id, this.getAuthContext(client));
      }

      case 'admin.articles.archive': {
        this.requireAuthAny(client);
        const id = payload.id as number;
        if (typeof id !== 'number') {
          throw new BadRequestException('id is required');
        }
        return this.articleService.archive(id, this.getAuthContext(client));
      }

      // ===== Account =====
      case 'account.count': {
        this.requireUserId(client);
        return this.accountService.count(payload);
      }

      case 'account.get': {
        this.requireUserId(client);
        const id = payload.id as string;
        if (!id || typeof id !== 'string') {
          throw new BadRequestException('id is required');
        }
        const numericId = parseInt(id, 10);
        const identifier =
          !isNaN(numericId) && numericId.toString() === id
            ? { accountId: numericId }
            : { phone: id };
        return this.accountService.findOne(identifier);
      }

      case 'account.list': {
        this.requireUserId(client);
        const query = this.withPagination(payload) as any;
        const res: any = await this.accountService.findAll(query);
        return this.normalizePaginatedList(query, res);
      }

      case 'account.create': {
        this.requireUserId(client);
        const { membership, ...rest } = (payload ?? {}) as any;
        const data: any = {
          ...rest,
          ...(membership ? { membership } : {}),
        };

        if (data.dob && !data.dob.toString().endsWith('Z')) {
          data.dob = data.dob.toString() + 'Z';
        }

        const transformed = transformToIdArrays(data, [
          'church',
          'column',
          'membershipPositions',
        ]);
        return this.accountService.create(transformed);
      }

      case 'account.update': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number') {
          throw new BadRequestException('id is required');
        }

        const updateDto = payload.dto ?? {};
        const transformed = transformToIdArrays(updateDto, [
          'column',
          'church',
        ]);
        const prismaSet = transformToSetFormat(transformed, [
          'membershipPositions',
        ]);
        const cleaned = stripKeys(prismaSet, ['id', 'updatedAt', 'createdAt']);
        if (cleaned.dob && !cleaned.dob.toString().endsWith('Z')) {
          cleaned.dob = new Date(cleaned.dob.toString() + 'Z');
        }
        return this.accountService.update(id, cleaned);
      }

      case 'account.delete': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number') {
          throw new BadRequestException('id is required');
        }
        return this.accountService.delete(id);
      }

      // ===== Membership =====
      case 'membership.create': {
        this.requireUserId(client);
        return this.membershipService.create(payload);
      }

      case 'membership.list': {
        this.requireUserId(client);
        const query = this.withPagination(payload) as any;
        const res: any = await this.membershipService.findAll(query);
        return this.normalizePaginatedList(query, res);
      }

      case 'membership.get': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.membershipService.findOne(id);
      }

      case 'membership.update': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.membershipService.update(id, payload.dto ?? {});
      }

      case 'membership.delete': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.membershipService.remove(id);
      }

      // ===== Membership Invitations =====
      case 'membershipInvitation.preview': {
        this.requireUserId(client);

        const identifier =
          (payload.identifier as string | undefined) ??
          (payload.id as string | undefined) ??
          (payload.phone as string | undefined);
        if (!identifier || typeof identifier !== 'string') {
          throw new BadRequestException('identifier is required');
        }

        const invitee: any = await (this.prisma as any).account.findUnique({
          where: { phone: identifier },
          select: {
            id: true,
            name: true,
            phone: true,
            email: true,
            isActive: true,
            claimed: true,
            gender: true,
            maritalStatus: true,
            dob: true,
            createdAt: true,
            updatedAt: true,
          },
        });

        if (!invitee?.id) {
          throw new NotFoundException('Account not found');
        }

        const membership: any = await (
          this.prisma as any
        ).membership.findUnique({
          where: { accountId: invitee.id },
          include: {
            account: true,
            church: true,
            column: true,
            membershipPositions: true,
          },
        });

        if (membership?.id) {
          return {
            message: 'OK',
            data: {
              eligibility: 'ALREADY_MEMBER',
              invitee,
              membership,
              pendingInvitation: null,
              latestRejectedInvitation: null,
            },
          };
        }

        const pendingInvitation: any = await (
          this.prisma as any
        ).membershipInvitation.findFirst({
          where: {
            inviteeId: invitee.id,
            status: 'PENDING',
          },
          orderBy: { createdAt: 'desc' },
          include: {
            inviter: {
              select: {
                id: true,
                name: true,
                phone: true,
                email: true,
                isActive: true,
                claimed: true,
                gender: true,
                maritalStatus: true,
                dob: true,
                createdAt: true,
                updatedAt: true,
              },
            },
            church: { select: { id: true, name: true } },
            column: { select: { id: true, name: true, churchId: true } },
          },
        });

        if (pendingInvitation?.id) {
          return {
            message: 'OK',
            data: {
              eligibility: 'PENDING_INVITE_EXISTS',
              invitee,
              membership: null,
              pendingInvitation,
              latestRejectedInvitation: null,
            },
          };
        }

        const latestRejectedInvitation: any = await (
          this.prisma as any
        ).membershipInvitation.findFirst({
          where: {
            inviteeId: invitee.id,
            status: 'REJECTED',
          },
          orderBy: { updatedAt: 'desc' },
          include: {
            inviter: {
              select: {
                id: true,
                name: true,
                phone: true,
                email: true,
                isActive: true,
                claimed: true,
                gender: true,
                maritalStatus: true,
                dob: true,
                createdAt: true,
                updatedAt: true,
              },
            },
            church: { select: { id: true, name: true } },
            column: { select: { id: true, name: true, churchId: true } },
          },
        });

        return {
          message: 'OK',
          data: {
            eligibility: latestRejectedInvitation?.id
              ? 'REJECTED_PREVIOUSLY'
              : 'CAN_INVITE',
            invitee,
            membership: null,
            pendingInvitation: null,
            latestRejectedInvitation: latestRejectedInvitation?.id
              ? latestRejectedInvitation
              : null,
          },
        };
      }

      case 'membershipInvitation.create': {
        const user = this.requireUserId(client);
        const inviteeId = payload.inviteeId as number;
        const churchId = payload.churchId as number;
        const columnId = payload.columnId as number;
        const baptize = payload.baptize === true;
        const sidi = payload.sidi === true;

        if (typeof inviteeId !== 'number') {
          throw new BadRequestException('inviteeId is required');
        }
        if (typeof churchId !== 'number') {
          throw new BadRequestException('churchId is required');
        }
        if (typeof columnId !== 'number') {
          throw new BadRequestException('columnId is required');
        }
        if (inviteeId === user.userId) {
          throw new BadRequestException('Cannot invite yourself');
        }

        const inviterMembershipId = await this.resolveMembershipIdForUser(
          user.userId,
        );
        const inviterMembership: any = await (
          this.prisma as any
        ).membership.findUnique({
          where: { id: inviterMembershipId },
          select: { id: true, churchId: true, columnId: true },
        });
        if (!inviterMembership?.id) {
          throw new BadRequestException('Invalid inviter membership');
        }
        if (inviterMembership.churchId !== churchId) {
          throw new ForbiddenException('Invalid church scope');
        }
        if (inviterMembership.columnId !== columnId) {
          throw new ForbiddenException('Invalid column scope');
        }

        const column: any = await (this.prisma as any).column.findUnique({
          where: { id: columnId },
          select: { id: true, churchId: true },
        });
        if (!column?.id) {
          throw new BadRequestException('columnId does not exist');
        }
        if (
          typeof column.churchId !== 'number' ||
          column.churchId !== churchId
        ) {
          throw new BadRequestException(
            'columnId belongs to a different church',
          );
        }

        const inviteeMembership: any = await (
          this.prisma as any
        ).membership.findUnique({
          where: { accountId: inviteeId },
          select: { id: true },
        });
        if (inviteeMembership?.id) {
          throw new ConflictException('Invitee already has a membership');
        }

        const existingPending: any = await (
          this.prisma as any
        ).membershipInvitation.findFirst({
          where: { inviteeId, status: 'PENDING' },
          orderBy: { createdAt: 'desc' },
          include: {
            inviter: {
              select: {
                id: true,
                name: true,
                phone: true,
                email: true,
                isActive: true,
                claimed: true,
                gender: true,
                maritalStatus: true,
                dob: true,
                createdAt: true,
                updatedAt: true,
              },
            },
            church: { select: { id: true, name: true } },
            column: { select: { id: true, name: true, churchId: true } },
          },
        });

        if (existingPending?.id) {
          return {
            message: 'OK',
            data: existingPending,
          };
        }

        const created: any = await (
          this.prisma as any
        ).membershipInvitation.create({
          data: {
            inviterId: user.userId,
            inviteeId,
            churchId,
            columnId,
            baptize,
            sidi,
            status: 'PENDING',
          },
          include: {
            inviter: {
              select: {
                id: true,
                name: true,
                phone: true,
                email: true,
                isActive: true,
                claimed: true,
                gender: true,
                maritalStatus: true,
                dob: true,
                createdAt: true,
                updatedAt: true,
              },
            },
            church: { select: { id: true, name: true } },
            column: { select: { id: true, name: true, churchId: true } },
          },
        });

        return {
          message: 'OK',
          data: created,
        };
      }

      case 'membershipInvitation.myPending': {
        const user = this.requireUserId(client);

        const pending: any = await (
          this.prisma as any
        ).membershipInvitation.findFirst({
          where: {
            inviteeId: user.userId,
            status: 'PENDING',
          },
          orderBy: { createdAt: 'desc' },
          include: {
            inviter: {
              select: {
                id: true,
                name: true,
                phone: true,
                email: true,
                isActive: true,
                claimed: true,
                gender: true,
                maritalStatus: true,
                dob: true,
                createdAt: true,
                updatedAt: true,
              },
            },
            church: { select: { id: true, name: true } },
            column: { select: { id: true, name: true, churchId: true } },
          },
        });

        return {
          message: 'OK',
          data: pending ?? null,
        };
      }

      case 'membershipInvitation.respond': {
        const user = this.requireUserId(client);
        const id = payload.id as number;
        const action = (payload.action ?? payload.status ?? '').toString();
        const reason =
          (payload.reason as string | undefined) ??
          (payload.rejectedReason as string | undefined) ??
          (payload.dto?.reason as string | undefined) ??
          (payload.dto?.rejectedReason as string | undefined);

        if (typeof id !== 'number') {
          throw new BadRequestException('id is required');
        }
        if (!action || (action !== 'APPROVE' && action !== 'REJECT')) {
          throw new BadRequestException('action must be APPROVE or REJECT');
        }

        const invitation: any = await (
          this.prisma as any
        ).membershipInvitation.findUnique({
          where: { id },
          include: {
            inviter: {
              select: {
                id: true,
                name: true,
                phone: true,
                email: true,
                isActive: true,
                claimed: true,
                gender: true,
                maritalStatus: true,
                dob: true,
                createdAt: true,
                updatedAt: true,
              },
            },
            church: { select: { id: true, name: true } },
            column: { select: { id: true, name: true, churchId: true } },
          },
        });

        if (!invitation?.id) {
          throw new NotFoundException('Invitation not found');
        }
        if (invitation.inviteeId !== user.userId) {
          throw new ForbiddenException('Not allowed');
        }
        if (invitation.status !== 'PENDING') {
          throw new ConflictException('Invitation already resolved');
        }

        if (action === 'REJECT') {
          const updated: any = await (
            this.prisma as any
          ).membershipInvitation.update({
            where: { id: invitation.id },
            data: {
              status: 'REJECTED',
              rejectedAt: new Date(),
              rejectedReason:
                typeof reason === 'string' && reason.trim().length > 0
                  ? reason.trim()
                  : null,
            },
            include: {
              inviter: {
                select: {
                  id: true,
                  name: true,
                  phone: true,
                  email: true,
                  isActive: true,
                  claimed: true,
                  gender: true,
                  maritalStatus: true,
                  dob: true,
                  createdAt: true,
                  updatedAt: true,
                },
              },
              church: { select: { id: true, name: true } },
              column: { select: { id: true, name: true, churchId: true } },
            },
          });

          return { message: 'OK', data: { invitation: updated } };
        }

        const existingMembership: any = await (
          this.prisma as any
        ).membership.findUnique({
          where: { accountId: user.userId },
          select: { id: true },
        });
        if (existingMembership?.id) {
          throw new ConflictException('User already has a membership');
        }

        const res = await (this.prisma as any).$transaction(async (tx: any) => {
          const column: any = await tx.column.findUnique({
            where: { id: invitation.columnId },
            select: { id: true, churchId: true },
          });
          if (!column?.id) {
            throw new BadRequestException('columnId does not exist');
          }
          if (
            typeof column.churchId !== 'number' ||
            column.churchId !== invitation.churchId
          ) {
            throw new BadRequestException(
              'columnId belongs to a different church',
            );
          }

          const membership = await tx.membership.create({
            data: {
              accountId: user.userId,
              churchId: invitation.churchId,
              columnId: invitation.columnId,
              baptize: invitation.baptize === true,
              sidi: invitation.sidi === true,
            },
            include: {
              account: true,
              church: true,
              column: true,
              membershipPositions: true,
            },
          });

          const updatedInvitation = await tx.membershipInvitation.update({
            where: { id: invitation.id },
            data: {
              status: 'APPROVED',
              rejectedAt: null,
              rejectedReason: null,
            },
            include: {
              inviter: {
                select: {
                  id: true,
                  name: true,
                  phone: true,
                  email: true,
                  isActive: true,
                  claimed: true,
                  gender: true,
                  maritalStatus: true,
                  dob: true,
                  createdAt: true,
                  updatedAt: true,
                },
              },
              church: { select: { id: true, name: true } },
              column: { select: { id: true, name: true, churchId: true } },
            },
          });

          return { membership, invitation: updatedInvitation };
        });

        try {
          if (res?.membership?.id) {
            client.join(`membership.${res.membership.id}`);
          }
          if (res?.membership?.churchId) {
            client.join(`church.${res.membership.churchId}`);
          }
        } catch (_) {}

        return { message: 'OK', data: res };
      }

      case 'admin.membershipInvitation.list': {
        const auth = this.requireUserId(client);
        if (auth?.role !== 'SUPER_ADMIN') {
          throw new ForbiddenException('Insufficient role');
        }

        const query = this.withPagination(payload) as any;

        const status = (query.status ?? '').toString().trim().toUpperCase();
        const search = (query.search ?? '').toString().trim();
        const startDateRaw = (query.startDate ?? '').toString().trim();
        const endDateRaw = (query.endDate ?? '').toString().trim();

        const where: any = {};

        if (status) {
          if (
            status !== 'PENDING' &&
            status !== 'APPROVED' &&
            status !== 'REJECTED'
          ) {
            throw new BadRequestException('Invalid status');
          }
          where.status = status;
        }

        const start = startDateRaw ? new Date(startDateRaw) : null;
        const end = endDateRaw ? new Date(endDateRaw) : null;

        if (start && !isNaN(start.getTime())) {
          where.createdAt = { ...(where.createdAt ?? {}), gte: start };
        }
        if (end && !isNaN(end.getTime())) {
          where.createdAt = { ...(where.createdAt ?? {}), lte: end };
        }

        if (search && search.length >= 3) {
          where.OR = [
            { inviter: { name: { contains: search, mode: 'insensitive' } } },
            { inviter: { phone: { contains: search, mode: 'insensitive' } } },
            { invitee: { name: { contains: search, mode: 'insensitive' } } },
            { invitee: { phone: { contains: search, mode: 'insensitive' } } },
            { church: { name: { contains: search, mode: 'insensitive' } } },
            { column: { name: { contains: search, mode: 'insensitive' } } },
          ];
        }

        const accountSelect = {
          select: {
            id: true,
            name: true,
            phone: true,
            email: true,
            isActive: true,
            claimed: true,
            gender: true,
            maritalStatus: true,
            dob: true,
            createdAt: true,
            updatedAt: true,
          },
        } as const;

        const [total, data] = await (this.prisma as any).$transaction([
          (this.prisma as any).membershipInvitation.count({ where }),
          (this.prisma as any).membershipInvitation.findMany({
            where,
            skip: query.skip,
            take: query.take,
            orderBy: { createdAt: 'desc' },
            include: {
              inviter: accountSelect,
              invitee: accountSelect,
              church: { select: { id: true, name: true } },
              column: { select: { id: true, name: true, churchId: true } },
            },
          }),
        ]);

        return this.normalizePaginatedList(query, {
          message: 'OK',
          data,
          total,
        });
      }

      case 'admin.membershipInvitation.get': {
        const auth = this.requireUserId(client);
        if (auth?.role !== 'SUPER_ADMIN') {
          throw new ForbiddenException('Insufficient role');
        }
        const id = payload.id as number;
        if (typeof id !== 'number') {
          throw new BadRequestException('id is required');
        }

        const accountSelect = {
          select: {
            id: true,
            name: true,
            phone: true,
            email: true,
            isActive: true,
            claimed: true,
            gender: true,
            maritalStatus: true,
            dob: true,
            createdAt: true,
            updatedAt: true,
          },
        } as const;

        const inv = await (this.prisma as any).membershipInvitation.findUnique({
          where: { id },
          include: {
            inviter: accountSelect,
            invitee: accountSelect,
            church: { select: { id: true, name: true } },
            column: { select: { id: true, name: true, churchId: true } },
          },
        });

        if (!inv?.id) {
          throw new NotFoundException('Invitation not found');
        }

        return { message: 'OK', data: inv };
      }

      case 'admin.membershipInvitation.approve': {
        const auth = this.requireUserId(client);
        if (auth?.role !== 'SUPER_ADMIN') {
          throw new ForbiddenException('Insufficient role');
        }
        const id = payload.id as number;
        if (typeof id !== 'number') {
          throw new BadRequestException('id is required');
        }

        const accountSelect = {
          select: {
            id: true,
            name: true,
            phone: true,
            email: true,
            isActive: true,
            claimed: true,
            gender: true,
            maritalStatus: true,
            dob: true,
            createdAt: true,
            updatedAt: true,
          },
        } as const;

        const invitation: any = await (
          this.prisma as any
        ).membershipInvitation.findUnique({
          where: { id },
          include: {
            inviter: accountSelect,
            invitee: accountSelect,
            church: { select: { id: true, name: true } },
            column: { select: { id: true, name: true, churchId: true } },
          },
        });

        if (!invitation?.id) {
          throw new NotFoundException('Invitation not found');
        }
        if (invitation.status !== 'PENDING') {
          throw new ConflictException('Invitation already resolved');
        }

        const existingMembership: any = await (
          this.prisma as any
        ).membership.findUnique({
          where: { accountId: invitation.inviteeId },
          select: { id: true },
        });
        if (existingMembership?.id) {
          throw new ConflictException('User already has a membership');
        }

        const updatedInvitation = await (this.prisma as any).$transaction(
          async (tx: any) => {
            const column: any = await tx.column.findUnique({
              where: { id: invitation.columnId },
              select: { id: true, churchId: true },
            });
            if (!column?.id) {
              throw new BadRequestException('columnId does not exist');
            }
            if (
              typeof column.churchId !== 'number' ||
              column.churchId !== invitation.churchId
            ) {
              throw new BadRequestException(
                'columnId belongs to a different church',
              );
            }

            await tx.membership.create({
              data: {
                accountId: invitation.inviteeId,
                churchId: invitation.churchId,
                columnId: invitation.columnId,
                baptize: invitation.baptize === true,
                sidi: invitation.sidi === true,
              },
              select: { id: true },
            });

            return tx.membershipInvitation.update({
              where: { id: invitation.id },
              data: {
                status: 'APPROVED',
                rejectedAt: null,
                rejectedReason: null,
              },
              include: {
                inviter: accountSelect,
                invitee: accountSelect,
                church: { select: { id: true, name: true } },
                column: { select: { id: true, name: true, churchId: true } },
              },
            });
          },
        );

        return { message: 'OK', data: updatedInvitation };
      }

      case 'admin.membershipInvitation.reject': {
        const auth = this.requireUserId(client);
        if (auth?.role !== 'SUPER_ADMIN') {
          throw new ForbiddenException('Insufficient role');
        }
        const id = payload.id as number;
        const rejectedReason =
          (payload.rejectedReason as string | undefined) ??
          (payload.reason as string | undefined) ??
          (payload.dto?.rejectedReason as string | undefined) ??
          (payload.dto?.reason as string | undefined);

        if (typeof id !== 'number') {
          throw new BadRequestException('id is required');
        }

        const accountSelect = {
          select: {
            id: true,
            name: true,
            phone: true,
            email: true,
            isActive: true,
            claimed: true,
            gender: true,
            maritalStatus: true,
            dob: true,
            createdAt: true,
            updatedAt: true,
          },
        } as const;

        const invitation: any = await (
          this.prisma as any
        ).membershipInvitation.findUnique({
          where: { id },
          select: { id: true, status: true },
        });
        if (!invitation?.id) {
          throw new NotFoundException('Invitation not found');
        }
        if (invitation.status !== 'PENDING') {
          throw new ConflictException('Invitation already resolved');
        }

        const trimmed =
          typeof rejectedReason === 'string' ? rejectedReason.trim() : '';
        const updated = await (this.prisma as any).membershipInvitation.update({
          where: { id },
          data: {
            status: 'REJECTED',
            rejectedAt: new Date(),
            rejectedReason: trimmed.length > 0 ? trimmed : null,
          },
          include: {
            inviter: accountSelect,
            invitee: accountSelect,
            church: { select: { id: true, name: true } },
            column: { select: { id: true, name: true, churchId: true } },
          },
        });

        return { message: 'OK', data: updated };
      }

      case 'admin.membershipInvitation.delete': {
        const auth = this.requireUserId(client);
        if (auth?.role !== 'SUPER_ADMIN') {
          throw new ForbiddenException('Insufficient role');
        }
        const id = payload.id as number;
        if (typeof id !== 'number') {
          throw new BadRequestException('id is required');
        }
        await (this.prisma as any).membershipInvitation.delete({
          where: { id },
        });
        return { message: 'OK' };
      }

      // ===== Finance / Revenue / Expense =====
      case 'finance.list': {
        const user = this.requireUserId(client);
        const query = this.withPagination(payload) as any;
        const res: any = await this.financeService.findAll(query, user);
        return this.normalizePaginatedList(query, res);
      }

      case 'finance.overview': {
        const user = this.requireUserId(client);
        return this.financeService.getOverview(user);
      }

      case 'revenue.list': {
        this.requireUserId(client);
        const query = this.withPagination(payload) as any;
        const res: any = await this.revenueService.findAll(query);
        return this.normalizePaginatedList(query, res);
      }

      case 'revenue.get': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.revenueService.findOne(id);
      }

      case 'revenue.create': {
        this.requireUserId(client);
        return this.revenueService.create(payload);
      }

      case 'revenue.update': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.revenueService.update(id, payload.dto ?? {});
      }

      case 'revenue.delete': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.revenueService.remove(id);
      }

      case 'expense.list': {
        this.requireUserId(client);
        const query = this.withPagination(payload) as any;
        const res: any = await this.expenseService.findAll(query);
        return this.normalizePaginatedList(query, res);
      }

      case 'expense.get': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.expenseService.findOne(id);
      }

      case 'expense.create': {
        this.requireUserId(client);
        return this.expenseService.create(payload);
      }

      case 'expense.update': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.expenseService.update(id, payload.dto ?? {});
      }

      case 'expense.delete': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.expenseService.remove(id);
      }

      // ===== Cash =====
      case 'cashAccount.list': {
        const user = this.requireUserId(client);
        const query = this.withPagination(payload) as any;
        const res: any = await this.cashAccountService.findAll(query, user);
        return this.normalizePaginatedList(query, res);
      }

      case 'cashAccount.get': {
        const user = this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.cashAccountService.findOne(id, user);
      }

      case 'cashAccount.create': {
        const user = this.requireUserId(client);
        return this.cashAccountService.create(payload, user);
      }

      case 'cashAccount.update': {
        const user = this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.cashAccountService.update(id, payload.dto ?? {}, user);
      }

      case 'cashAccount.delete': {
        const user = this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.cashAccountService.remove(id, user);
      }

      case 'cashMutation.list': {
        const user = this.requireUserId(client);
        const query = this.withPagination(payload) as any;
        const res: any = await this.cashMutationService.findAll(query, user);
        return this.normalizePaginatedList(query, res);
      }

      case 'cashMutation.get': {
        const user = this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.cashMutationService.findOne(id, user);
      }

      case 'cashMutation.create': {
        const user = this.requireUserId(client);
        return this.cashMutationService.create(payload, user);
      }

      case 'cashMutation.transfer': {
        const user = this.requireUserId(client);
        return this.cashMutationService.transfer(payload, user);
      }

      case 'cashMutation.delete': {
        const user = this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.cashMutationService.remove(id, user);
      }

      case 'report.list': {
        this.requireUserId(client);
        const query = this.withPagination(payload) as any;
        const res: any = await this.reportService.getReports(
          query,
          this.getAuthContext(client),
        );
        if (res && Array.isArray(res.data) && typeof res.total === 'number') {
          return {
            message: res.message,
            data: res.data,
            pagination: this.toPaginationMeta(query, res.total),
          };
        }
        return res;
      }

      case 'report.get': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.reportService.findOne(id);
      }

      case 'report.create': {
        this.requireUserId(client);
        return this.reportService.create(payload);
      }

      case 'report.update': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.reportService.update(id, payload.dto ?? {});
      }

      case 'report.delete': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.reportService.remove(id);
      }

      case 'report.generate': {
        const user = this.requireUserId(client);
        return this.reportQueueService.createJob(payload, user);
      }

      case 'reportJob.list': {
        const user = this.requireUserId(client);
        return this.reportQueueService.getMyJobs(
          this.withPagination(payload),
          user,
        );
      }

      case 'reportJob.get': {
        const user = this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.reportQueueService.getJobStatus(id, user);
      }

      case 'reportJob.cancel': {
        const user = this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.reportQueueService.cancelJob(id, user);
      }

      // ===== Document =====
      case 'document.list': {
        this.requireUserId(client);
        const query = this.withPagination(payload) as any;
        const res: any = await this.documentService.getDocuments(query);
        return this.normalizePaginatedList(query, res);
      }

      case 'document.get': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.documentService.findOne(id);
      }

      case 'document.create': {
        this.requireUserId(client);
        return this.documentService.create(payload);
      }

      case 'document.update': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.documentService.update(id, payload.dto ?? {});
      }

      case 'document.delete': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.documentService.remove(id);
      }

      // ===== File Manager (temporary; WS streaming will replace resolveDownloadUrl/proxy) =====
      case 'file.list': {
        this.requireUserId(client);
        const query = this.withPagination(payload) as any;
        const res: any = await this.fileService.getFiles(query);
        return this.normalizePaginatedList(query, res);
      }

      case 'file.get': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.fileService.findOne(id);
      }

      case 'file.finalize': {
        const user = this.requireUserId(client);
        return this.fileService.finalize(payload, user);
      }

      case 'file.upload.init': {
        const user = this.requireUserId(client);
        const socketId = client?.id as string;
        const churchId = payload.churchId as number;
        const sizeBytes = payload.sizeBytes as number;
        const contentType = payload.contentType as string | undefined;
        const originalName = payload.originalName as string | undefined;

        if (typeof churchId !== 'number') {
          throw new BadRequestException('churchId is required');
        }
        if (typeof sizeBytes !== 'number' || sizeBytes <= 0) {
          throw new BadRequestException('sizeBytes is required');
        }
        if (sizeBytes > this.MAX_FILE_BYTES) {
          throw new BadRequestException('File too large');
        }

        const membership = await (this.prisma as any).membership.findUnique({
          where: { accountId: user.userId },
          select: { churchId: true },
        });
        if (!membership?.churchId || membership.churchId !== churchId) {
          throw new BadRequestException('Invalid church context');
        }

        const bucketName =
          (payload.bucket as string | undefined) ??
          process.env.FIREBASE_STORAGE_BUCKET;
        if (!bucketName) {
          throw new BadRequestException('Bucket is required');
        }

        const path = this.buildUploadPath(churchId, originalName);
        const uploadId = randomBytes(16).toString('hex');
        const bucket = this.firebaseAdmin.bucket(bucketName);
        const fileRef = bucket.file(path);

        const canStream =
          typeof (fileRef as any).createWriteStream === 'function';
        const writeStream = canStream
          ? (fileRef as any).createWriteStream({
              resumable: false,
              contentType: contentType || undefined,
              metadata: {
                metadata: {
                  churchId: String(churchId),
                  originalName: originalName ?? '',
                },
              },
            })
          : null;

        const session = {
          uploadId,
          socketId,
          churchId,
          bucketName,
          path,
          contentType,
          originalName,
          sizeBytes,
          receivedBytes: 0,
          writeStream,
          buffers: [] as Buffer[],
        };
        this.uploadSessions.set(uploadId, session);
        this.trackSocketSession(socketId, 'upload', uploadId);

        return {
          message: 'OK',
          data: {
            uploadId,
            chunkSize: this.CHUNK_BYTES,
            maxBytes: this.MAX_FILE_BYTES,
            bucket: bucketName,
            path,
          },
        };
      }

      case 'file.upload.chunk': {
        this.requireUserId(client);
        const socketId = client?.id as string;
        const uploadId = payload.uploadId as string;
        const dataBase64 = payload.dataBase64 as string;
        if (!uploadId || typeof uploadId !== 'string') {
          throw new BadRequestException('uploadId is required');
        }
        if (!dataBase64 || typeof dataBase64 !== 'string') {
          throw new BadRequestException('dataBase64 is required');
        }

        const session = this.uploadSessions.get(uploadId);
        if (!session || session.socketId !== socketId) {
          throw new BadRequestException('Invalid uploadId');
        }

        const buf = Buffer.from(dataBase64, 'base64');
        if (buf.length === 0) {
          throw new BadRequestException('Empty chunk');
        }
        if (buf.length > this.CHUNK_BYTES) {
          throw new BadRequestException('Chunk too large');
        }

        session.receivedBytes += buf.length;
        if (session.receivedBytes > session.sizeBytes) {
          throw new BadRequestException('Received too many bytes');
        }
        if (session.receivedBytes > this.MAX_FILE_BYTES) {
          throw new BadRequestException('File too large');
        }

        if (session.writeStream) {
          const ok = session.writeStream.write(buf);
          if (!ok) {
            await new Promise<void>((resolve, reject) => {
              session.writeStream.once('drain', resolve);
              session.writeStream.once('error', reject);
            });
          }
        } else {
          session.buffers.push(buf);
        }

        return {
          message: 'OK',
          data: {
            receivedBytes: session.receivedBytes,
            totalBytes: session.sizeBytes,
          },
        };
      }

      case 'file.upload.complete': {
        const user = this.requireUserId(client);
        const socketId = client?.id as string;
        const uploadId = payload.uploadId as string;
        if (!uploadId || typeof uploadId !== 'string') {
          throw new BadRequestException('uploadId is required');
        }

        const session = this.uploadSessions.get(uploadId);
        if (!session || session.socketId !== socketId) {
          throw new BadRequestException('Invalid uploadId');
        }

        if (session.receivedBytes !== session.sizeBytes) {
          throw new BadRequestException('Incomplete upload');
        }

        if (session.writeStream) {
          await new Promise<void>((resolve, reject) => {
            session.writeStream.end();
            session.writeStream.once('finish', resolve);
            session.writeStream.once('error', reject);
          });
        } else {
          const bucket = this.firebaseAdmin.bucket(session.bucketName);
          const fileRef = bucket.file(session.path);
          const buffer = Buffer.concat(session.buffers);
          await (fileRef as any).save(buffer, {
            resumable: false,
            contentType: session.contentType || undefined,
            metadata: {
              metadata: {
                churchId: String(session.churchId),
                originalName: session.originalName ?? '',
              },
            },
          });
        }

        const sizeInKB = Number((session.sizeBytes / 1024).toFixed(2));
        const finalized = await this.fileService.finalize(
          {
            churchId: session.churchId,
            bucket: session.bucketName,
            path: session.path,
            sizeInKB,
            contentType: session.contentType,
            originalName: session.originalName,
          },
          user,
        );

        this.uploadSessions.delete(uploadId);
        return finalized;
      }

      case 'file.upload.abort': {
        this.requireUserId(client);
        const socketId = client?.id as string;
        const uploadId = payload.uploadId as string;
        if (!uploadId || typeof uploadId !== 'string') {
          throw new BadRequestException('uploadId is required');
        }
        const session = this.uploadSessions.get(uploadId);
        if (session && session.socketId === socketId) {
          try {
            session.writeStream?.end?.();
          } catch (_) {}
          this.uploadSessions.delete(uploadId);
        }
        return { message: 'OK', data: true };
      }

      case 'public.songDb.meta': {
        const rawFileId =
          (payload as any)?.fileId ?? process.env.SONG_DB_FILE_ID;
        const fileId =
          typeof rawFileId === 'number' ? rawFileId : Number(rawFileId);
        if (typeof fileId !== 'number' || !Number.isFinite(fileId)) {
          throw new BadRequestException('fileId is required');
        }

        let file = await (this.prisma as any).fileManager.findUnique({
          where: { id: fileId },
          select: {
            id: true,
            bucket: true,
            path: true,
            sizeInKB: true,
            contentType: true,
            originalName: true,
            updatedAt: true,
          },
        });

        if (!file) {
          file = await (this.prisma as any).fileManager.findFirst({
            where: {
              path: {
                in: ['db/songs.json', '/db/songs.json'],
              },
            },
            select: {
              id: true,
              bucket: true,
              path: true,
              sizeInKB: true,
              contentType: true,
              originalName: true,
              updatedAt: true,
            },
          });
        }

        if (!file || !this.isPublicSongDbFileRecord(file)) {
          throw new BadRequestException('Song DB file not found');
        }

        return {
          message: 'OK',
          data: {
            fileId: file.id,
            bucket: file.bucket,
            path: file.path,
            sizeInKB: file.sizeInKB,
            contentType: file.contentType,
            originalName: file.originalName,
            updatedAt: file.updatedAt,
          },
        };
      }

      case 'file.download.init': {
        const socketId = client?.id as string;
        const rawFileId = (payload as any)?.fileId;
        const fileId =
          typeof rawFileId === 'number' ? rawFileId : Number(rawFileId);
        if (typeof fileId !== 'number' || !Number.isFinite(fileId)) {
          throw new BadRequestException('fileId is required');
        }

        let file = await (this.prisma as any).fileManager.findUnique({
          where: { id: fileId },
          select: {
            id: true,
            churchId: true,
            bucket: true,
            path: true,
            contentType: true,
            originalName: true,
            sizeInKB: true,
          },
        });

        if (!file) {
          file = await (this.prisma as any).fileManager.findFirst({
            where: {
              path: {
                in: ['db/songs.json', '/db/songs.json'],
              },
            },
            select: {
              id: true,
              churchId: true,
              bucket: true,
              path: true,
              contentType: true,
              originalName: true,
              sizeInKB: true,
            },
          });
        }

        const configuredSongDbIdRaw = process.env.SONG_DB_FILE_ID;
        const configuredSongDbId = configuredSongDbIdRaw
          ? Number(configuredSongDbIdRaw)
          : Number.NaN;
        const defaultSongDbId = 999;
        const allowSongDbFallback =
          !Number.isFinite(configuredSongDbId) ||
          fileId === configuredSongDbId ||
          fileId === defaultSongDbId;

        if (!file && allowSongDbFallback) {
          const bucketName = process.env.FIREBASE_STORAGE_BUCKET;
          const normalizedBucketName =
            bucketName && bucketName.trim().length > 0
              ? bucketName.trim()
              : undefined;
          file = {
            id: fileId,
            churchId: 0,
            bucket: normalizedBucketName,
            path: 'db/songs.json',
            contentType: 'application/json',
            originalName: 'songs.json',
            sizeInKB: 0,
          };
        }

        if (!file) {
          throw new BadRequestException('File not found');
        }

        const isPublicSongDb = this.isPublicSongDbFileRecord(file);
        const user = isPublicSongDb ? undefined : this.requireUserId(client);

        let membershipChurchId: number | undefined;
        if (!isPublicSongDb) {
          const membership = await (this.prisma as any).membership.findUnique({
            where: { accountId: user.userId },
            select: { churchId: true },
          });
          if (!membership?.churchId) {
            throw new BadRequestException('User does not have a membership');
          }
          membershipChurchId = membership.churchId;

          if (file.churchId !== membershipChurchId) {
            throw new BadRequestException('Invalid church context');
          }
        }

        const bucket = this.firebaseAdmin.bucket(file.bucket);
        const fileRef = bucket.file(file.path);
        if (typeof (fileRef as any).createReadStream !== 'function') {
          throw new BadRequestException('Storage streaming is not available');
        }

        const stream = (fileRef as any).createReadStream({
          highWaterMark: this.CHUNK_BYTES,
        });
        const iterator = (stream as any)[Symbol.asyncIterator]();

        const downloadId = randomBytes(16).toString('hex');
        const sizeBytes = Math.ceil((Number(file.sizeInKB ?? 0) || 0) * 1024);
        if (sizeBytes > this.MAX_FILE_BYTES) {
          throw new BadRequestException('File too large');
        }

        this.downloadSessions.set(downloadId, {
          downloadId,
          socketId,
          stream,
          iterator,
          sentBytes: 0,
          public: isPublicSongDb,
        });
        this.trackSocketSession(socketId, 'download', downloadId);

        return {
          message: 'OK',
          data: {
            downloadId,
            fileId,
            chunkSize: this.CHUNK_BYTES,
            sizeBytes,
            contentType: file.contentType,
            originalName: file.originalName,
          },
        };
      }

      case 'file.download.chunk': {
        const socketId = client?.id as string;
        const downloadId = payload.downloadId as string;
        if (!downloadId || typeof downloadId !== 'string') {
          throw new BadRequestException('downloadId is required');
        }

        const session = this.downloadSessions.get(downloadId);
        if (!session || session.socketId !== socketId) {
          throw new BadRequestException('Invalid downloadId');
        }

        if (session.public !== true) {
          this.requireUserId(client);
        }

        const next = await session.iterator.next();
        if (next.done) {
          try {
            session.stream?.destroy?.();
          } catch (_) {}
          this.downloadSessions.delete(downloadId);
          return { message: 'OK', data: { done: true } };
        }

        const chunk: Buffer = next.value;
        session.sentBytes += chunk.length;
        if (session.sentBytes > this.MAX_FILE_BYTES) {
          throw new BadRequestException('File too large');
        }

        return {
          message: 'OK',
          data: {
            done: false,
            dataBase64: chunk.toString('base64'),
          },
        };
      }

      case 'file.download.complete': {
        const socketId = client?.id as string;
        const downloadId = payload.downloadId as string;
        if (!downloadId || typeof downloadId !== 'string') {
          throw new BadRequestException('downloadId is required');
        }
        const session = this.downloadSessions.get(downloadId);

        if (
          session &&
          session.socketId === socketId &&
          session.public !== true
        ) {
          this.requireUserId(client);
        }

        if (session && session.socketId === socketId) {
          try {
            session.stream?.destroy?.();
          } catch (_) {}
          this.downloadSessions.delete(downloadId);
        }
        return { message: 'OK', data: true };
      }

      case 'file.delete': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.fileService.remove(id);
      }

      // ===== Notifications =====
      case 'notifications.list': {
        const user = this.requireUserId(client);
        const membershipId = await this.resolveMembershipIdForUser(user.userId);
        const query = this.withPagination(payload) as any;
        const res: any = await this.notificationService.findAll(
          query,
          membershipId,
        );
        if (res && Array.isArray(res.data) && typeof res.total === 'number') {
          return {
            message: res.message,
            data: res.data,
            pagination: this.toPaginationMeta(query, res.total),
            unreadCount: res.unreadCount,
          };
        }
        return res;
      }

      case 'notifications.get': {
        const user = this.requireUserId(client);
        const membershipId = await this.resolveMembershipIdForUser(user.userId);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.notificationService.findOne(id, membershipId);
      }

      case 'notifications.markRead': {
        const user = this.requireUserId(client);
        const membershipId = await this.resolveMembershipIdForUser(user.userId);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.notificationService.markAsRead(id, membershipId);
      }

      case 'notifications.delete': {
        const user = this.requireUserId(client);
        const membershipId = await this.resolveMembershipIdForUser(user.userId);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.notificationService.remove(id, membershipId);
      }

      // ===== Church =====
      case 'church.list': {
        this.requireUserId(client);
        const query = this.withPagination(payload) as any;
        const res: any = await this.churchService.getChurches(query);
        return this.normalizePaginatedList(query, res);
      }

      // ===== Church Letterhead =====
      case 'churchLetterhead.getMe': {
        const user = this.requireUserId(client);
        return this.churchLetterheadService.getMe(user);
      }

      case 'churchLetterhead.updateMe': {
        const user = this.requireUserId(client);
        return this.churchLetterheadService.updateMe(payload, user);
      }

      case 'churchLetterhead.setLogo': {
        const user = this.requireUserId(client);
        const logoFileId = payload.logoFileId as number;
        if (typeof logoFileId !== 'number') {
          throw new BadRequestException('logoFileId is required');
        }
        return this.churchLetterheadService.setLogoFile(logoFileId, user);
      }

      case 'church.get': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.churchService.findOne(id);
      }

      case 'church.create': {
        this.requireSuperAdminOrClient(client);
        return this.churchService.create(payload);
      }

      case 'church.update': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.churchService.update(id, payload.dto ?? {});
      }

      case 'church.delete': {
        this.requireSuperAdminOrClient(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.churchService.remove(id);
      }

      // ===== Column =====
      case 'column.list': {
        this.requireUserId(client);
        const query = this.withPagination(payload) as any;
        const res: any = await this.columnService.getColumns(query);
        return this.normalizePaginatedList(query, res);
      }

      case 'column.get': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.columnService.findOne(id);
      }

      case 'column.create': {
        this.requireUserId(client);
        return this.columnService.create(payload);
      }

      case 'column.update': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.columnService.update(id, payload.dto ?? {});
      }

      case 'column.delete': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.columnService.remove(id);
      }

      // ===== Location =====
      case 'location.list': {
        this.requireUserId(client);
        const query = this.withPagination(payload) as any;
        const res: any = await this.locationService.findAll(query);
        return this.normalizePaginatedList(query, res);
      }

      case 'location.get': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.locationService.findOne(id);
      }

      case 'location.create': {
        this.requireUserId(client);
        return this.locationService.create(payload);
      }

      case 'location.update': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.locationService.update(id, payload.dto ?? {});
      }

      case 'location.delete': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.locationService.delete(id);
      }

      // ===== Membership Positions =====
      case 'membershipPosition.list': {
        this.requireUserId(client);
        const query = this.withPagination(payload) as any;
        const res: any = await this.membershipPositionService.findAll(query);
        return this.normalizePaginatedList(query, res);
      }

      case 'membershipPosition.get': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.membershipPositionService.findOne(id);
      }

      case 'membershipPosition.create': {
        this.requireUserId(client);
        return this.membershipPositionService.create(payload);
      }

      case 'membershipPosition.update': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.membershipPositionService.update(id, payload.dto ?? {});
      }

      case 'membershipPosition.delete': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.membershipPositionService.delete(id);
      }

      // ===== Approval Rules =====
      case 'approvalRule.list': {
        this.requireUserId(client);
        const query = this.withPagination(payload) as any;
        const res: any = await this.approvalRuleService.getApprovalRules(query);
        return this.normalizePaginatedList(query, res);
      }

      case 'approvalRule.get': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.approvalRuleService.findOne(id);
      }

      case 'approvalRule.create': {
        this.requireUserId(client);
        return this.approvalRuleService.create(payload);
      }

      case 'approvalRule.update': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.approvalRuleService.update(id, payload.dto ?? {});
      }

      case 'approvalRule.delete': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.approvalRuleService.remove(id);
      }

      // ===== Approver =====
      case 'approver.list': {
        const user = this.requireUserId(client);
        const query = this.withPagination(payload) as any;

        const membershipId = await this.resolveMembershipIdForUser(user.userId);
        const membership = await (this.prisma as any).membership.findUnique({
          where: { id: membershipId },
          select: { churchId: true },
        });

        const requesterChurchId = membership?.churchId;
        if (typeof requesterChurchId !== 'number') {
          throw new BadRequestException('Invalid membership church context');
        }

        if (
          query.churchId !== undefined &&
          query.churchId !== null &&
          query.churchId !== requesterChurchId
        ) {
          throw new ForbiddenException(
            'You are not authorized to access approvers for this church',
          );
        }

        query.churchId = requesterChurchId;
        const res: any = await this.approverService.findAll(query);
        return this.normalizePaginatedList(query, res);
      }

      case 'approver.get': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.approverService.findOne(id);
      }

      case 'approver.create': {
        this.requireUserId(client);
        return this.approverService.create(payload);
      }

      case 'approver.update': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.approverService.update(id, payload.dto ?? {});
      }

      case 'approver.delete': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.approverService.remove(id);
      }

      // ===== Financial Account Numbers =====
      case 'financialAccountNumber.list': {
        this.requireUserId(client);
        const query = this.withPagination(payload) as any;
        const churchId = query.churchId as number;
        if (typeof churchId !== 'number')
          throw new BadRequestException('churchId is required');
        const { churchId: _c, ...restQuery } = query;
        const res: any = await this.financialAccountNumberService.findAll(
          restQuery,
          churchId,
        );
        return this.normalizePaginatedList(query, res);
      }

      case 'financialAccountNumber.available': {
        this.requireUserId(client);
        const query = this.withPagination(payload) as any;
        const churchId = query.churchId as number;
        if (typeof churchId !== 'number')
          throw new BadRequestException('churchId is required');
        const { churchId: _c, ...restQuery } = query;
        const res: any =
          await this.financialAccountNumberService.getAvailableAccounts(
            churchId,
            restQuery,
          );
        return this.normalizePaginatedList(query, res);
      }

      case 'financialAccountNumber.get': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.financialAccountNumberService.findOne(id);
      }

      case 'financialAccountNumber.create': {
        this.requireUserId(client);
        const churchId = payload.churchId as number;
        if (typeof churchId !== 'number')
          throw new BadRequestException('churchId is required');
        return this.financialAccountNumberService.create(
          payload.dto ?? payload,
          churchId,
        );
      }

      case 'financialAccountNumber.update': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.financialAccountNumberService.update(id, payload.dto ?? {});
      }

      case 'financialAccountNumber.delete': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.financialAccountNumberService.remove(id);
      }

      // ===== Church Requests =====
      case 'churchRequest.create': {
        const user = this.requireUserId(client);
        return this.churchRequestService.createOrResubmit(user.userId, payload);
      }

      case 'churchRequest.my': {
        const user = this.requireUserId(client);
        return this.churchRequestService.findByRequester(user.userId);
      }

      case 'admin.churchRequest.list': {
        this.requireSuperAdminOrClient(client);
        const query = this.withPagination(payload) as any;
        const res: any = await this.churchRequestService.findAll(query);
        return this.normalizePaginatedList(query, res);
      }

      case 'admin.churchRequest.get': {
        this.requireSuperAdminOrClient(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.churchRequestService.findOne(id);
      }

      case 'admin.churchRequest.update': {
        this.requireSuperAdminOrClient(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.churchRequestService.update(id, payload.dto ?? {});
      }

      case 'admin.churchRequest.delete': {
        this.requireSuperAdminOrClient(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.churchRequestService.remove(id);
      }

      case 'admin.churchRequest.approve': {
        const user = this.requireUserId(client);
        this.requireSuperAdminOrClient(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.churchRequestService.approve(
          id,
          user.userId,
          payload.dto ?? {},
        );
      }

      case 'admin.churchRequest.reject': {
        const user = this.requireUserId(client);
        this.requireSuperAdminOrClient(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.churchRequestService.reject(
          id,
          user.userId,
          payload.dto ?? {},
        );
      }

      // ===== Activities =====
      case 'activity.list': {
        const query = this.withPagination(payload) as any;
        const res: any = await this.activitiesService.findAll(
          query,
          this.getAuthContext(client),
        );
        return this.normalizePaginatedList(query, res);
      }

      case 'activity.get': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.activitiesService.findOne(id);
      }

      case 'activity.create': {
        return this.activitiesService.create(
          payload,
          this.getAuthContext(client),
        );
      }

      case 'activity.update': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.activitiesService.update(id, payload.dto ?? {});
      }

      case 'activity.delete': {
        this.requireUserId(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.activitiesService.remove(id);
      }

      // ===== Songs =====
      case 'songsPublic.list': {
        const query = this.withPagination(payload) as any;
        const res: any = await this.songService.findAllPublic(query);
        return this.normalizePaginatedList(query, res);
      }

      case 'songsPublic.get': {
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.songService.findOnePublic(id);
      }

      case 'admin.songs.list': {
        this.requireSuperAdminOrClient(client);
        const query = this.withPagination(payload) as any;
        const res: any = await this.songService.findAllAdmin(
          query,
          this.getAuthContext(client),
        );
        return this.normalizePaginatedList(query, res);
      }

      case 'admin.songs.get': {
        this.requireSuperAdminOrClient(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.songService.findOneAdmin(id, this.getAuthContext(client));
      }

      case 'admin.songs.create': {
        this.requireSuperAdminOrClient(client);
        return this.songService.create(payload, this.getAuthContext(client));
      }

      case 'admin.songs.update': {
        this.requireSuperAdminOrClient(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.songService.update(
          id,
          payload.dto ?? {},
          this.getAuthContext(client),
        );
      }

      case 'admin.songs.delete': {
        this.requireSuperAdminOrClient(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.songService.delete(id, this.getAuthContext(client));
      }

      case 'admin.songs.publish': {
        const auth = this.requireUserId(client);
        if (auth?.role !== 'SUPER_ADMIN') {
          throw new ForbiddenException('Insufficient role');
        }

        if (!this.firebaseAdmin.isConfigured()) {
          throw new BadRequestException('Firebase Storage is not configured');
        }

        const rawFileId = payload.fileId ?? process.env.SONG_DB_FILE_ID ?? 999;
        const requestedFileId =
          typeof rawFileId === 'number' ? rawFileId : Number(rawFileId);
        if (
          typeof requestedFileId !== 'number' ||
          !Number.isFinite(requestedFileId)
        ) {
          throw new BadRequestException('SONG_DB_FILE_ID is not configured');
        }

        const bucketName = process.env.FIREBASE_STORAGE_BUCKET;
        if (!bucketName || bucketName.trim().length === 0) {
          throw new BadRequestException('FIREBASE_STORAGE_BUCKET is not set');
        }

        let fileRecord = await (this.prisma as any).fileManager.findUnique({
          where: { id: requestedFileId },
          select: {
            id: true,
            churchId: true,
            bucket: true,
            path: true,
            contentType: true,
            originalName: true,
          },
        });

        if (!fileRecord) {
          fileRecord = await (this.prisma as any).fileManager.findFirst({
            where: {
              path: {
                in: ['db/songs.json', '/db/songs.json'],
              },
            },
            select: {
              id: true,
              churchId: true,
              bucket: true,
              path: true,
              contentType: true,
              originalName: true,
            },
          });
        }

        // If a record already exists for db/songs.json, prefer updating it to
        // avoid unique(bucket,path) conflicts when SONG_DB_FILE_ID is mismatched.
        const effectiveFileId =
          typeof fileRecord?.id === 'number' ? fileRecord.id : requestedFileId;

        const configuredChurchIdRaw = process.env.SONG_DB_CHURCH_ID;
        const configuredChurchId = configuredChurchIdRaw
          ? Number(configuredChurchIdRaw)
          : Number.NaN;

        let churchId: number | undefined =
          typeof fileRecord?.churchId === 'number'
            ? fileRecord.churchId
            : undefined;
        if (!churchId && Number.isFinite(configuredChurchId)) {
          churchId = configuredChurchId;
        }
        if (!churchId) {
          const first = await (this.prisma as any).church.findFirst({
            select: { id: true },
          });
          if (first?.id) churchId = first.id;
        }
        if (!churchId || !Number.isFinite(churchId)) {
          throw new BadRequestException(
            'No Church found. Set SONG_DB_CHURCH_ID to an existing church id.',
          );
        }

        const songs = await (this.prisma as any).song.findMany({
          orderBy: [{ book: 'asc' }, { index: 'asc' }],
          include: {
            parts: {
              orderBy: { index: 'asc' },
            },
          },
        });

        const books = this.songDbBooks();
        const now = new Date();

        const payloadJson = {
          version: '1.0.0',
          updatedAt: now.toISOString(),
          books_count: books.length,
          songs_count: Array.isArray(songs) ? songs.length : 0,
          books,
          songs: (Array.isArray(songs) ? songs : []).map((song: any) => {
            const book = song?.book ?? '';
            const bookId = this.songDbBookId(book);
            const parts = Array.isArray(song?.parts) ? song.parts : [];
            const definition = parts.map((p: any) => {
              const type = this.normalizeSongDbPartType(p?.name);
              return {
                type,
                content: (p?.content ?? '').toString(),
              };
            });
            const composition = definition.map((d: any) => d.type);

            return {
              id: `${book}-${song?.index}`,
              bookId,
              bookName: this.songDbBookName(book),
              title: (song?.title ?? '').toString(),
              subTitle: '',
              author: '',
              baseNote: '',
              lastUpdate: song?.updatedAt
                ? new Date(song.updatedAt).toISOString()
                : now.toISOString(),
              publisher: '',
              composition,
              definition,
              urlImage: '',
              urlVideo: (song?.link ?? '').toString(),
            };
          }),
        };

        const rawJson = JSON.stringify(payloadJson, null, 2);
        const buf = Buffer.from(rawJson, 'utf8');
        const sizeInKB = Number((buf.byteLength / 1024).toFixed(2));

        const bucket = this.firebaseAdmin.bucket(bucketName);
        const fileRef = bucket.file('db/songs.json');
        await (fileRef as any).save(buf, {
          resumable: false,
          contentType: 'application/json',
          metadata: {
            metadata: {
              churchId: String(churchId),
              originalName: 'songs.json',
            },
          },
        });

        const updated = await (this.prisma as any).fileManager.upsert({
          where: { id: effectiveFileId },
          update: {
            provider: 'FIREBASE_STORAGE',
            bucket: bucketName,
            path: 'db/songs.json',
            sizeInKB,
            contentType: 'application/json',
            originalName: 'songs.json',
            churchId,
          },
          create: {
            id: effectiveFileId,
            provider: 'FIREBASE_STORAGE',
            bucket: bucketName,
            path: 'db/songs.json',
            sizeInKB,
            contentType: 'application/json',
            originalName: 'songs.json',
            churchId,
          },
          select: {
            id: true,
            updatedAt: true,
            sizeInKB: true,
            bucket: true,
            path: true,
          },
        });

        return {
          message: 'OK',
          data: {
            fileId: updated.id,
            bucket: updated.bucket,
            path: updated.path,
            updatedAt: updated.updatedAt,
            sizeInKB: updated.sizeInKB,
            songsCount: payloadJson.songs_count,
            booksCount: payloadJson.books_count,
          },
        };
      }

      case 'admin.songDb.upload.init': {
        const auth = this.requireUserId(client);
        if (auth?.role !== 'SUPER_ADMIN') {
          throw new ForbiddenException('Insufficient role');
        }

        if (!this.firebaseAdmin.isConfigured()) {
          throw new BadRequestException('Firebase Storage is not configured');
        }

        const socketId = client?.id as string;
        const sizeBytes = payload.sizeBytes as number;
        const contentType = payload.contentType as string | undefined;
        const originalName = payload.originalName as string | undefined;

        if (typeof sizeBytes !== 'number' || sizeBytes <= 0) {
          throw new BadRequestException('sizeBytes is required');
        }
        if (sizeBytes > this.MAX_FILE_BYTES) {
          throw new BadRequestException('File too large');
        }

        const rawFileId = payload.fileId ?? process.env.SONG_DB_FILE_ID ?? 999;
        const requestedFileId =
          typeof rawFileId === 'number' ? rawFileId : Number(rawFileId);
        if (
          typeof requestedFileId !== 'number' ||
          !Number.isFinite(requestedFileId)
        ) {
          throw new BadRequestException('SONG_DB_FILE_ID is not configured');
        }

        const bucketName = process.env.FIREBASE_STORAGE_BUCKET;
        if (!bucketName || bucketName.trim().length === 0) {
          throw new BadRequestException('FIREBASE_STORAGE_BUCKET is not set');
        }

        let fileRecord = await (this.prisma as any).fileManager.findUnique({
          where: { id: requestedFileId },
          select: { id: true, churchId: true },
        });
        if (!fileRecord) {
          fileRecord = await (this.prisma as any).fileManager.findFirst({
            where: {
              path: {
                in: ['db/songs.json', '/db/songs.json'],
              },
            },
            select: { id: true, churchId: true },
          });
        }

        const effectiveFileId =
          typeof fileRecord?.id === 'number' ? fileRecord.id : requestedFileId;

        const configuredChurchIdRaw = process.env.SONG_DB_CHURCH_ID;
        const configuredChurchId = configuredChurchIdRaw
          ? Number(configuredChurchIdRaw)
          : Number.NaN;

        let churchId: number | undefined =
          typeof fileRecord?.churchId === 'number'
            ? fileRecord.churchId
            : undefined;
        if (!churchId && Number.isFinite(configuredChurchId)) {
          churchId = configuredChurchId;
        }
        if (!churchId) {
          const first = await (this.prisma as any).church.findFirst({
            select: { id: true },
          });
          if (first?.id) churchId = first.id;
        }
        if (!churchId || !Number.isFinite(churchId)) {
          throw new BadRequestException(
            'No Church found. Set SONG_DB_CHURCH_ID to an existing church id.',
          );
        }

        const uploadId = randomBytes(16).toString('hex');
        const bucket = this.firebaseAdmin.bucket(bucketName);
        const path = 'db/songs.json';
        const fileRef = bucket.file(path);

        const canStream =
          typeof (fileRef as any).createWriteStream === 'function';
        const writeStream = canStream
          ? (fileRef as any).createWriteStream({
              resumable: false,
              contentType: contentType || 'application/json',
              metadata: {
                metadata: {
                  churchId: String(churchId),
                  originalName: originalName ?? 'songs.json',
                },
              },
            })
          : null;

        const session = {
          type: 'songDb',
          uploadId,
          socketId,
          requestedFileId,
          effectiveFileId,
          churchId,
          bucketName,
          path,
          contentType: contentType || 'application/json',
          originalName: originalName ?? 'songs.json',
          sizeBytes,
          receivedBytes: 0,
          writeStream,
          buffers: [] as Buffer[],
        };
        this.uploadSessions.set(uploadId, session);
        this.trackSocketSession(socketId, 'upload', uploadId);

        return {
          message: 'OK',
          data: {
            uploadId,
            fileId: effectiveFileId,
            chunkSize: this.CHUNK_BYTES,
            maxBytes: this.MAX_FILE_BYTES,
            bucket: bucketName,
            path,
          },
        };
      }

      case 'admin.songDb.upload.chunk': {
        const auth = this.requireUserId(client);
        if (auth?.role !== 'SUPER_ADMIN') {
          throw new ForbiddenException('Insufficient role');
        }

        const socketId = client?.id as string;
        const uploadId = payload.uploadId as string;
        const dataBase64 = payload.dataBase64 as string;
        if (!uploadId || typeof uploadId !== 'string') {
          throw new BadRequestException('uploadId is required');
        }
        if (!dataBase64 || typeof dataBase64 !== 'string') {
          throw new BadRequestException('dataBase64 is required');
        }

        const session = this.uploadSessions.get(uploadId);
        if (
          !session ||
          session.socketId !== socketId ||
          session.type !== 'songDb'
        ) {
          throw new BadRequestException('Invalid uploadId');
        }

        const buf = Buffer.from(dataBase64, 'base64');
        if (buf.length === 0) {
          throw new BadRequestException('Empty chunk');
        }
        if (buf.length > this.CHUNK_BYTES) {
          throw new BadRequestException('Chunk too large');
        }

        session.receivedBytes += buf.length;
        if (session.receivedBytes > session.sizeBytes) {
          throw new BadRequestException('Received too many bytes');
        }
        if (session.receivedBytes > this.MAX_FILE_BYTES) {
          throw new BadRequestException('File too large');
        }

        if (session.writeStream) {
          const ok = session.writeStream.write(buf);
          if (!ok) {
            await new Promise<void>((resolve, reject) => {
              session.writeStream.once('drain', resolve);
              session.writeStream.once('error', reject);
            });
          }
        } else {
          session.buffers.push(buf);
        }

        return {
          message: 'OK',
          data: {
            receivedBytes: session.receivedBytes,
            totalBytes: session.sizeBytes,
          },
        };
      }

      case 'admin.songDb.upload.complete': {
        const auth = this.requireUserId(client);
        if (auth?.role !== 'SUPER_ADMIN') {
          throw new ForbiddenException('Insufficient role');
        }

        const socketId = client?.id as string;
        const uploadId = payload.uploadId as string;
        if (!uploadId || typeof uploadId !== 'string') {
          throw new BadRequestException('uploadId is required');
        }

        const session = this.uploadSessions.get(uploadId);
        if (
          !session ||
          session.socketId !== socketId ||
          session.type !== 'songDb'
        ) {
          throw new BadRequestException('Invalid uploadId');
        }

        if (session.receivedBytes !== session.sizeBytes) {
          throw new BadRequestException('Incomplete upload');
        }

        let finalBuffer: Buffer | undefined;
        if (session.writeStream) {
          await new Promise<void>((resolve, reject) => {
            session.writeStream.end();
            session.writeStream.once('finish', resolve);
            session.writeStream.once('error', reject);
          });
        } else {
          const bucket = this.firebaseAdmin.bucket(session.bucketName);
          const fileRef = bucket.file(session.path);
          finalBuffer = Buffer.concat(session.buffers);
          await (fileRef as any).save(finalBuffer, {
            resumable: false,
            contentType: session.contentType || 'application/json',
            metadata: {
              metadata: {
                churchId: String(session.churchId),
                originalName: session.originalName ?? 'songs.json',
              },
            },
          });
        }

        if (finalBuffer) {
          try {
            JSON.parse(finalBuffer.toString('utf8'));
          } catch {
            throw new BadRequestException('Invalid JSON');
          }
        }

        const sizeInKB = Number((session.sizeBytes / 1024).toFixed(2));

        let fileRecord = await (this.prisma as any).fileManager.findUnique({
          where: { id: session.requestedFileId },
          select: { id: true },
        });
        if (!fileRecord) {
          fileRecord = await (this.prisma as any).fileManager.findFirst({
            where: {
              path: {
                in: ['db/songs.json', '/db/songs.json'],
              },
            },
            select: { id: true },
          });
        }

        const effectiveFileId =
          typeof fileRecord?.id === 'number'
            ? fileRecord.id
            : session.effectiveFileId;

        const updated = await (this.prisma as any).fileManager.upsert({
          where: { id: effectiveFileId },
          update: {
            provider: 'FIREBASE_STORAGE',
            bucket: session.bucketName,
            path: 'db/songs.json',
            sizeInKB,
            contentType: session.contentType || 'application/json',
            originalName: session.originalName ?? 'songs.json',
            churchId: session.churchId,
          },
          create: {
            id: effectiveFileId,
            provider: 'FIREBASE_STORAGE',
            bucket: session.bucketName,
            path: 'db/songs.json',
            sizeInKB,
            contentType: session.contentType || 'application/json',
            originalName: session.originalName ?? 'songs.json',
            churchId: session.churchId,
          },
          select: {
            id: true,
            updatedAt: true,
            sizeInKB: true,
            bucket: true,
            path: true,
          },
        });

        this.uploadSessions.delete(uploadId);

        this.realtimeEmitter.emitToRoom(
          `church.${session.churchId}`,
          'songDb.updated',
          {
            fileId: updated.id,
            updatedAt: updated.updatedAt,
            sizeInKB: updated.sizeInKB,
          },
        );

        return {
          message: 'OK',
          data: {
            fileId: updated.id,
            bucket: updated.bucket,
            path: updated.path,
            updatedAt: updated.updatedAt,
            sizeInKB: updated.sizeInKB,
          },
        };
      }

      case 'admin.songDb.upload.abort': {
        const auth = this.requireUserId(client);
        if (auth?.role !== 'SUPER_ADMIN') {
          throw new ForbiddenException('Insufficient role');
        }

        const socketId = client?.id as string;
        const uploadId = payload.uploadId as string;
        if (!uploadId || typeof uploadId !== 'string') {
          throw new BadRequestException('uploadId is required');
        }

        const session = this.uploadSessions.get(uploadId);
        if (
          session &&
          session.socketId === socketId &&
          session.type === 'songDb'
        ) {
          try {
            session.writeStream?.end?.();
          } catch (_) {}
          this.uploadSessions.delete(uploadId);
        }

        return { message: 'OK', data: true };
      }

      // ===== Song Parts =====
      case 'admin.songParts.list': {
        this.requireSuperAdminOrClient(client);
        const query = this.withPagination(payload) as any;
        const res: any = await this.songPartService.findAll(
          query,
          this.getAuthContext(client),
        );
        return this.normalizePaginatedList(query, res);
      }

      case 'admin.songParts.get': {
        this.requireSuperAdminOrClient(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.songPartService.findOne(id, this.getAuthContext(client));
      }

      case 'admin.songParts.create': {
        this.requireSuperAdminOrClient(client);
        return this.songPartService.create(
          payload,
          this.getAuthContext(client),
        );
      }

      case 'admin.songParts.update': {
        this.requireSuperAdminOrClient(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.songPartService.update(
          id,
          payload.dto ?? {},
          this.getAuthContext(client),
        );
      }

      case 'admin.songParts.delete': {
        this.requireSuperAdminOrClient(client);
        const id = payload.id as number;
        if (typeof id !== 'number')
          throw new BadRequestException('id is required');
        return this.songPartService.delete(id, this.getAuthContext(client));
      }

      default:
        throw new BadRequestException(`Unknown action: ${action}`);
    }
  }
}
