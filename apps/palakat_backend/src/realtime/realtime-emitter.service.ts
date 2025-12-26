import { Injectable, Logger } from '@nestjs/common';
import { RealtimeGateway } from './realtime.gateway';

@Injectable()
export class RealtimeEmitterService {
  private readonly logger = new Logger(RealtimeEmitterService.name);

  constructor(private readonly gateway: RealtimeGateway) {}

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
}
