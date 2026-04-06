import { Injectable, Logger } from '@nestjs/common';
import { RealtimeGateway } from './realtime.gateway';

type ActivityRealtimeEventName =
  | 'activity.created'
  | 'activity.updated'
  | 'activity.deleted';

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

  emitToSocketId(socketId: string, event: string, payload: unknown) {
    if (!socketId || socketId.trim().length === 0) return;

    const server = this.gateway.server;
    if (!server) {
      this.logger.warn('Socket server not ready; dropping event');
      return;
    }

    server.to(socketId).emit(event, payload);
  }

  emitActivityEvent(params: {
    eventName: ActivityRealtimeEventName;
    activityId: number;
    churchId: number;
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
        ...(this.normalizeUpdatedAt(params.updatedAt) != null
          ? { updatedAt: this.normalizeUpdatedAt(params.updatedAt) }
          : {}),
      },
    };

    this.emitToRoom(`church.${params.churchId}`, params.eventName, payload);
  }
}
