import { Logger, Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { HelperService } from '../common/helper/helper.service';
import { AccountModule } from './account/account.module';
import { ActivitiesModule } from './activity/activity.module';
import { AppController } from './app.controller';
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
import { FinancialAccountNumberModule } from './financial-account-number/financial-account-number.module';
import { LocationModule } from './location/location.module';
import { MembershipPositionModule } from './membership-position/membership-position.module';
import { MembershipModule } from './membership/membership.module';
import { NotificationModule } from './notification/notification.module';
import { PrismaModule } from './prisma.module';
import { ReportModule } from './report/report.module';
import { RevenueModule } from './revenue/revenue.module';
import { SongPartModule } from './song-part/song-part.module';
import { SongModule } from './song/song.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    FirebaseModule,
    AuthModule,
    AccountModule,
    MembershipModule,
    ActivitiesModule,
    ApproverModule,
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
    ChurchRequestModule,
    FinancialAccountNumberModule,
    NotificationModule,
  ],
  controllers: [AppController],
  providers: [AppService, Logger, PrismaExceptionFilter, HelperService],
  exports: [HelperService],
})
export class AppModule {}
