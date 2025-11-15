import { Logger, Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { PrismaModule } from 'nestjs-prisma';
import { AccountModule } from './account/account.module';
import { PrismaExceptionFilter } from './exception.filter';
import { MembershipModule } from './membership/membership.module';
import { ActivitiesModule } from './activity/activity.module';
import { ChurchModule } from './church/church.module';
import { HelperService } from '../common/helper/helper.service';
import { SongModule } from './song/song.module';
import { SongPartModule } from './song-part/song-part.module';
import { ColumnModule } from './column/column.module';
import { MembershipPositionModule } from './membership-position/membership-position.module';
import { LocationModule } from './location/location.module';
import { RevenueModule } from './revenue/revenue.module';
import { ExpenseModule } from './expense/expense.module';
import { FileModule } from './file/file.module';
import { ReportModule } from './report/report.module';
import { DocumentModule } from './document/document.module';
import { ApprovalRuleModule } from './approval-rule/approval-rule.module';

@Module({
  imports: [
    PrismaModule.forRoot({ isGlobal: true }),
    AuthModule,
    AccountModule,
    MembershipModule,
    ActivitiesModule,
    ChurchModule,
    SongModule,
    ColumnModule,
    SongPartModule,
    MembershipPositionModule,
    LocationModule,
    RevenueModule,
    ExpenseModule,
    FileModule,
    ReportModule,
    DocumentModule,
    ApprovalRuleModule,
  ],
  controllers: [AppController],
  providers: [AppService, Logger, PrismaExceptionFilter, HelperService],
  exports: [HelperService],
})
export class AppModule {}
