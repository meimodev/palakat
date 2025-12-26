export type RpcAction = string;

export interface RpcRequest {
  id: string;
  action: RpcAction;
  payload?: unknown;
  meta?: Record<string, unknown>;
}

export interface RpcOkResponse {
  ok: true;
  id: string;
  data?: unknown;
}

export interface RpcErrorResponse {
  ok: false;
  id: string;
  error: {
    code: string;
    message: string;
    details?: unknown;
  };
}

export type RpcResponse = RpcOkResponse | RpcErrorResponse;
