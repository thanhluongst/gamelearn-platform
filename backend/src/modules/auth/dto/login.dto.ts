import { IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({ description: 'Email hoặc Username' })
  @IsString()
  identifier: string;

  @ApiProperty()
  @IsString()
  password: string;
}
