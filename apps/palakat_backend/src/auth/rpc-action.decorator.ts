import { SetMetadata } from '@nestjs/common';

export const RPC_ACTION_KEY = 'rpcAction';

/**
 * The RPC action this route replaces, e.g. `finance.get`.
 *
 * It exists so CI can check the route against its source of truth. The parity
 * table is keyed by action, and without this link there is nothing to join a
 * controller method to the allow-list it was transcribed from — the permission
 * diff would have no way to know which row to compare against.
 *
 * It also gives Phase 2 a completeness measure for free: every action with no
 * route claiming it is a gap in the port, and `pnpm parity:check` prints them.
 */
export const RpcAction = (action: string) =>
  SetMetadata(RPC_ACTION_KEY, action);
