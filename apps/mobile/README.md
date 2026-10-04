# Flashi mobile

The Flutter app is an offline-first client.

## Flutter responsibilities

- local Hive storage for study sets/history/preferences
- flashcard and quiz review UI
- Google sign-in client flow
- upload source files to a backend-issued Supabase signed URL
- call the protected Next.js generation/credit APIs
- show Start.io rewarded ads
- save generated study sets locally for offline review

Flutter does **not** contain the OpenAI API key, Supabase secret key, model-selection logic, credit mutation rules, or AI business logic.

## Development config

Run with public/build-time values:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:3000 \
  --dart-define=SUPABASE_URL=https://PROJECT.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_... \
  --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_WEB_CLIENT_ID
```

After Vercel deployment, replace `API_BASE_URL` with the production API URL.

### Start.io

Start.io needs the App ID in native metadata at build time. On Android set `START_IO_APP_ID` as an environment variable or add it to local `android/local.properties`. On iOS add the `START_IO_APP_ID` build setting in Xcode. The backend still returns runtime ad enable/test/reward settings.

### Google Auth

Configure the Android OAuth client with package `com.curibtech.flashi` and both debug/release SHA-1 fingerprints. Configure the Google Web client ID in Supabase Google provider settings and pass that web client ID to Flutter.
