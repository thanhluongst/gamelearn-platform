import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as AWS from 'aws-sdk';
import { v4 as uuidv4 } from 'uuid';
import * as path from 'path';

@Injectable()
export class StorageService {
  private readonly logger = new Logger(StorageService.name);
  private s3: AWS.S3;
  private bucket: string;
  private publicUrl: string;

  constructor(private readonly config: ConfigService) {
    this.bucket = config.get('app.storage.bucket');
    this.publicUrl = config.get('app.storage.publicUrl');

    this.s3 = new AWS.S3({
      endpoint: config.get('app.storage.endpoint'),
      accessKeyId: config.get('app.storage.accessKey'),
      secretAccessKey: config.get('app.storage.secretKey'),
      s3ForcePathStyle: true,
      signatureVersion: 'v4',
    });
  }

  async uploadFile(
    file: Express.Multer.File,
    folder = 'uploads',
    makePublic = false,
  ): Promise<string> {
    const ext = path.extname(file.originalname);
    const key = `${folder}/${uuidv4()}${ext}`;

    await this.s3.upload({
      Bucket: this.bucket,
      Key: key,
      Body: file.buffer,
      ContentType: file.mimetype,
      ACL: makePublic ? 'public-read' : 'private',
    }).promise();

    return `${this.publicUrl}/${this.bucket}/${key}`;
  }

  async deleteFile(url: string): Promise<void> {
    const key = url.replace(`${this.publicUrl}/${this.bucket}/`, '');
    await this.s3.deleteObject({ Bucket: this.bucket, Key: key }).promise();
  }

  async getSignedUrl(key: string, expiresIn = 3600): Promise<string> {
    return this.s3.getSignedUrlPromise('getObject', {
      Bucket: this.bucket,
      Key: key,
      Expires: expiresIn,
    });
  }
}
