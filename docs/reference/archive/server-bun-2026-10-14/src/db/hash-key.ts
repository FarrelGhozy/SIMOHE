import { hashDeviceKey } from '../lib/hash'

const key = process.argv[2]

if (!key) {
  console.error('Usage: bun run key:hash <device-key>')
  process.exit(1)
}

console.log(hashDeviceKey(key))
