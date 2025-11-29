import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import {
  CreateFinancialAccountNumberDto,
  FindAllFinancialAccountNumberDto,
  UpdateFinancialAccountNumberDto,
} from './dto';

@Injectable()
export class FinancialAccountNumberService {
  constructor(private prisma: PrismaService) {}

  async findAll(query: FindAllFinancialAccountNumberDto, churchId: number) {
    const { search, skip, take, type } = query;

    const where: any = {
      churchId,
    };

    if (type) {
      where.type = type;
    }

    if (search) {
      where.OR = [
        { accountNumber: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [total, data] = await (this.prisma as any).$transaction([
      (this.prisma as any).financialAccountNumber.count({ where }),
      (this.prisma as any).financialAccountNumber.findMany({
        where,
        take,
        skip,
        orderBy: { createdAt: 'desc' },
      }),
    ]);

    return {
      message: 'Financial account numbers retrieved successfully',
      data,
      total,
    };
  }

  async findOne(id: number) {
    const record = await (this.prisma as any).financialAccountNumber.findUnique(
      {
        where: { id },
      },
    );

    if (!record) {
      throw new NotFoundException('Financial account number not found');
    }

    return {
      message: 'Financial account number retrieved successfully',
      data: record,
    };
  }

  async create(dto: CreateFinancialAccountNumberDto, churchId: number) {
    // Check for uniqueness within church
    const existing = await (
      this.prisma as any
    ).financialAccountNumber.findUnique({
      where: {
        churchId_accountNumber: {
          churchId,
          accountNumber: dto.accountNumber,
        },
      },
    });

    if (existing) {
      throw new ConflictException(
        'Account number already exists for this church',
      );
    }

    const record = await (this.prisma as any).financialAccountNumber.create({
      data: {
        accountNumber: dto.accountNumber,
        description: dto.description,
        type: dto.type,
        churchId,
      },
    });

    return {
      message: 'Financial account number created successfully',
      data: record,
    };
  }

  async update(id: number, dto: UpdateFinancialAccountNumberDto) {
    // Check if record exists
    const existing = await (
      this.prisma as any
    ).financialAccountNumber.findUnique({
      where: { id },
    });

    if (!existing) {
      throw new NotFoundException('Financial account number not found');
    }

    // If updating accountNumber, check uniqueness
    if (dto.accountNumber && dto.accountNumber !== existing.accountNumber) {
      const duplicate = await (
        this.prisma as any
      ).financialAccountNumber.findUnique({
        where: {
          churchId_accountNumber: {
            churchId: existing.churchId,
            accountNumber: dto.accountNumber,
          },
        },
      });

      if (duplicate) {
        throw new ConflictException(
          'Account number already exists for this church',
        );
      }
    }

    const record = await (this.prisma as any).financialAccountNumber.update({
      where: { id },
      data: dto,
    });

    return {
      message: 'Financial account number updated successfully',
      data: record,
    };
  }

  async remove(id: number) {
    // Check if record exists
    const existing = await (
      this.prisma as any
    ).financialAccountNumber.findUnique({
      where: { id },
      include: {
        revenues: true,
        expenses: true,
      },
    });

    if (!existing) {
      throw new NotFoundException('Financial account number not found');
    }

    // Check if in use (has any revenues or expenses linked)
    if (existing.revenues.length > 0 || existing.expenses.length > 0) {
      throw new BadRequestException(
        'Cannot delete account number that is in use',
      );
    }

    await (this.prisma as any).financialAccountNumber.delete({
      where: { id },
    });

    return {
      message: 'Financial account number deleted successfully',
    };
  }
}
