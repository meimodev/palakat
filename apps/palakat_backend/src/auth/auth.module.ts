import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ClientStrategy } from './strategies/client.strategy';
import { JwtStrategy } from './strategies/jwt.strategy';
import { RolesGuard } from './roles.guard';
import { PermissionsGuard } from './permissions.guard';
import { ChurchPermissionPolicyModule } from '../church-permission-policy/church-permission-policy.module';

@Module({
  imports: [
    ChurchPermissionPolicyModule,
    ConfigModule,
    PassportModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET'),
        // signOptions: { expiresIn: '1h' },
      }),
      inject: [ConfigService],
    }),
  ],
  providers: [
    AuthService,
    ClientStrategy,
    JwtStrategy,
    RolesGuard,
    PermissionsGuard,
  ],
  exports: [PassportModule, JwtModule, AuthService, PermissionsGuard],
})
export class AuthModule {}
