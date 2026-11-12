import { createHash } from "node:crypto";
import { HttpsError } from "firebase-functions/v2/https";

export type RecommendationMode =
  | { mode: "moment"; prompt: string; locale: string }
  | { mode: "blend"; movieIds: [number, number]; locale: string };

export function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

export function parseRequest(data: unknown): RecommendationMode {
  if (!isRecord(data) || typeof data.mode !== "string") {
    throw new HttpsError("invalid-argument", "Invalid recommendation request.");
  }

  const locale = typeof data.locale === "string" && ["en-US", "pt-BR"].includes(data.locale)
    ? data.locale
    : "en-US";

  if (data.mode === "moment") {
    if (Object.keys(data).some((key) => !["mode", "prompt", "locale"].includes(key))) {
      throw new HttpsError("invalid-argument", "Unexpected recommendation fields.");
    }
    if (typeof data.prompt !== "string") {
      throw new HttpsError("invalid-argument", "A prompt is required.");
    }
    const prompt = data.prompt.trim();
    if (!prompt || prompt.length > 500) {
      throw new HttpsError("invalid-argument", "The prompt must contain 1 to 500 characters.");
    }
    return { mode: "moment", prompt, locale };
  }

  if (data.mode === "blend") {
    if (Object.keys(data).some((key) => !["mode", "movieIds", "locale"].includes(key))) {
      throw new HttpsError("invalid-argument", "Unexpected recommendation fields.");
    }
    if (
      !Array.isArray(data.movieIds) ||
      data.movieIds.length !== 2 ||
      !data.movieIds.every((id) => Number.isSafeInteger(id) && id > 0) ||
      data.movieIds[0] === data.movieIds[1]
    ) {
      throw new HttpsError("invalid-argument", "Two distinct valid movie IDs are required.");
    }
    return { mode: "blend", movieIds: [data.movieIds[0], data.movieIds[1]], locale };
  }

  throw new HttpsError("invalid-argument", "Unsupported recommendation mode.");
}

export function subjectForUid(uid: string): string {
  return createHash("sha256").update(uid).digest("hex");
}

export function mergeCandidateMovies<T extends { id: number }>(
  resultSets: T[][],
  excludedMovieIds: readonly number[],
  limit: number
): T[] {
  const excluded = new Set(excludedMovieIds);
  return Array.from(
    new Map(
      resultSets
        .flat()
        .filter((movie) => !excluded.has(movie.id))
        .map((movie) => [movie.id, movie])
    ).values()
  ).slice(0, limit);
}

export function isAnonymousAuthToken(token: Record<string, unknown> | undefined): boolean {
  const firebase = token?.firebase;
  if (!isRecord(firebase)) return false;
  return firebase.sign_in_provider === "anonymous";
}
