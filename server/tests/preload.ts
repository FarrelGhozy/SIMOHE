import { drizzle } from 'drizzle-orm/mysql2'
import { migrate } from 'drizzle-orm/mysql2/migrator'
import mysql from 'mysql2/promise'

const TEST_DATABASE = 'simohe_test'
const DB_HOST = process.env.TEST_DB_HOST ?? '127.0.0.1'
const DB_PORT = Number(process.env.TEST_DB_PORT ?? 3307)
const DB_ROOT_USER = process.env.TEST_DB_ROOT_USER ?? 'root'
const DB_ROOT_PASSWORD = process.env.TEST_DB_ROOT_PASSWORD ?? 'simohe_root'

const admin = await mysql.createConnection({
  host: DB_HOST,
  port: DB_PORT,
  user: DB_ROOT_USER,
  password: DB_ROOT_PASSWORD,
})

await admin.query(
  `CREATE DATABASE IF NOT EXISTS \`${TEST_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`,
)
await admin.end()

const url = `mysql://${DB_ROOT_USER}:${DB_ROOT_PASSWORD}@${DB_HOST}:${DB_PORT}/${TEST_DATABASE}`

process.env.NODE_ENV = 'test'
process.env.DATABASE_URL = url
process.env.APP_TOKEN = 'test-app-token'
process.env.LOG_LEVEL = 'error'
process.env.RATE_LIMIT_INGEST_PER_SEC = '1000'
process.env.RATE_LIMIT_APP_PER_SEC = '1000'
process.env.APP_CORS_ORIGIN = '*'

const pool = mysql.createPool({ uri: url, timezone: 'Z' })
await migrate(drizzle(pool), { migrationsFolder: './drizzle' })
await pool.end()
