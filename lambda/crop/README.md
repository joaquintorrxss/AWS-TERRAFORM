# Lambda Crop

Esta funcion procesa los eventos recibidos desde Amazon SQS.

Flujo:

SQS -> Lambda Crop -> S3 processed/

La funcion:

- Lee la imagen original desde `uploads/`.
- Redimensiona la imagen a 40x40 px.
- Aplica una mascara circular.
- Convierte el resultado a PNG.
- Almacena el archivo dentro de `processed/`.

## Dependencias

La funcion utiliza `sharp`.

Como AWS Lambda utiliza Linux x64, desde Windows instalar las
dependencias con:

```powershell
npm install --cpu=x64 --os=linux --libc=glibc sharp