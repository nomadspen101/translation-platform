import {
  S3Client,
  PutObjectCommand,
  DeleteObjectCommand,
  GetObjectCommand,
} from "@aws-sdk/client-s3";
import { getSignedUrl as awsGetSignedUrl } from "@aws-sdk/s3-request-presigner";

// ─── Client ───────────────────────────────────────────────────────────────────

const s3Client = new S3Client({
  region: process.env.AWS_REGION!,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!,
  },
});

const BUCKET = process.env.S3_BUCKET_NAME!;

// ─── Helpers ──────────────────────────────────────────────────────────────────

/**
 * Upload a file to S3.
 *
 * Key path conventions (ARCHITECTURE.md §8):
 *   uploads/{orderId}/original   — customer document
 *   jobs/{jobId}/draft.docx      — AI-generated draft
 *   jobs/{jobId}/certified.pdf   — translator-certified final PDF
 */
export async function uploadToS3(
  key: string,
  body: Buffer | Uint8Array,
  contentType: string
): Promise<string> {
  await s3Client.send(
    new PutObjectCommand({
      Bucket: BUCKET,
      Key: key,
      Body: body,
      ContentType: contentType,
    })
  );
  return key;
}

/**
 * Generate a presigned URL for a private S3 object.
 * Use for serving documents to translators and customers.
 */
export async function getSignedUrl(
  key: string,
  expiresInSeconds = 3600
): Promise<string> {
  const command = new GetObjectCommand({ Bucket: BUCKET, Key: key });
  return awsGetSignedUrl(s3Client, command, { expiresIn: expiresInSeconds });
}

/**
 * Delete an object from S3.
 * Used for manual early deletion (30-day lifecycle handles scheduled deletion).
 */
export async function deleteFromS3(key: string): Promise<void> {
  await s3Client.send(
    new DeleteObjectCommand({ Bucket: BUCKET, Key: key })
  );
}
