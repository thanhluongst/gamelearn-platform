import { IsString, IsOptional, IsNumber, IsBoolean, IsEnum } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateGameSessionDto {
  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  classId?: string;

  @ApiProperty()
  @IsString()
  bankId: string;

  @ApiProperty({ enum: ['fishing', 'gold_mining', 'car_race', 'treasure_hunt', 'puzzle', 'arena'] })
  @IsEnum(['fishing', 'gold_mining', 'car_race', 'treasure_hunt', 'puzzle', 'arena'])
  gameType: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  title?: string;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  questionCount?: number;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  timePerQuestion?: number;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  difficulty?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  subject?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  topic?: string;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  allowLateJoin?: boolean;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  randomizeQuestions?: boolean;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  maxPlayers?: number;
}
