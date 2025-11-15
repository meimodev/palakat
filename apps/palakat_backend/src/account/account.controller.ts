import {
  Controller,
  Get,
  Query,
  Post,
  Body,
  UseGuards,
  Patch,
  ParseIntPipe,
  Delete,
  Param,
  // Patch,
  // Param,
  // Delete,
} from '@nestjs/common';
import { AccountService } from './account.service';
import { Prisma } from '@prisma/client';
import { CreateAccountDto } from './dto/create-account.dto';
import { AuthGuard } from '@nestjs/passport';
import { AccountListQueryDto } from './dto/account-list.dto';
import { AccountCountQueryDto } from './dto/account-count.dto';
import {
  stripKeys,
  transformToIdArrays,
  transformToSetFormat,
} from 'src/utils';

@UseGuards(AuthGuard('jwt'))
@Controller('account')
export class AccountController {
  constructor(private readonly accountService: AccountService) {}

  @Get('count')
  async count(@Query() query: AccountCountQueryDto) {
    return this.accountService.count(query);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    // Try to parse as number for accountId, otherwise treat as phone
    const numericId = parseInt(id, 10);
    const identifier =
      !isNaN(numericId) && numericId.toString() === id
        ? { accountId: numericId }
        : { phone: id };

    return this.accountService.findOne(identifier);
  }

  @Get()
  async findAll(@Query() query: AccountListQueryDto) {
    return this.accountService.findAll(query);
  }

  @Post()
  create(@Body() createAccountDto: CreateAccountDto) {
    const { membership, ...rest } = createAccountDto as any;
    const data: Prisma.AccountCreateInput = {
      ...rest,
      ...(membership ? { membership } : {}),
    } as any;

    if (data.dob && !data.dob.toString().endsWith('Z')) {
      data.dob = data.dob.toString() + 'Z';
    }

    const payload = transformToIdArrays(data, [
      'church',
      'column',
      'membershipPositions',
    ]);

    return this.accountService.create(payload);
  }

  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateAccountDto: Prisma.AccountUpdateInput,
  ) {
    const transformed = transformToIdArrays(updateAccountDto, [
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

  @Delete(':id')
  delete(@Param('id', ParseIntPipe) id: number) {
    return this.accountService.delete(id);
  }
}
