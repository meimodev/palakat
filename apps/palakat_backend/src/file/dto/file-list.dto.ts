import { IsInt, IsOptional, IsString } from 'class-validator';
import { Type } from 'class-transformer';
import { PaginationQueryDto } from '../../../common/pagination/pagination.dto';

export class FileListQueryDto extends PaginationQueryDto {
  @IsOptional()
  @IsString()
  search?: string;

  // Forced to the requester's church by the router. The field existed nowhere
  // before, so `getFiles` had no way to scope and listed every church's files.
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  churchId?: number;
}
