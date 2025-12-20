import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(configService: ConfigService) {
    const jwtSecret = configService.get<string>('JWT_SECRET');

    if (!jwtSecret) {
      throw new Error('JWT_SECRET is not configured in environment variables');
    }

    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: jwtSecret,
    });
  }

  async validate(payload: any): Promise<any> {
    if (payload?.clientId) {
      return {
        clientId: payload.clientId,
        source: 'jwt-strategy',
      };
    }
    if (payload?.sub) {
      return {
        userId: payload.sub,
        role: payload?.role,
        aud: payload?.aud,
        source: 'jwt-strategy',
      };
    }
    throw new UnauthorizedException('Invalid JWT payload');
  }
}
