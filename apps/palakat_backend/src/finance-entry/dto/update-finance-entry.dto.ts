import { PartialType } from '@nestjs/mapped-types';
import { CreateFinanceEntryDto } from './create-finance-entry.dto';

export class UpdateFinanceEntryDto extends PartialType(CreateFinanceEntryDto) {}
