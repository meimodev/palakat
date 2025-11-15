import { PassportStrategy } from '@nestjs/passport';
import { Injectable, Logger, UnauthorizedException } from '@nestjs/common';
import { Strategy } from 'passport-custom';
import { Request } from 'express';
import { ConfigService } from '@nestjs/config';

export interface ValidatedClient {
  clientId: string;
  source: string;
}

@Injectable()
export class ClientStrategy extends PassportStrategy(
  Strategy,
  'client-signing',
) {
  private readonly logger = new Logger(ClientStrategy.name);
  constructor(private readonly configService: ConfigService) {
    super();
  }

  async validate(req: Request): Promise<ValidatedClient> {
    const username = req.headers['x-username'] as string;
    const password = req.headers['x-password'] as string;

    const validUsername = this.configService.get<string>('APP_CLIENT_USERNAME');
    const validPassword = this.configService.get<string>('APP_CLIENT_PASSWORD');

    if (username === validUsername && password === validPassword) {
      return { clientId: username, source: 'client-strategy' };
    } else {
      throw new UnauthorizedException('Invalid client credentials');
    }
  }
}
