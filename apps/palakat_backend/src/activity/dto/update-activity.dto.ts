import { OmitType, PartialType } from '@nestjs/mapped-types';
import { CreateActivityDto } from './create-activity.dto';

class UpdateActivityBaseDto extends OmitType(CreateActivityDto, [
  'finances',
] as const) {}

export class UpdateActivityDto extends PartialType(UpdateActivityBaseDto) {}
