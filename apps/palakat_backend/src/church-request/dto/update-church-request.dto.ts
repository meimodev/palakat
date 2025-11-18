import { PartialType } from '@nestjs/mapped-types';
import { CreateChurchRequestDto } from './create-church-request.dto';

export class UpdateChurchRequestDto extends PartialType(
  CreateChurchRequestDto,
) {}
