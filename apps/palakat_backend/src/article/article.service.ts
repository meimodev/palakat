import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { randomUUID } from 'crypto';
import {
  AccountRole,
  ArticleStatus,
  ArticleType,
  Prisma,
} from '../generated/prisma/client';
import { PrismaService } from '../prisma.service';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import { ArticleListQueryDto } from './dto/article-list.dto';
import { AdminArticleListQueryDto } from './dto/admin-article-list.dto';
import { CreateArticleDto } from './dto/create-article.dto';
import { UpdateArticleDto } from './dto/update-article.dto';

@Injectable()
export class ArticleService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly firebaseAdmin: FirebaseAdminService,
  ) {}

  private assertAdmin(user?: any) {
    const isClient = !!user?.clientId;
    const isSuperAdmin = user?.role === AccountRole.SUPER_ADMIN;
    if (!isClient && !isSuperAdmin) {
      throw new ForbiddenException('Super admin token required');
    }
  }

  private async assertMember(userId: number) {
    const membership = await (this.prisma as any).membership.findUnique({
      where: { accountId: userId },
      select: { id: true },
    });
    if (!membership) {
      throw new BadRequestException('User does not have a membership');
    }
    return membership.id;
  }

  private slugify(input: string): string {
    return input
      .toLowerCase()
      .trim()
      .replace(/[^a-z0-9\s-]/g, '')
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-');
  }

  private async ensureUniqueSlug(slugBase: string, excludeId?: number) {
    const normalized = this.slugify(slugBase);
    if (!normalized) {
      throw new BadRequestException('Invalid slug');
    }

    let slug = normalized;
    let counter = 2;

    while (true) {
      const existing = await this.prisma.article.findFirst({
        where: {
          slug,
          ...(excludeId ? { id: { not: excludeId } } : {}),
        },
        select: { id: true },
      });
      if (!existing) return slug;
      slug = `${normalized}-${counter}`;
      counter++;
    }
  }

  async findAllPublic(query: ArticleListQueryDto) {
    const {
      search,
      type,
      skip,
      take,
      sortBy = 'publishedAt',
      sortOrder = 'desc',
    } = query;

    const where: Prisma.ArticleWhereInput = {
      status: ArticleStatus.PUBLISHED,
      publishedAt: { not: null },
    };

    if (type) {
      where.type = type;
    }

    if (search && search.trim().length >= 3) {
      const q = search.trim();
      where.OR = [
        { title: { contains: q, mode: 'insensitive' } },
        { excerpt: { contains: q, mode: 'insensitive' } },
      ];
    }

    const [total, articles] = await this.prisma.$transaction([
      this.prisma.article.count({ where }),
      this.prisma.article.findMany({
        where,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },
        select: {
          id: true,
          type: true,
          title: true,
          slug: true,
          excerpt: true,
          coverImageUrl: true,
          publishedAt: true,
          likesCount: true,
          createdAt: true,
          updatedAt: true,
        },
      }),
    ]);

    return {
      message: 'OK',
      data: articles,
      total,
    };
  }

  async findOnePublic(id: number) {
    const article = await this.prisma.article.findFirst({
      where: { id, status: ArticleStatus.PUBLISHED },
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

    if (!article) {
      throw new NotFoundException('Article not found');
    }

    return {
      message: 'OK',
      data: article,
    };
  }

  async like(articleId: number, userId: number) {
    await this.assertMember(userId);

    const article = await this.prisma.article.findFirst({
      where: { id: articleId, status: ArticleStatus.PUBLISHED },
      select: { id: true, likesCount: true },
    });

    if (!article) {
      throw new NotFoundException('Article not found');
    }

    const existing = await this.prisma.articleLike.findUnique({
      where: {
        articleId_accountId: {
          articleId,
          accountId: userId,
        },
      },
      select: { id: true },
    });

    if (existing) {
      return {
        message: 'OK',
        data: {
          liked: true,
          likesCount: article.likesCount,
        },
      };
    }

    const [, updated] = await this.prisma.$transaction([
      this.prisma.articleLike.create({
        data: {
          article: { connect: { id: articleId } },
          account: { connect: { id: userId } },
        },
        select: { id: true },
      }),
      this.prisma.article.update({
        where: { id: articleId },
        data: { likesCount: { increment: 1 } },
        select: { likesCount: true },
      }),
    ]);

    return {
      message: 'OK',
      data: {
        liked: true,
        likesCount: updated.likesCount,
      },
    };
  }

  async unlike(articleId: number, userId: number) {
    await this.assertMember(userId);

    const existing = await this.prisma.articleLike.findUnique({
      where: {
        articleId_accountId: {
          articleId,
          accountId: userId,
        },
      },
      select: { id: true },
    });

    if (!existing) {
      const article = await this.prisma.article.findUnique({
        where: { id: articleId },
        select: { likesCount: true },
      });
      return {
        message: 'OK',
        data: {
          liked: false,
          likesCount: article?.likesCount ?? 0,
        },
      };
    }

    const [, updated] = await this.prisma.$transaction([
      this.prisma.articleLike.delete({
        where: { id: existing.id },
        select: { id: true },
      }),
      this.prisma.article.update({
        where: { id: articleId },
        data: { likesCount: { decrement: 1 } },
        select: { likesCount: true },
      }),
    ]);

    return {
      message: 'OK',
      data: {
        liked: false,
        likesCount: Math.max(0, updated.likesCount),
      },
    };
  }

  async findAllAdmin(query: AdminArticleListQueryDto, user?: any) {
    this.assertAdmin(user);

    const {
      search,
      type,
      status,
      skip,
      take,
      sortBy = 'updatedAt',
      sortOrder = 'desc',
    } = query;

    const where: Prisma.ArticleWhereInput = {};

    if (type) {
      where.type = type;
    }

    if (status) {
      where.status = status;
    }

    if (search && search.trim().length >= 3) {
      const q = search.trim();
      where.OR = [
        { title: { contains: q, mode: 'insensitive' } },
        { excerpt: { contains: q, mode: 'insensitive' } },
        { slug: { contains: q, mode: 'insensitive' } },
      ];
    }

    const [total, articles] = await this.prisma.$transaction([
      this.prisma.article.count({ where }),
      this.prisma.article.findMany({
        where,
        take,
        skip,
        orderBy: { [sortBy]: sortOrder },
        select: {
          id: true,
          type: true,
          status: true,
          title: true,
          slug: true,
          excerpt: true,
          coverImageUrl: true,
          publishedAt: true,
          likesCount: true,
          createdAt: true,
          updatedAt: true,
        },
      }),
    ]);

    return {
      message: 'OK',
      data: articles,
      total,
    };
  }

  async findOneAdmin(id: number, user?: any) {
    this.assertAdmin(user);

    const article = await this.prisma.article.findUnique({
      where: { id },
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

    if (!article) {
      throw new NotFoundException('Article not found');
    }

    return {
      message: 'OK',
      data: article,
    };
  }

  async create(dto: CreateArticleDto, user?: any) {
    this.assertAdmin(user);

    const desiredSlug = dto.slug?.trim().length ? dto.slug.trim() : dto.title;
    const slug = await this.ensureUniqueSlug(desiredSlug);

    const created = await this.prisma.article.create({
      data: {
        type: dto.type,
        title: dto.title,
        slug,
        excerpt: dto.excerpt ?? null,
        content: dto.content,
        coverImageUrl: dto.coverImageUrl ?? null,
        status: ArticleStatus.DRAFT,
        publishedAt: null,
      },
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

    return {
      message: 'OK',
      data: created,
    };
  }

  async update(id: number, dto: UpdateArticleDto, user?: any) {
    this.assertAdmin(user);

    const existing = await this.prisma.article.findUnique({
      where: { id },
      select: { id: true, title: true },
    });

    if (!existing) {
      throw new NotFoundException('Article not found');
    }

    const data: Prisma.ArticleUpdateInput = {
      ...(dto.type ? { type: dto.type } : {}),
      ...(dto.title ? { title: dto.title } : {}),
      ...(dto.excerpt !== undefined ? { excerpt: dto.excerpt } : {}),
      ...(dto.content ? { content: dto.content } : {}),
      ...(dto.coverImageUrl !== undefined
        ? { coverImageUrl: dto.coverImageUrl }
        : {}),
    };

    if (dto.slug !== undefined) {
      const base = dto.slug?.trim().length ? dto.slug.trim() : dto.title;
      if (!base) {
        throw new BadRequestException('slug is invalid');
      }
      (data as any).slug = await this.ensureUniqueSlug(base, id);
    }

    const updated = await this.prisma.article.update({
      where: { id },
      data: data as any,
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

    return {
      message: 'OK',
      data: updated,
    };
  }

  async publish(id: number, user?: any) {
    this.assertAdmin(user);

    const updated = await this.prisma.article.update({
      where: { id },
      data: {
        status: ArticleStatus.PUBLISHED,
        publishedAt: new Date(),
      },
      select: { id: true, status: true, publishedAt: true },
    });

    return {
      message: 'OK',
      data: updated,
    };
  }

  async unpublish(id: number, user?: any) {
    this.assertAdmin(user);

    const updated = await this.prisma.article.update({
      where: { id },
      data: {
        status: ArticleStatus.DRAFT,
        publishedAt: null,
      },
      select: { id: true, status: true, publishedAt: true },
    });

    return {
      message: 'OK',
      data: updated,
    };
  }

  async archive(id: number, user?: any) {
    this.assertAdmin(user);

    const updated = await this.prisma.article.update({
      where: { id },
      data: {
        status: ArticleStatus.ARCHIVED,
        publishedAt: null,
      },
      select: { id: true, status: true },
    });

    return {
      message: 'OK',
      data: updated,
    };
  }

  async uploadCover(
    id: number,
    file: {
      buffer?: Buffer;
      mimetype?: string;
      originalname?: string;
      size?: number;
    },
    user?: any,
  ) {
    this.assertAdmin(user);

    if (!this.firebaseAdmin.isConfigured()) {
      throw new BadRequestException('Firebase Storage is not configured');
    }

    if (!file?.buffer?.length) {
      throw new BadRequestException('file is required');
    }

    if (!file.mimetype?.startsWith('image/')) {
      throw new BadRequestException('Only image uploads are supported');
    }

    const existing = await this.prisma.article.findUnique({
      where: { id },
      select: { id: true },
    });
    if (!existing) {
      throw new NotFoundException('Article not found');
    }

    const maxBytes = 5 * 1024 * 1024;
    if ((file.size ?? 0) > maxBytes) {
      throw new BadRequestException('File is too large (max 5MB)');
    }

    const original = file.originalname ?? '';
    const extFromName = original.includes('.')
      ? original.split('.').pop()?.toLowerCase()
      : undefined;
    const extFromMime =
      file.mimetype === 'image/jpeg'
        ? 'jpg'
        : file.mimetype === 'image/png'
          ? 'png'
          : file.mimetype === 'image/webp'
            ? 'webp'
            : undefined;
    const ext = extFromName || extFromMime || 'png';

    const path = `articles/${id}/cover.${ext}`;

    const bucket = this.firebaseAdmin.bucket();
    const object = bucket.file(path);
    const token = randomUUID();
    await object.save(file.buffer, {
      resumable: false,
      metadata: {
        contentType: file.mimetype,
        cacheControl: 'public, max-age=31536000',
        metadata: {
          firebaseStorageDownloadTokens: token,
        },
      },
    });

    const bucketName = bucket.name as string;
    const url = `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(path)}?alt=media&token=${token}`;

    const updated = await this.prisma.article.update({
      where: { id },
      data: {
        coverImageUrl: url,
      },
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

    return {
      message: 'OK',
      data: updated,
    };
  }
}
