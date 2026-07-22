import { Injectable, Logger } from '@nestjs/common';
import { RealtimeGateway } from './realtime.gateway';

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

  constructor(private readonly gateway: RealtimeGateway) {}

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

  emitToRoom(room: string, event: string, payload: unknown) {
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
