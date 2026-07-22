import { Injectable, Logger } from '@nestjs/common';
import { FirebaseAdminService } from '../firebase/firebase-admin.service';
import { RealtimeGateway } from './realtime.gateway';
import { buildPushMessage } from './push-payload';

type ActivityRealtimeEventName =
  | 'activity.created'
  | 'activity.updated'
  | 'activity.deleted';

type FinanceRealtimeEventName =
  | 'finance.created'
  | 'finance.updated'
  | 'finance.deleted';

export type ApprovalLifecycleEventName =
  | 'approval.required'
  | 'approval.approved'
  | 'approval.rejected'
  | 'approval.override.approved'
  | 'approval.override.rejected';

@Injectable()
export class RealtimeEmitterService {
  private readonly logger = new Logger(RealtimeEmitterService.name);

  constructor(
    private readonly gateway: RealtimeGateway,
    private readonly firebase: FirebaseAdminService,
  ) {}

  private normalizeUpdatedAt(value: unknown): string | undefined {
    if (value instanceof Date) {
      return value.toISOString();
    }

    if (typeof value === 'string' && value.trim().length > 0) {
      return value;
    }

    return undefined;
  }

  private normalizeMembershipIds(
    membershipIds: Array<number | null | undefined>,
  ): number[] {
    const ids = new Set<number>();

    for (const membershipId of membershipIds) {
      if (typeof membershipId === 'number') {
        ids.add(membershipId);
      }
    }

    return Array.from(ids);
  }

  /**
   * Phase 4. Publishes to an FCM topic — and, for now, still to the socket room.
   * Room names were already valid topic names (§2.3), so nothing is renamed.
   *
   * `payload` is deliberately still `unknown` and deliberately still accepted
   * from callers that pass entity rows — `push-payload.ts` strips it down to
   * the allow-list. Narrowing the type here instead would push the callers to
   * pre-strip, which is thirteen places to get it right rather than one.
   *
   * Never rejects. A push is a hint that a read is due; a failed hint must not
   * roll back the write that earned it.
   *
   * ## Why both transports, for now
   *
   * **Nothing in the repo calls `subscribeToTopic`.** Publishing to FCM topics
   * that have no subscribers delivers to nobody, and the first version of this
   * method dropped the socket emit — which would have silently killed live
   * updates in `palakat_admin` the next time anyone tagged a backend deploy.
   * Seven files there consume `realtimeEventProvider`, and it has been serving
   * production since 2026-03-20 (decision 21).
   *
   * The plan splits Phase 4 (backend transport) from Phase 5 (client subscribe),
   * which leaves a window where the backend has moved and the clients have not.
   * Dual-emit is what makes that window survivable. It adds no exposure: the
   * socket path is authenticated and room-authorized (#56), which is the posture
   * these payloads already had.
   *
   * **Delete the socket half in Phase 5**, once the clients subscribe to topics —
   * and note that `palakat_admin` is Flutter *web* with no `firebase_messaging`
   * dependency at all, so "subscribe to topics" is not one job across the
   * clients (§10.1).
   */
  emitToRoom(room: string, event: string, payload: unknown): void {
    if (!room || room.trim().length === 0) return;

    void this.firebase
      .messaging()
      .send(buildPushMessage(room, event, payload))
      .catch((error) => {
        this.logger.error(
          `Failed to publish ${event} to topic ${room}: ${error?.message}`,
        );
      });

    // Transitional — see above. Delete with Phase 5.
    this.emitToSocketRoom(room, event, payload);
  }

  /**
   * The socket transport, with the full payload. Two callers, for two reasons.
   *
   * **`report-queue.service.ts` calls it directly, and permanently for now.**
   * FCM data messages are best-effort — Android Doze and iOS background
   * throttling batch and delay them. That is the right trade for "something
   * changed, read it when you next look", and the wrong one for a progress bar
   * a user is actively watching (§9.3). Those payloads also carry whole
   * `ReportJob` and `Report` rows, which the push allow-list would strip to an
   * id anyway. §9.3 replaces them with 2-second polling in Phase 5.
   *
   * **`emitToRoom` calls it transitionally**, because nothing subscribes to FCM
   * topics yet — see the note there.
   *
   * When both of those land, this method and the socket gateway go together.
   * It is the last thing holding the socket open.
   */
  emitToSocketRoom(room: string, event: string, payload: unknown): void {
    if (!room || room.trim().length === 0) return;

    const server = this.gateway.server;
    if (!server) {
      this.logger.warn('Socket server not ready; dropping event');
      return;
    }

    server.to(room).emit(event, payload);
  }

  emitActivityEvent(params: {
    eventName: ActivityRealtimeEventName;
    activityId: number;
    churchId: number;
    activityTitle?: string | null;
    changeSource?: 'activity' | 'approval';
    affectedMembershipIds?: Array<number | null | undefined>;
    updatedAt?: unknown;
  }) {
    const affectedMembershipIds = this.normalizeMembershipIds(
      params.affectedMembershipIds ?? [],
    );

    const payload = {
      data: {
        activityId: params.activityId,
        churchId: params.churchId,
        affectedMembershipIds,
        ...(params.activityTitle != null
          ? { activityTitle: params.activityTitle }
          : {}),
        ...(params.changeSource != null
          ? { changeSource: params.changeSource }
          : {}),
        ...(this.normalizeUpdatedAt(params.updatedAt) != null
          ? { updatedAt: this.normalizeUpdatedAt(params.updatedAt) }
          : {}),
      },
    };

    this.emitToRoom(`church.${params.churchId}`, params.eventName, payload);
  }

  emitFinanceEvent(params: {
    eventName: FinanceRealtimeEventName;
    financeId: number;
    financeType: 'REVENUE' | 'EXPENSE';
    churchId: number;
    activityId?: number | null;
    affectedMembershipIds?: Array<number | null | undefined>;
    updatedAt?: unknown;
  }) {
    const affectedMembershipIds = this.normalizeMembershipIds(
      params.affectedMembershipIds ?? [],
    );

    const payload = {
      data: {
        financeId: params.financeId,
        financeType: params.financeType,
        churchId: params.churchId,
        affectedMembershipIds,
        ...(typeof params.activityId === 'number'
          ? { activityId: params.activityId }
          : {}),
        ...(this.normalizeUpdatedAt(params.updatedAt) != null
          ? { updatedAt: this.normalizeUpdatedAt(params.updatedAt) }
          : {}),
      },
    };

    this.emitToRoom(`church.${params.churchId}`, params.eventName, payload);
  }

  /**
   * Emit a dedicated approval lifecycle event with full notification context.
   * Used by admin notifications listener to show in-app banners.
   */
  emitApprovalLifecycleEvent(params: {
    eventName: ApprovalLifecycleEventName;
    entityType: 'ACTIVITY' | 'REVENUE' | 'EXPENSE';
    entityId: number;
    entityTitle?: string | null;
    churchId: number;
    actorName?: string | null;
    resultingStatus: string;
    isOverride: boolean;
    affectedMembershipIds?: Array<number | null | undefined>;
    updatedAt?: unknown;
  }) {
    const affectedMembershipIds = this.normalizeMembershipIds(
      params.affectedMembershipIds ?? [],
    );

    const payload = {
      data: {
        entityType: params.entityType,
        entityId: params.entityId,
        churchId: params.churchId,
        affectedMembershipIds,
        resultingStatus: params.resultingStatus,
        isOverride: params.isOverride,
        ...(params.entityTitle != null
          ? { entityTitle: params.entityTitle }
          : {}),
        ...(params.actorName != null ? { actorName: params.actorName } : {}),
        ...(this.normalizeUpdatedAt(params.updatedAt) != null
          ? { updatedAt: this.normalizeUpdatedAt(params.updatedAt) }
          : {}),
      },
    };

    this.emitToRoom(`church.${params.churchId}`, params.eventName, payload);
  }
}
