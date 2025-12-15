/**
 * Unit Tests for ApproverService
 *
 * Tests CRUD operations for the Approver module.
 * _Requirements: 1.1-1.4, 2.1-2.6, 3.1-3.3, 4.1-4.2_
 */

import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException, NotFoundException } from '@nestjs/common';
import { ApproverService } from './approver.service';
import { PrismaService } from '../prisma.service';
import { NotificationService } from '../notification/notification.service';
import { ApprovalStatus } from '@prisma/client';

describe('ApproverService', () => {
  let service: ApproverService;

  // Mock data
  const mockMembership = { id: 1, accountId: 1, churchId: 1 };
  const mockActivity = { id: 1, title: 'Test Activity', supervisorId: 1 };
  const mockApprover = {
    id: 1,
    membershipId: 1,
    activityId: 1,
    status: 'UNCONFIRMED' as ApprovalStatus,
    createdAt: new Date(),
    updatedAt: new Date(),
    activity: {
      id: 1,
      title: 'Test Activity',
      supervisor: {
        id: 1,
        account: { id: 1, name: 'Supervisor', phone: '123' },
      },
    },
    membership: {
      id: 1,
      account: { id: 1, name: 'Member', phone: '456' },
    },
  };

  // Mock PrismaService
  const mockPrismaService = {
    membership: {
      findUnique: jest.fn(),
    },
    activity: {
      findUnique: jest.fn(),
    },
    approver: {
      findUnique: jest.fn(),
      findUniqueOrThrow: jest.fn(),
      findMany: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
      count: jest.fn(),
    },
    $transaction: jest.fn(),
  };

  const mockNotificationService = {
    notifyApprovalStatusChanged: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ApproverService,
        { provide: PrismaService, useValue: mockPrismaService },
        { provide: NotificationService, useValue: mockNotificationService },
      ],
    }).compile();

    service = module.get<ApproverService>(ApproverService);

    // Reset all mocks
    jest.clearAllMocks();
  });

  describe('create', () => {
    it('should create an approver with valid data', async () => {
      mockPrismaService.membership.findUnique.mockResolvedValue(mockMembership);
      mockPrismaService.activity.findUnique.mockResolvedValue(mockActivity);
      mockPrismaService.approver.findUnique.mockResolvedValue(null);
      mockPrismaService.approver.create.mockResolvedValue(mockApprover);

      const result = await service.create({ membershipId: 1, activityId: 1 });

      expect(result.message).toBe('Approver created successfully');
      expect(result.data).toEqual(mockApprover);
      expect(mockPrismaService.approver.create).toHaveBeenCalledWith({
        data: { membershipId: 1, activityId: 1 },
        include: expect.any(Object),
      });
    });

    it('should throw NotFoundException for non-existent membership', async () => {
      mockPrismaService.membership.findUnique.mockResolvedValue(null);

      await expect(
        service.create({ membershipId: 999, activityId: 1 }),
      ).rejects.toThrow(NotFoundException);
      await expect(
        service.create({ membershipId: 999, activityId: 1 }),
      ).rejects.toThrow('Membership with ID 999 not found');
    });

    it('should throw NotFoundException for non-existent activity', async () => {
      mockPrismaService.membership.findUnique.mockResolvedValue(mockMembership);
      mockPrismaService.activity.findUnique.mockResolvedValue(null);

      await expect(
        service.create({ membershipId: 1, activityId: 999 }),
      ).rejects.toThrow(NotFoundException);
      await expect(
        service.create({ membershipId: 1, activityId: 999 }),
      ).rejects.toThrow('Activity with ID 999 not found');
    });

    it('should throw BadRequestException for duplicate approver', async () => {
      mockPrismaService.membership.findUnique.mockResolvedValue(mockMembership);
      mockPrismaService.activity.findUnique.mockResolvedValue(mockActivity);
      mockPrismaService.approver.findUnique.mockResolvedValue(mockApprover);

      await expect(
        service.create({ membershipId: 1, activityId: 1 }),
      ).rejects.toThrow(BadRequestException);
      await expect(
        service.create({ membershipId: 1, activityId: 1 }),
      ).rejects.toThrow(
        'Approver already exists for this activity and membership',
      );
    });
  });

  describe('findAll', () => {
    const mockApprovers = [mockApprover];

    // Helper to create query DTO with computed skip/take
    const createQueryDto = (
      overrides: {
        page?: number;
        pageSize?: number;
        membershipId?: number;
        activityId?: number;
        status?: ApprovalStatus;
      } = {},
    ) => {
      const page = overrides.page ?? 1;
      const pageSize = overrides.pageSize ?? 10;
      return {
        page,
        pageSize,
        membershipId: overrides.membershipId,
        activityId: overrides.activityId,
        status: overrides.status,
        get skip() {
          return (page - 1) * pageSize;
        },
        get take() {
          return pageSize;
        },
      } as any;
    };

    it('should return paginated list without filters', async () => {
      mockPrismaService.$transaction.mockResolvedValue([1, mockApprovers]);

      const result = await service.findAll(createQueryDto());

      expect(result.message).toBe('Approvers retrieved successfully');
      expect(result.data).toEqual(mockApprovers);
      expect(result.total).toBe(1);
    });

    it('should filter by membershipId', async () => {
      mockPrismaService.$transaction.mockResolvedValue([1, mockApprovers]);

      await service.findAll(createQueryDto({ membershipId: 1 }));

      expect(mockPrismaService.$transaction).toHaveBeenCalled();
      const transactionCalls = mockPrismaService.$transaction.mock.calls[0][0];
      expect(transactionCalls).toHaveLength(2);
    });

    it('should filter by activityId', async () => {
      mockPrismaService.$transaction.mockResolvedValue([1, mockApprovers]);

      await service.findAll(createQueryDto({ activityId: 1 }));

      expect(mockPrismaService.$transaction).toHaveBeenCalled();
    });

    it('should filter by status', async () => {
      mockPrismaService.$transaction.mockResolvedValue([1, mockApprovers]);

      await service.findAll(
        createQueryDto({ status: 'APPROVED' as ApprovalStatus }),
      );

      expect(mockPrismaService.$transaction).toHaveBeenCalled();
    });

    it('should apply multiple filters', async () => {
      mockPrismaService.$transaction.mockResolvedValue([1, mockApprovers]);

      await service.findAll(
        createQueryDto({
          membershipId: 1,
          activityId: 1,
          status: 'UNCONFIRMED' as ApprovalStatus,
        }),
      );

      expect(mockPrismaService.$transaction).toHaveBeenCalled();
    });
  });

  describe('findOne', () => {
    it('should return approver by id', async () => {
      mockPrismaService.approver.findUniqueOrThrow.mockResolvedValue(
        mockApprover,
      );

      const result = await service.findOne(1);

      expect(result.message).toBe('Approver retrieved successfully');
      expect(result.data).toEqual(mockApprover);
      expect(mockPrismaService.approver.findUniqueOrThrow).toHaveBeenCalledWith(
        {
          where: { id: 1 },
          include: expect.any(Object),
        },
      );
    });

    it('should throw when approver not found', async () => {
      mockPrismaService.approver.findUniqueOrThrow.mockRejectedValue(
        new Error('Record not found'),
      );

      await expect(service.findOne(999)).rejects.toThrow();
    });
  });

  describe('update', () => {
    const updatedApprover = {
      ...mockApprover,
      status: 'APPROVED' as ApprovalStatus,
    };

    it('should update approver status', async () => {
      mockPrismaService.approver.update.mockResolvedValue(updatedApprover);

      const result = await service.update(1, {
        status: 'APPROVED' as ApprovalStatus,
      });

      expect(result.message).toBe('Approver updated successfully');
      expect(result.data.status).toBe('APPROVED');
      expect(mockPrismaService.approver.update).toHaveBeenCalledWith({
        where: { id: 1 },
        data: { status: 'APPROVED' },
        include: expect.any(Object),
      });
    });

    it('should throw when approver not found', async () => {
      mockPrismaService.approver.update.mockRejectedValue(
        new Error('Record not found'),
      );

      await expect(
        service.update(999, { status: 'APPROVED' as ApprovalStatus }),
      ).rejects.toThrow();
    });
  });

  describe('remove', () => {
    it('should delete approver', async () => {
      mockPrismaService.approver.delete.mockResolvedValue(mockApprover);

      const result = await service.remove(1);

      expect(result.message).toBe('Approver deleted successfully');
      expect(mockPrismaService.approver.delete).toHaveBeenCalledWith({
        where: { id: 1 },
      });
    });

    it('should throw when approver not found', async () => {
      mockPrismaService.approver.delete.mockRejectedValue(
        new Error('Record not found'),
      );

      await expect(service.remove(999)).rejects.toThrow();
    });
  });
});
