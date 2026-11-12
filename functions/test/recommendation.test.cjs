const test = require("node:test");
const assert = require("node:assert/strict");
const {
  isAnonymousAuthToken,
  mergeCandidateMovies,
  parseRequest,
  subjectForUid,
} = require("../lib/recommendation.js");

test("accepts and trims a valid moment prompt", () => {
  assert.deepEqual(
    parseRequest({ mode: "moment", prompt: "  cozy mystery  ", locale: "pt-BR" }),
    { mode: "moment", prompt: "cozy mystery", locale: "pt-BR" }
  );
});

test("falls back to the supported default locale", () => {
  assert.deepEqual(
    parseRequest({ mode: "moment", prompt: "a", locale: "pt_BR" }),
    { mode: "moment", prompt: "a", locale: "en-US" }
  );
  assert.deepEqual(
    parseRequest({ mode: "moment", prompt: "a", locale: "x".repeat(33) }),
    { mode: "moment", prompt: "a", locale: "en-US" }
  );
});

test("rejects an empty or oversized moment prompt", () => {
  assert.throws(() => parseRequest({ mode: "moment", prompt: "  " }));
  assert.throws(() => parseRequest({ mode: "moment", prompt: "x".repeat(501) }));
});

test("accepts two positive, distinct movie IDs", () => {
  assert.deepEqual(
    parseRequest({ mode: "blend", movieIds: [11, 22] }),
    { mode: "blend", movieIds: [11, 22], locale: "en-US" }
  );
});

test("rejects malformed movie ID pairs and unknown fields", () => {
  assert.throws(() => parseRequest({ mode: "blend", movieIds: [11, 11] }));
  assert.throws(() => parseRequest({ mode: "blend", movieIds: [0, 22] }));
  assert.throws(() => parseRequest({ mode: "blend", movieIds: [11, "22"] }));
  assert.throws(() => parseRequest({ mode: "moment", prompt: "film", uid: "spoof" }));
});

test("hashes auth UIDs before using them as rate-limit document IDs", () => {
  assert.equal(subjectForUid("user-1").length, 64);
  assert.notEqual(subjectForUid("user-1"), subjectForUid("user-2"));
});

test("merges similar movie results without sources or duplicates", () => {
  const candidates = mergeCandidateMovies(
    [
      [{ id: 11 }, { id: 22 }, { id: 33 }],
      [{ id: 22 }, { id: 44 }],
    ],
    [11, 44],
    10
  );
  assert.deepEqual(candidates, [{ id: 22 }, { id: 33 }]);
});

test("identifies anonymous Firebase Auth tokens", () => {
  assert.equal(
    isAnonymousAuthToken({ firebase: { sign_in_provider: "anonymous" } }),
    true
  );
  assert.equal(
    isAnonymousAuthToken({ firebase: { sign_in_provider: "password" } }),
    false
  );
});
