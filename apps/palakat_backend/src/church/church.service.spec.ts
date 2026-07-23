import { Test, TestingModule } from '@nestjs/testing';
import { ChurchService } from './church.service';
import { PrismaService } from '../prisma.service';
import { HelperService } from '../../common/helper/helper.service';

/**
 * Phase 5 §9.5 — the palakat_admin poll transport. `getChangeVersion` returns
 * the max `updatedAt` (epoch millis) across the church-scoped tables the admin
 * watches, so the value changes whenever any of them does.
 */
describe('ChurchService.getChangeVersion', () => {
  // The 12 church-scoped models the version aggregates over.
  const models = [
    'revenue',
    'expense',
    'cashMutation',
    'cashAccount',
    'report',
    'membership',
    'document',
    'approvalRule',
    'activity',
    'approver',
    'revenueApprover',
    'expenseApprover',
  ] as const;

  let service: ChurchService;
  let prisma: Record<string, { aggregate: jest.Mock }>;

  const buildService = async (
    maxByModel: Partial<Record<(typeof models)[number], Date | null>>,
  ) => {
    prisma = {};
    for (const model of models) {
      prisma[model] = {
        aggregate: jest.fn().mockResolvedValue({
          _max: { updatedAt: maxByModel[model] ?? null },
        }),
      };
    }

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ChurchService,
        { provide: PrismaService, useValue: prisma },
        { provide: HelperService, useValue: {} },
      ],
    }).compile();
    service = module.get(ChurchService);
  };

  it('returns the latest updatedAt across every watched table, as epoch millis', async () => {
    const newest = new Date('2026-07-23T10:00:00.000Z');
    await buildService({
      revenue: new Date('2026-07-20T00:00:00.000Z'),
      activity: newest, // the newest write is on a relation-scoped table
      expenseApprover: new Date('2026-07-22T00:00:00.000Z'),
    });

    const result = await service.getChangeVersion(12);

    expect(result).toEqual({ version: newest.getTime() });
    // scoped to the requested church
    expect(prisma.revenue.aggregate).toHaveBeenCalledWith(
      expect.objectContaining({ where: { churchId: 12 } }),
    );
  });

  it('is 0 when the church has no rows in any watched table', async () => {
    await buildService({});
    const result = await service.getChangeVersion(99);
    expect(result).toEqual({ version: 0 });
  });
});
