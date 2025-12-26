import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { RealtimeGateway } from './realtime.gateway';
import { RpcRouterService } from './rpc-router.service';
import { RealtimeEmitterService } from './realtime-emitter.service';

@Module({
  imports: [AuthModule],
  providers: [RealtimeGateway, RpcRouterService, RealtimeEmitterService],
  exports: [RealtimeEmitterService],
})
export class RealtimeModule {}
