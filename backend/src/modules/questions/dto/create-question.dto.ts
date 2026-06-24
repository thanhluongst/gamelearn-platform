import { IsString, IsOptional, IsEnum, IsNumber, IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

class AnswerDto {
  @IsString()
  label: string;

  @IsString()
  content: string;

  @IsOptional()
  isCorrect?: boolean;
}

export class CreateQuestionDto {
  @ApiProperty()
  @IsString()
  bankId: string;

  @ApiProperty({ enum: ['multiple_choice', 'true_false', 'numeric'] })
  @IsEnum(['multiple_choice', 'true_false', 'numeric'])
  type: string;

  @ApiProperty()
  @IsString()
  content: string;

  @ApiPropertyOptional()
  @IsEnum(['easy', 'medium', 'hard'])
  @IsOptional()
  difficulty?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  explanation?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  correctAnswer?: string;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  timeLimit?: number;

  @ApiPropertyOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => AnswerDto)
  @IsOptional()
  answers?: AnswerDto[];
}
