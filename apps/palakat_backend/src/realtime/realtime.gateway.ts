import {
  ConnectedSocket,
  MessageBody,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Logger } from '@nestjs/common';
import { Server } from 'socket.io';
import { RpcRouterService } from './rpc-router.service';
import { RpcRequest } from './realtime.types';

@WebSocketGateway({
  path: '/ws',
  cors: {
    origin: '*',
    credentials: true,
  },
})
export class RealtimeGateway {
  private readonly logger = new Logger(RealtimeGateway.name);

  @WebSocketServer()
  server!: Server;

  constructor(private readonly router: RpcRouterService) {}

  async handleConnection(client: any) {
    const token = client?.handshake?.auth?.token as string | undefined;
    if (token && token.trim().length > 0) {
      const res = await this.router.dispatch(client, {
        id: 'handshake',
        action: 'auth.attach',
        payload: { accessToken: token },
      } as RpcRequest);

      if (!res.ok) {
        try {
          client.disconnect(true);
        } catch (_) {}
        return;
      }
    }
  }

  handleDisconnect(client: any) {
    try {
      (this.router as any).onDisconnect?.(client);
    } catch (_) {}
    const userId = client?.data?.user?.userId;
    if (userId) {
      this.logger.log(`Client disconnected userId=${userId}`);
    }
  }

  @SubscribeMessage('rpc')
  async onRpc(@ConnectedSocket() client: any, @MessageBody() body: RpcRequest) {
    if (!body || typeof body !== 'object') {
      return {
        ok: false,
        id: 'invalid',
        error: { code: 'VALIDATION_ERROR', message: 'Invalid request body' },
      };
    }

    const request: RpcRequest = {
      id: body?.id,
      action: body?.action,
      payload: body?.payload,
      meta: body?.meta,
    };

    if (!request.id || typeof request.id !== 'string') {
      return {
        ok: false,
        id: 'invalid',
        error: { code: 'VALIDATION_ERROR', message: 'id is required' },
      };
    }
    if (!request.action || typeof request.action !== 'string') {
      return {
        ok: false,
        id: request.id,
        error: { code: 'VALIDATION_ERROR', message: 'action is required' },
      };
    }

    return this.router.dispatch(client, request);
  }
}
