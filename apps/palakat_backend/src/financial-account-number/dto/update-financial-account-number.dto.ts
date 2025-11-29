import { PartialType } from '@nestjs/mapped-types';
import { CreateFinancialAccountNumberDto } from './create-financial-account-number.dto';

export class UpdateFinancialAccountNumberDto extends PartialType(
  CreateFinancialAccountNumberDto,
) {}
