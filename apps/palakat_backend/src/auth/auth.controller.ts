import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthGuard } from '@nestjs/passport';
import { Request } from 'express';
import { ValidatedClient } from './strategies/client.strategy';
import { SignInDto } from './dto/sign-in.dto';
import { RefreshDto } from './dto/refresh.dto';
import { JwtService } from '@nestjs/jwt';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
    private readonly jwtService: JwtService,
  ) {}

  @Get('signing')
  @UseGuards(AuthGuard('client-signing'))
  async signingClient(@Req() req: Request) {
    return this.authService.generateClientToken(req.user as ValidatedClient);
  }

  @Get('validate')
  async validate(@Query('phone') phone?: string) {
    return this.authService.validate(phone as string);
  }

  @Post('sign-in')
  async signIn(@Body() dto: SignInDto) {
    return this.authService.signIn(dto);
  }

  @Post('refresh')
  async refresh(@Body() body: RefreshDto) {
    try {
      const decoded: any = this.jwtService.verify(body.refreshToken);
      if (!decoded?.sub) {
        throw new BadRequestException('Invalid refresh token');
      }
      return this.authService.refreshToken(decoded.sub, body.refreshToken);
    } catch {
      throw new BadRequestException('Invalid refresh token');
    }
  }

  @UseGuards(AuthGuard('jwt'))
  @Post('sign-out')
  async signOut(@Req() req: Request) {
    const user: any = req.user;
    if (!user?.userId) {
      throw new BadRequestException('Invalid user');
    }
    return this.authService.signOut(user.userId);
  }
}
