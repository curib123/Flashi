# Flashi mobile

The Flutter app is an offline-first study client. It does not contain server-side business logic or private API credentials.

## Responsibilities

- SQLite is the active local store for study sets, subjects, attempts, and pending sync changes.
- Existing Hive quiz data is read once for migration into SQLite; Hive is not the active study database.
- Manual creation, practice, results, mistake review, backup, sharing, and `.flashi` imports work locally.
- Google Sign-In obtains an ID token, then the Next.js backend exchanges it for the application session.
- AI generation calls the protected backend only. Source files are uploaded with short-lived signed URLs issued by the backend.
- Generated sets are validated and saved to SQLite for offline study.
- Start.io is server-gated. Only an explicitly enabled, user-opted-in banner may appear on the library screen. Splash, return, interstitial, and rewarded-credit ads are not used.

Flutter never contains the OpenAI key, Supabase secret/service key, credit mutation rules, model routing, or AI prompts.

## Development

Run the API first, then:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:3000 \
  --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID
```

For production, set `API_BASE_URL` to the Vercel deployment URL.

### Google authentication

Configure the Android OAuth client for package `com.curibtech.flashi` with the correct debug/release signing fingerprints. Configure the same Google Web client ID on the backend/Supabase provider and pass it as `GOOGLE_WEB_CLIENT_ID` to Flutter.

### Start.io

The native Start.io App ID is a build-time Android manifest value. Set `START_IO_APP_ID` in the Android build environment or `android/local.properties`. Runtime enable/test/banner flags come from the Next.js `/api/v1/config` endpoint.

Return ads and splash ads are explicitly disabled in `AndroidManifest.xml`. The app does not load a banner until the backend enables the library-banner placement and the user opts in.
