import mysql from 'mysql2/promise'
import { drizzle } from 'drizzle-orm/mysql2'
import { env } from '../env'
import * as schema from './schema'

export const pool = mysql.createPool({
  uri: env.DATABASE_URL,
  timezone: 'Z',
  waitForConnections: true,
  connectionLimit: 10,
  supportBigNumbers: true,
})

export const db = drizzle(pool, { schema, mode: 'default' })
export type Database = typeof db
