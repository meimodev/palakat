import {
  Body,
  Controller,
  Get,
  Post,
  Put,
  Req,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { FileInterceptor } from '@nestjs/platform-express';
import { Request } from 'express';
import { ChurchLetterheadService } from './church-letterhead.service';
import { UpdateChurchLetterheadDto } from './dto/update-church-letterhead.dto';

@UseGuards(AuthGuard('jwt'))
@Controller('church-letterhead')
export class ChurchLetterheadController {
  constructor(
    private readonly churchLetterheadService: ChurchLetterheadService,
  ) {}

  @Get('me')
  async getMe(@Req() req: Request) {
    return this.churchLetterheadService.getMe((req as any).user);
  }

  @Put('me')
  async updateMe(@Body() dto: UpdateChurchLetterheadDto, @Req() req: Request) {
    return this.churchLetterheadService.updateMe(dto, (req as any).user);
  }

  @Post('me/logo')
  @UseInterceptors(
    FileInterceptor('file', {
      limits: {
        fileSize: 5 * 1024 * 1024,
      },
    }),
  )
  async uploadLogo(@UploadedFile() file: any, @Req() req: Request) {
    return this.churchLetterheadService.uploadLogo(file, (req as any).user);
  }
}
