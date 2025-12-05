import { IsInt, Min } from 'class-validator';

export class CreateApproverDto {
  @IsInt()
  @Min(1)
  membershipId: number;

  @IsInt()
  @Min(1)
  activityId: number;
}
