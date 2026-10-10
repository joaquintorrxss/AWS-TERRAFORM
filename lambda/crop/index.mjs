import {
  GetObjectCommand,
  PutObjectCommand,
  S3Client,
} from "@aws-sdk/client-s3";

import sharp from "sharp";

const s3 = new S3Client({});

const BUCKET_NAME = process.env.BUCKET_NAME;
const UPLOADS_PREFIX = process.env.UPLOADS_PREFIX ?? "uploads/";
const PROCESSED_PREFIX = process.env.PROCESSED_PREFIX ?? "processed/";

const OUTPUT_SIZE = 40;

/**
 * Convierte un stream de S3 en un Buffer.
 */
async function bodyToBuffer(body) {
  const bytes = await body.transformToByteArray();
  return Buffer.from(bytes);
}

/**
 * Genera una imagen PNG 40x40 con mascara circular.
 */
async function cropImage(imageBuffer) {
  const circle = Buffer.from(`
    <svg width="${OUTPUT_SIZE}" height="${OUTPUT_SIZE}">
      <circle
        cx="${OUTPUT_SIZE / 2}"
        cy="${OUTPUT_SIZE / 2}"
        r="${OUTPUT_SIZE / 2}"
        fill="white"
      />
    </svg>
  `);

  return sharp(imageBuffer)
    .resize(OUTPUT_SIZE, OUTPUT_SIZE, {
      fit: "cover",
      position: "centre",
    })
    .composite([
      {
        input: circle,
        blend: "dest-in",
      },
    ])
    .png()
    .toBuffer();
}

/**
 * Obtiene el nombre que se usara dentro de processed/.
 */
function buildProcessedKey(sourceKey) {
  const relativeKey = sourceKey.slice(UPLOADS_PREFIX.length);

  const fileNameWithoutExtension = relativeKey.replace(
    /\.[^/.]+$/,
    "",
  );

  return `${PROCESSED_PREFIX}${fileNameWithoutExtension}.png`;
}

/**
 * Procesa un evento individual enviado por S3.
 */
async function processS3Record(record) {
  const bucket = record.s3.bucket.name;

  const sourceKey = decodeURIComponent(
    record.s3.object.key.replace(/\+/g, " "),
  );

  if (!sourceKey.startsWith(UPLOADS_PREFIX)) {
    console.log(`Objeto ignorado: ${sourceKey}`);
    return;
  }

  console.log(`Procesando ${bucket}/${sourceKey}`);

  const original = await s3.send(
    new GetObjectCommand({
      Bucket: bucket,
      Key: sourceKey,
    }),
  );

  const originalBuffer = await bodyToBuffer(original.Body);

  const processedBuffer = await cropImage(originalBuffer);

  const processedKey = buildProcessedKey(sourceKey);

  await s3.send(
    new PutObjectCommand({
      Bucket: BUCKET_NAME,
      Key: processedKey,
      Body: processedBuffer,
      ContentType: "image/png",
    }),
  );

  console.log(
    `Imagen procesada correctamente: ${processedKey}`,
  );
}

export const handler = async (event) => {
  console.log(`Mensajes SQS recibidos: ${event.Records?.length ?? 0}`);

  for (const sqsRecord of event.Records ?? []) {
    const body = JSON.parse(sqsRecord.body);

    // S3 puede enviar un evento de prueba al configurar
    // una notificacion.
    if (body.Event === "s3:TestEvent") {
      console.log("Evento de prueba de S3 ignorado.");
      continue;
    }

    const s3Records = body.Records ?? [];

    for (const s3Record of s3Records) {
      await processS3Record(s3Record);
    }
  }

  return {
    processed: event.Records?.length ?? 0,
  };
};