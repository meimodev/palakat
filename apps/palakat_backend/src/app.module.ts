import { Logger, Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ScheduleModule } from '@nestjs/schedule';
import { HelperService } from '../common/helper/helper.service';
import { AccountModule } from './account/account.module';
import { ActivitiesModule } from './activity/activity.module';
import { AppService } from './app.service';
import { ApprovalRuleModule } from './approval-rule/approval-rule.module';
import { ApproverModule } from './approver/approver.module';
import { AuthModule } from './auth/auth.module';
import { ChurchRequestModule } from './church-request/church-request.module';
import { ChurchModule } from './church/church.module';
import { ColumnModule } from './column/column.module';
import { DocumentModule } from './document/document.module';
import { PrismaExceptionFilter } from './exception.filter';
import { ExpenseModule } from './expense/expense.module';
import { FirebaseModule } from './firebase/firebase.module';
import { FileModule } from './file/file.module';
import { ArticleModule } from './article/article.module';
import { FinancialAccountNumberModule } from './financial-account-number/financial-account-number.module';
import { CashModule } from './cash/cash.module';
import { LocationModule } from './location/location.module';
import { MembershipPositionModule } from './membership-position/membership-position.module';
import { MembershipModule } from './membership/membership.module';
import { NotificationModule } from './notification/notification.module';
import { PrismaModule } from './prisma.module';
import { ReportModule } from './report/report.module';
import { RevenueModule } from './revenue/revenue.module';
import { SongPartModule } from './song-part/song-part.module';
import { SongModule } from './song/song.module';
import { ChurchLetterheadModule } from './church-letterhead/church-letterhead.module';
import { FinanceModule } from './finance/finance.module';
import { RealtimeModule } from './realtime/realtime.module';
import { VerifyModule } from './verify/verify.module';
import { ChurchPermissionPolicyModule } from './church-permission-policy/church-permission-policy.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    ScheduleModule.forRoot(),
    PrismaModule,
    FirebaseModule,
    AuthModule,
    RealtimeModule,
    AccountModule,
    MembershipModule,
    ActivitiesModule,
    ApproverModule,
    ChurchModule,
    ChurchLetterheadModule,
    ChurchPermissionPolicyModule,
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
    ArticleModule,
    ApprovalRuleModule,
    ChurchRequestModule,
    FinancialAccountNumberModule,
    CashModule,
    FinanceModule,
    NotificationModule,
    VerifyModule,
  ],
  providers: [AppService, Logger, PrismaExceptionFilter, HelperService],
  exports: [HelperService],
})
export class AppModule {}
