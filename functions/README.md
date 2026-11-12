# Firebase Functions

`recommendMovie` is a Firebase Callable Function that uses popular TMDB
movies for moment recommendations and TMDB similar-movie results for blends.
Gemini ranks the candidates and writes the explanation. A Firebase Auth
identity is required for all calls.

## Configuration

- Runtime: Node.js 20
- Secrets, configured only in an explicitly authorized Firebase environment: `TMDB_READ_ACCESS_TOKEN`, `GEMINI_API_KEY`
- Function region: `us-central1`
- App Check enforcement: temporarily disabled for development; re-enable before production
- Rate limit: 5 calls per authenticated UID per minute
- A registered Firebase Auth account is required; anonymous Auth identities are rejected.

Rate limiting is five calls per Firebase UID per minute. Rate-limit documents
use a SHA-256 digest of the verified UID; client-provided identity fields are
rejected.

The callable requires Firebase Auth. App Check remains configured in the iOS
client, but enforcement is temporarily disabled because the development setup
does not have a paid Apple Developer team for App Attest. Re-enable
`enforceAppCheck` before production. The app's App Check provider uses the
debug provider in DEBUG builds and App Attest/Device Check in releases.

The Firebase project selection, billing, deploy, and secret values are managed
outside the source files and must be configured in the authorized Firebase
environment.

## Local development

1. Install Node 20, npm, and Firebase CLI.
2. From this directory, run `npm install` and `npm test`.
3. Store test-only credentials in Firebase Emulator secrets/configuration, never commit them.
4. Run emulators from the repository root with `firebase emulators:start --only auth,firestore,functions` after configuring local secrets.
5. Point the iOS Firebase Auth, Firestore, and Functions clients to the local emulators in a DEBUG-only development configuration before local callable testing.

The Firebase project selection, billing, deploy, and secret values are managed
outside the source files and must be configured in the authorized Firebase
environment.

