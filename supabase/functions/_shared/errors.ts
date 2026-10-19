// _shared/errors.ts — Format error seragam { error: { code, message } }.
// Diporting dari server lama (middlewares/error.ts + lib/app-error.ts).

export class AppError extends Error {
  readonly status: number;
  readonly code: string;

  constructor(status: number, code: string, message: string) {
    super(message);
    this.name = "AppError";
    this.status = status;
    this.code = code;
  }
}

export function errorBody(code: string, message: string): Response {
  const status = code === "VALIDATION_ERROR" || code === "INVALID_JSON" ||
      code === "BODY_TOO_LARGE"
    ? 400
    : code === "UNAUTHORIZED" || code === "FORBIDDEN"
    ? 401
    : code === "NOT_FOUND" || code === "DEVICE_NOT_FOUND" ||
      code === "COMMAND_NOT_FOUND" || code === "EVENT_NOT_FOUND" ||
      code === "BATCH_NOT_FOUND" || code === "SETTINGS_MISSING"
    ? 404
    : code === "CONFLICT" || code === "COMMAND_NOT_PENDING" ||
      code === "BATCH_ACTIVE" || code === "BATCH_HARVESTED"
    ? 409
    : code === "RATE_LIMITED"
    ? 429
    : 500;
  return Response.json({ error: { code, message } }, { status });
}

export function toAppError(error: unknown): AppError {
  if (error instanceof AppError) return error;
  console.error("unhandled error", error);
  return new AppError(500, "INTERNAL_ERROR", "Terjadi kesalahan pada server");
}

export function methodGuard(req: Request, allowed: string[]): Response | null {
  if (!allowed.includes(req.method)) {
    return Response.json(
      { error: { code: "METHOD_NOT_ALLOWED", message: "Metode tidak didukung" } },
      { status: 405 },
    );
  }
  return null;
}
