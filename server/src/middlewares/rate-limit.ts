import { createHash } from 'node:crypto'
import { rateLimit } from 'elysia-rate-limit'
import { env } from '../env'

function fingerprint(value: string | null): string {
  if (!value) return ''
  return createHash('sha256').update(value).digest('hex').slice(0, 16)
}

export const rateLimiter = rateLimit({
  duration: 1000,
  max: (_key, request) =>
    request.headers.get('x-device-key')
      ? env.RATE_LIMIT_INGEST_PER_SEC
      : env.RATE_LIMIT_APP_PER_SEC,
  generator: (request, server) => {
    const deviceKey = request.headers.get('x-device-key')
    if (deviceKey) return `device:${fingerprint(deviceKey)}`

    const authorization = request.headers.get('authorization')
    if (authorization) return `app:${fingerprint(authorization)}`

    const ip = server?.requestIP(request)?.address ?? 'unknown'
    return `ip:${ip}`
  },
  errorResponse: new Response(
    JSON.stringify({ error: { code: 'RATE_LIMITED', message: 'Terlalu banyak permintaan' } }),
    { status: 429, headers: { 'content-type': 'application/json' } },
  ),
  headers: true,
})
