import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as PushNotifications from '@pusher/push-notifications-server';

/**
 * Payload structure for push notifications
 */
export interface PushPayload {
  title: string;
  body: string;
  deepLink?: string;
  data?: Record<string, any>;
}

/**
 * Service for interacting with Pusher Beams push notification service.
 *
 * This service handles:
 * - Publishing notifications to device interests
 * - Formatting interest names for different targeting patterns
 * - Error handling and logging for Pusher Beams API calls
 *
 * **Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5**
 */
@Injectable()
export class PusherBeamsService {
  private readonly logger = new Logger(PusherBeamsService.name);
  private beamsClient: PushNotifications | null = null;

  constructor(private configService: ConfigService) {
    let instanceId = this.configService.get<string>('PUSHER_BEAMS_INSTANCE_ID');
    let secretKey = this.configService.get<string>('PUSHER_BEAMS_SECRET_KEY');

    // Remove quotes if present (common .env formatting issue)
    if (instanceId) {
      instanceId = instanceId.replace(/^["']|["']$/g, '');
    }
    if (secretKey) {
      secretKey = secretKey.replace(/^["']|["']$/g, '');
    }

    if (instanceId && secretKey) {
      try {
        this.beamsClient = new PushNotifications({
          instanceId,
          secretKey,
        });
        this.logger.log(
          `Pusher Beams client initialized successfully (Instance: ${instanceId.substring(0, 8)}...)`,
        );
      } catch (error) {
        this.logger.error(
          `Failed to initialize Pusher Beams client: ${error.message}`,
          error.stack,
        );
      }
    } else {
      this.logger.warn(
        'Pusher Beams credentials not configured. Push notifications will be disabled.',
      );
      if (!instanceId) {
        this.logger.warn('Missing: PUSHER_BEAMS_INSTANCE_ID');
      }
      if (!secretKey) {
        this.logger.warn('Missing: PUSHER_BEAMS_SECRET_KEY');
      }
    }
  }

  /**
   * Publishes a notification to the specified device interests.
   *
   * @param interests - Array of interest names to publish to
   * @param payload - The notification payload containing title, body, and optional data
   *
   * **Validates: Requirements 2.4, 2.5**
   */
  async publishToInterests(
    interests: string[],
    payload: PushPayload,
  ): Promise<void> {
    if (!this.beamsClient) {
      this.logger.warn(
        'Pusher Beams client not initialized. Skipping notification.',
      );
      return;
    }

    if (interests.length === 0) {
      this.logger.warn('No interests provided. Skipping notification.');
      return;
    }

    try {
      // For web, deep_link must be a valid URI - we omit it and pass in data instead
      // For mobile (FCM/APNs), we pass the path in data for the app to handle
      const publishRequest = {
        interests,
        web: {
          notification: {
            title: payload.title,
            body: payload.body,
            ...(payload.data && { data: payload.data }),
          },
        },
        fcm: {
          notification: {
            title: payload.title,
            body: payload.body,
          },
          data: {
            ...(payload.deepLink && { deep_link: payload.deepLink }),
            ...(payload.data || {}),
          },
        },
        apns: {
          aps: {
            alert: {
              title: payload.title,
              body: payload.body,
            },
          },
          data: {
            ...(payload.deepLink && { deep_link: payload.deepLink }),
            ...(payload.data || {}),
          },
        },
      };

      await this.beamsClient.publishToInterests(interests, publishRequest);

      this.logger.log(
        `Notification published to interests: ${interests.join(', ')}`,
      );
    } catch (error) {
      // Log error but don't throw - notifications should not block main operations
      // **Validates: Requirements 2.4**
      this.logger.error(
        `Failed to publish notification to interests [${interests.join(', ')}]: ${error.message}`,
        error.stack,
      );
    }
  }

  /**
   * Formats a BIPRA group interest name.
   *
   * @param churchId - The church ID
   * @param bipra - The BIPRA division (PKB, WKI, PMD, RMJ, ASM)
   * @returns Formatted interest name: church.{churchId}_bipra.{BIPRA}
   *
   * **Validates: Requirements 2.2, 5.1**
   */
  formatBipraInterest(churchId: number, bipra: string): string {
    return `church.${churchId}_bipra.${bipra.toUpperCase()}`;
  }

  /**
   * Formats a membership interest name for individual notifications.
   *
   * @param membershipId - The membership ID
   * @returns Formatted interest name: membership.{membershipId}
   *
   * **Validates: Requirements 2.3, 6.1**
   */
  formatMembershipInterest(membershipId: number): string {
    return `membership.${membershipId}`;
  }

  formatMembershipBirthdayInterest(membershipId: number): string {
    return `membership.${membershipId}.birthday`;
  }

  /**
   * Formats an account interest name for individual notifications.
   *
   * @param accountId - The account ID
   * @returns Formatted interest name: account.{accountId}
   */
  formatAccountInterest(accountId: number): string {
    return `account.${accountId}`;
  }

  /**
   * Formats a church-wide interest name.
   *
   * @param churchId - The church ID
   * @returns Formatted interest name: church.{churchId}
   */
  formatChurchInterest(churchId: number): string {
    return `church.${churchId}`;
  }

  /**
   * Formats a column interest name.
   *
   * @param churchId - The church ID
   * @param columnId - The column ID
   * @returns Formatted interest name: church.{churchId}_column.{columnId}
   */
  formatColumnInterest(churchId: number, columnId: number): string {
    return `church.${churchId}_column.${columnId}`;
  }

  /**
   * Formats a column BIPRA interest name.
   *
   * @param churchId - The church ID
   * @param columnId - The column ID
   * @param bipra - The BIPRA division
   * @returns Formatted interest name: church.{churchId}_column.{columnId}_bipra.{BIPRA}
   */
  formatColumnBipraInterest(
    churchId: number,
    columnId: number,
    bipra: string,
  ): string {
    return `church.${churchId}_column.${columnId}_bipra.${bipra.toUpperCase()}`;
  }

  /**
   * Returns the global interest name for all app users.
   *
   * @returns The global interest name: palakat
   */
  getGlobalInterest(): string {
    return 'palakat';
  }

  /**
   * Checks if the Pusher Beams client is properly initialized.
   *
   * @returns true if the client is initialized, false otherwise
   */
  isInitialized(): boolean {
    return this.beamsClient !== null;
  }
}
