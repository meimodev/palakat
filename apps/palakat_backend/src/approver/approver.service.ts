import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Injectable()
export class ApproverService {
  constructor(private prisma: PrismaService) {}
}
