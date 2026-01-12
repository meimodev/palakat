import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { PrismaService } from '../prisma.service';
import { PusherBeamsService } from './pusher-beams.service';

@Injectable()
export class BirthdayNotificationService {
  private readonly logger = new Logger(BirthdayNotificationService.name);

  constructor(
    private prisma: PrismaService,
    private pusherBeams: PusherBeamsService,
  ) {}

  @Cron('0 7 * * *')
  async sendDailyBirthdayNotifications(): Promise<void> {
    const now = new Date();
    const month = now.getMonth() + 1;
    const day = now.getDate();
    const dateKey = `${now.getFullYear()}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;

    try {
      const churches = await this.prisma.church.findMany({
        select: { id: true },
      });

      for (const church of churches) {
        await this.sendForChurch(church.id, month, day, dateKey);
      }
    } catch (e: any) {
      this.logger.error(`Birthday cron failed: ${e?.message ?? e}`, e?.stack);
    }
  }

  private async sendForChurch(
    churchId: number,
    month: number,
    day: number,
    dateKey: string,
  ): Promise<void> {
    const birthdays: Array<{ membershipId: number; name: string }> = await (
      this.prisma as any
    ).$queryRaw`
        SELECT m.id as "membershipId", a.name as "name"
        FROM "Membership" m
        JOIN "Account" a ON a.id = m."accountId"
        LEFT JOIN "Column" c ON c.id = m."columnId"
        WHERE (m."churchId" = ${churchId} OR c."churchId" = ${churchId})
          AND EXTRACT(MONTH FROM a.dob) = ${month}
          AND EXTRACT(DAY FROM a.dob) = ${day}
      `;

    if (!birthdays || birthdays.length === 0) {
      return;
    }

    const recipients = await (this.prisma as any).membership.findMany({
      where: {
        OR: [{ churchId }, { column: { churchId } }],
        membershipPositions: {
          some: {
            OR: [
              { name: { contains: 'penatua', mode: 'insensitive' } },
              { name: { contains: 'diaken', mode: 'insensitive' } },
            ],
          },
        },
      },
      select: {
        id: true,
      },
    });

    if (!recipients || recipients.length === 0) {
      return;
    }

    for (const birthday of birthdays) {
      for (const recipient of recipients) {
        const recipientInterest =
          this.pusherBeams.formatMembershipBirthdayInterest(recipient.id);

        const title = 'Member Birthday';
        const body = `Today is ${birthday.name}'s birthday`;

        const dedupeKey = `member-birthday:${churchId}:${recipient.id}:${birthday.membershipId}:${dateKey}`;

        try {
          await (this.prisma as any).notification.create({
            data: {
              title,
              body,
              type: 'MEMBER_BIRTHDAY',
              recipient: recipientInterest,
              isRead: false,
              dedupeKey,
              data: {
                type: 'MEMBER_BIRTHDAY',
                birthdayMembershipId: birthday.membershipId,
                birthdayName: birthday.name,
                churchId,
              },
            },
          });
        } catch (e: any) {
          if (e?.code === 'P2002') {
            continue;
          }
          this.logger.error(
            `Failed to create birthday notification (dedupeKey=${dedupeKey}): ${e?.message ?? e}`,
            e?.stack,
          );
          continue;
        }

        await this.pusherBeams.publishToInterests([recipientInterest], {
          title,
          body,
          data: {
            type: 'MEMBER_BIRTHDAY',
            birthdayMembershipId: birthday.membershipId,
            birthdayName: birthday.name,
            churchId,
          },
        });
      }
    }

    this.logger.log(
      `Birthday notifications sent (churchId=${churchId}, birthdays=${birthdays.length}, recipients=${recipients.length})`,
    );
  }
}
