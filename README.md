# TikTok Service

> Publicación de videos en cuentas TikTok autorizadas vía la Content Posting API.

## Qué hace

Microservicio para **publicar videos en TikTok** vía la Content Posting API. **No es mensajería** — TikTok no permite DMs vía API para developers. Este servicio solo:

1. Consume de `channels.tiktok.send`
2. Llama a la API de TikTok para publicar el video bajo la cuenta creator autorizada
3. Reporta éxito/fallo

## Stack

| Pieza | Valor |
|---|---|
| Framework | NestJS 10 |
| Lenguaje | TypeScript 5 |
| DB | PostgreSQL (`tiktok_db`) |
| Mensajería | RabbitMQ — exchange `channels` |
| Provider externo | TikTok for Developers — Content Posting API |
| Puerto | `3005` |

## Routing keys

| Routing key | Dirección | Descripción |
|---|---|---|
| `channels.tiktok.send` | inbound | Publicar video en cuenta(s) |
| `channels.tiktok.response` | outbound | Respuesta con `video_id` o error |

## Payload típico

```json
{
  "messageId": "uuid-from-gateway",
  "recipients": ["open_id-del-creador"],
  "message": "Mira este video! 🔥 #fyp #contenido",
  "videoUrl": "https://example.com/mi-video.mp4",
  "coverUrl": "https://example.com/thumbnail.jpg",
  "metadata": {
    "privacy_level": "PUBLIC_TO_EVERYONE",
    "disable_duet": false,
    "disable_comment": false,
    "disable_stitch": false,
    "video_cover_timestamp_ms": 2000
  }
}
```

| Campo | Notas |
|---|---|
| `recipients` | Array de `open_id` — uno por cada creator account autorizada. Si pasás 3, publica el mismo video en las 3 cuentas. |
| `message` | El **caption** del video (incluí hashtags acá, no en campo separado) |
| `videoUrl` | URL pública del MP4 — TikTok lo descarga del internet. ⚠️ tu dominio tiene que estar verified en TikTok Developer Portal |
| `coverUrl` | Opcional — imagen de portada |
| `privacy_level` | `PUBLIC_TO_EVERYONE` (default), `MUTUAL_FOLLOW_FRIENDS`, `SELF_ONLY` |

## Endpoints HTTP (vía gateway)

Ver [../docs/api/channels/tiktok.md](../docs/api/channels/tiktok.md).

## Configuración (`.env`)

```env
TIKTOK_PORT=3005
TIKTOK_DATABASE_URL=postgresql://postgres:postgres123@postgres:5432/tiktok_db
RABBITMQ_URL=...

TIKTOK_APP_ID=...
TIKTOK_APP_SECRET=...
TIKTOK_ACCESS_TOKEN=...        # access token del creator account
```

## Restricciones de TikTok

| Restricción | Valor |
|---|---|
| Formato | MP4, codec H.264, audio AAC |
| Aspect ratio | 9:16 vertical recomendado (1080×1920) |
| Duración | 3 segundos a 10 minutos |
| Tamaño | hasta 4 GB |
| Caption | máx 2200 caracteres |
| Hashtags | máx 50 por video |
| Sandbox mode | las primeras semanas solo podés publicar a la cuenta del developer. Para publicar a creators externos hay que pasar el review de TikTok. |

## ⚠️ Lo que NO se puede hacer

- ❌ DMs (la API no lo permite)
- ❌ Stories
- ❌ Live streaming
- ❌ Upload multipart — TikTok requiere URL pública (no es limitación nuestra)
- ❌ Programar publicación a futuro **desde este servicio** — usá [scheduler](../scheduler/) para eso

## Cómo correrlo

```bash
docker-compose up -d tiktok
```

Dev local:
```bash
cd tiktok
pnpm install
pnpm prisma:generate
pnpm start:dev
```

## Ver también

- **[../docs/api/channels/tiktok.md](../docs/api/channels/tiktok.md)** — API reference
- **[../scheduler/](../scheduler/)** — para programar publicaciones recurrentes
