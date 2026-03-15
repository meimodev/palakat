import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Request } from 'express';
import { timingSafeEqual } from 'crypto';

@Injectable()
export class HealthSecretGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<Request>();
    const configuredSecret = process.env.HEALTH_PAGE_SECRET;

    if (!configuredSecret || configuredSecret.trim().length === 0) {
      throw new UnauthorizedException('Unauthorized');
    }

    const candidate = this.resolveCandidate(request);
    if (!candidate || !this.safeEquals(candidate, configuredSecret)) {
      throw new UnauthorizedException('Unauthorized');
    }

    return true;
  }

  private resolveCandidate(request: Request): string | undefined {
    const headerValue = request.headers['x-health-secret'];
    if (typeof headerValue === 'string' && headerValue.trim().length > 0) {
      return headerValue.trim();
    }

    const authorization = request.headers.authorization;
    if (typeof authorization === 'string') {
      const bearerMatch = authorization.match(/^Bearer\s+(.+)$/i);
      if (bearerMatch?.[1]) {
        return bearerMatch[1].trim();
      }
    }

    const queryValue = request.query?.s;
    if (typeof queryValue === 'string' && queryValue.trim().length > 0) {
      return queryValue.trim();
    }

    return undefined;
  }

  private safeEquals(left: string, right: string): boolean {
    const leftBuffer = Buffer.from(left);
    const rightBuffer = Buffer.from(right);

    if (leftBuffer.length !== rightBuffer.length) {
      return false;
    }

    return timingSafeEqual(leftBuffer, rightBuffer);
  }
}
