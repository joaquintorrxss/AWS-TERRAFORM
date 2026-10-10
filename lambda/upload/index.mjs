import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { randomUUID } from "node:crypto";

const s3 = new S3Client({});

const BUCKET_NAME = process.env.BUCKET_NAME;
const UPLOADS_PREFIX = process.env.UPLOADS_PREFIX ?? "uploads/";
const MAX_FILE_BYTES = Number(process.env.MAX_FILE_BYTES ?? "4194304");

const allowedTypes = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
};

function response(statusCode, body) {
  return {
    statusCode,
    headers: {
      "content-type": "application/json",
    },
    body: JSON.stringify(body),
  };
}

export const handler = async (event) => {
  try {
    if (!event?.body) {
      return response(400, {
        message: "El cuerpo de la solicitud es obligatorio.",
      });
    }

    const rawBody = event.isBase64Encoded
      ? Buffer.from(event.body, "base64").toString("utf8")
      : event.body;

    const payload = JSON.parse(rawBody);

    const contentType = payload.contentType;
    const dataBase64 = payload.dataBase64;

    if (!allowedTypes[contentType]) {
      return response(400, {
        message: "Tipo de imagen no permitido.",
        allowedTypes: Object.keys(allowedTypes),
      });
    }

    if (typeof dataBase64 !== "string" || dataBase64.length === 0) {
      return response(400, {
        message: "dataBase64 es obligatorio.",
      });
    }

    const imageBuffer = Buffer.from(dataBase64, "base64");

    if (imageBuffer.length === 0) {
      return response(400, {
        message: "La imagen enviada no contiene datos.",
      });
    }

    if (imageBuffer.length > MAX_FILE_BYTES) {
      return response(413, {
        message: "La imagen supera el tamaño máximo permitido.",
        maxBytes: MAX_FILE_BYTES,
      });
    }

    const extension = allowedTypes[contentType];
    const fileName = `${randomUUID()}.${extension}`;
    const key = `${UPLOADS_PREFIX}${fileName}`;

    await s3.send(
      new PutObjectCommand({
        Bucket: BUCKET_NAME,
        Key: key,
        Body: imageBuffer,
        ContentType: contentType,
      }),
    );

    return response(201, {
      message: "Imagen almacenada correctamente.",
      key,
      size: imageBuffer.length,
    });
  } catch (error) {
    console.error("Error procesando la carga:", error);

    if (error instanceof SyntaxError) {
      return response(400, {
        message: "El cuerpo JSON no es válido.",
      });
    }

    return response(500, {
      message: "No se pudo almacenar la imagen.",
    });
  }
};
