# AI Image Studio — Text-to-Image Generator
**Project 3: AI Text-to-Image Generator** — Flutter + Artificial Intelligence Capstone

---

## 1. What's in this package

```
ai_image_gen/
├── flutter_app/        Complete Flutter app (Dart)
├── backend/             Node.js/Express backend that holds the real AI API key
└── README.md            This file — architecture, setup, AI docs, rubric mapping
```

## 2. Architecture (matches the handbook's standard architecture)

```
Flutter Mobile App
   ↓ REST/HTTPS (JSON)
Backend API (Node/Express)
   ↓
OpenAI API (image + text models)
   ↓
Structured JSON response → Flutter renders image
```

**Why a backend at all (Rule 4)?** Image-generation and LLM APIs require a secret
API key. If that key were embedded in the Flutter app, anyone could extract it
from the compiled APK/IPA and rack up charges on your account. The backend is the
only thing that ever sees `OPENAI_API_KEY` — the app only ever calls *your* server.

## 3. Setup

### 3.1 Backend
```bash
cd backend
cp .env.example .env      # then paste your real OpenAI API key into .env
npm install
npm start                 # runs on http://localhost:3000
```

### 3.2 Flutter app
```bash
cd flutter_app
flutter pub get
```
Open `lib/core/constants/app_constants.dart` and set `backendBaseUrl`:
- Android emulator → `http://10.0.2.2:3000`
- iOS simulator → `http://localhost:3000`
- Physical phone → `http://<your-computer's-LAN-IP>:3000`

Then run:
```bash
flutter run
```

## 4. AI Engineering Documentation (Section 8 / 21 requirement)

| Item | Detail |
|---|---|
| **Business/learning problem** | Let a user describe an image in plain language and receive a generated image in a chosen visual style, with an option to have AI improve a weak prompt first. |
| **Input** | User's free-text prompt (string) + selected style (enum: realistic, anime, oil painting, cyberpunk, watercolor, 3D render). |
| **Model 1 — Prompt enhancement** | An LLM (`gpt-4o-mini` by default, configurable) rewrites a short prompt into a more descriptive one (subject, setting, lighting, mood). |
| **Model 2 — Image generation** | An image-generation model (`gpt-image-1` by default; `dall-e-3` also supported) turns the final prompt + style suffix into a 1024×1024 image, returned as base64. |
| **Output** | Model 1: a rewritten text prompt. Model 2: an image (base64 PNG) shown in the app and saved to history. |
| **Human review** | The user sees the AI-enhanced prompt *before* generating and can dismiss it; users judge and can regenerate/discard any image. |

### Three representative prompts (required for the report)

1. `"a cat"` → enhanced → *"A fluffy orange tabby cat sitting on a sunlit windowsill, soft morning light, cozy interior"* → generated with **Anime** style.
2. `"cyberpunk city street at night"` (used as-is) → generated with **Cyberpunk** style suffix appended (`neon lights, futuristic, high contrast`).
3. `"a bowl of fruit on a wooden table"` → generated with **Oil Painting** style → tests how well the model follows still-life composition.

### Known limitations (must be documented per Rule 7 / Section 8)
- The model sometimes misreads unusual word combinations or ignores minor details in long prompts.
- Generated text/lettering inside images is frequently garbled — avoid prompts requiring readable text.
- Content-policy filtering can reject prompts involving real public figures, violence, or certain sensitive topics; the backend surfaces this as a clear error instead of crashing.
- Generation latency is typically 5–15 seconds; the app shows a shimmer loading state during this time.
- Style is applied by appending descriptive keywords to the prompt — it strongly influences but does not guarantee the exact art style requested.
- Costs money per image — for classroom demos, use small quotas and test/demo API keys (Rule 5 spirit).

### How to test it (Section 8: "test both successful and unsuccessful AI responses")
| Test case | Expected result |
|---|---|
| Valid prompt, each of the 6 styles | Image generated, saved to history, correct style label shown |
| Empty prompt → tap Generate | Inline validation error, no network call made |
| Backend not running | `AppErrorWidget` shows a clear "cannot reach server" message with Retry |
| Prompt violating content policy | Backend returns 400 with a readable message instead of a raw stack trace |
| Airplane mode / no internet | `SocketException` caught → friendly error, Retry button works |
| "Enhance with AI" on a 2-word prompt | Returns a longer, more descriptive prompt shown in a preview chip, dismissible |
| Delete a history item / clear all | List updates immediately, persists after app restart |

## 5. Mapping to the handbook's project rules

| Rule | How this project satisfies it |
|---|---|
| Rule 1 — Flutter app | Full Flutter app in `flutter_app/`, Material 3, clean navigation (Home → History → Detail). |
| Rule 2 — Meaningful AI, not a bolt-on chatbot | Two real AI workflows: prompt enhancement (LLM) and image generation (diffusion/image model) are core to the app, not decorative. |
| Rule 3 — Explain input/output | Documented above in Section 4; also expose this at your demo/defense. |
| Rule 4 — No exposed API keys | API key lives only in `backend/.env`; Flutter calls only your backend (`ApiClient`). |
| Rule 5 — Test/demo data for sensitive domains | N/A (no banking/health data), but do use a low-quota test key for classroom demos. |
| Rule 6 — Review AI-generated code | Read through this codebase, understand each file — you'll need to defend it live. |
| Rule 7 — Document prompts/APIs/limitations | Section 4 above; expand into your Project Report and AI Documentation deliverable. |

## 6. Mapping to "Minimum Technical Requirements" (Section 7)

- ✅ Clean navigation + responsive UI (Home / History / Detail, `ListView`-based, works on any screen size)
- ✅ Dart models for API/data (`GenerationResult`)
- ✅ REST integration using JSON (`ApiClient`, `ImageGenerationService`)
- ✅ Loading, success, empty, and error states (`GenerationLoadingWidget`, `AppErrorWidget`, `EmptyStateWidget`)
- ✅ Input validation (empty-prompt check) + exception handling (`ApiException`, timeouts, `SocketException`)
- ✅ Secure credential handling (backend `.env`, never in Flutter)
- ✅ Persistent storage for generation history (`shared_preferences` via `LocalStorageService`)
- ✅ Separation of UI / state (`providers/`) / service layer (`data/`) / models (`data/models/`)
- ✅ Live-demoable AI workflow end to end

## 7. Feature checklist from the project brief (Section 6, Project 3)

- ✅ Natural-language description → generated image
- ✅ Prompt history (History screen, persisted locally)
- ✅ Regeneration (Regenerate button on the result card)
- ✅ Image preview, save, and share
- ✅ At least three generation styles (**six** provided)
- ✅ Optional AI prompt-improvement feature ("Enhance with AI")
- ✅ Documented how prompt wording changes results (Section 4 above — extend with your own screenshots for the report)

## 8. New features added (v2)

| Feature | What it does | Files |
|---|---|---|
| **Content safety filter** | Blocks nudity/NSFW, signatures, ID cards, passports, invoices, contracts, currency/banknotes *before* any network call — a first line of defense on top of the AI provider's own content policy. | `core/services/content_filter_service.dart`, wired into `generator_provider.dart` |
| **Dark / Light / Pink color modes** | Full app-wide theme switcher, persisted on device. Every screen reads colors from the active palette instead of hardcoded constants. | `core/theme/app_theme.dart`, `features/settings/.../settings_screen.dart` |
| **11 languages (English + 10 Asian, no Thai)** | UI text switches to Khmer, Vietnamese, Chinese, Japanese, Korean, Indonesian, Malay, Filipino, Hindi, or Burmese. Picked from Settings, persisted. | `core/localization/app_localizations.dart` |
| **Voice input, multi-language** | Tap the mic in the prompt box to speak your idea; speech recognition uses the locale matching your selected UI language. | `core/services/voice_input_service.dart`, `widgets/prompt_input.dart` |
| **Save as JPG** | Generated images (returned as PNG) are re-encoded to JPG before saving/sharing. | `core/utils/image_save_util.dart` |

### Android/iOS permissions you must add (required for voice input + saving)

**`android/app/src/main/AndroidManifest.xml`** — inside `<manifest>`, above `<application>`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

**`ios/Runner/Info.plist`** — inside the outer `<dict>`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access so you can speak your image prompt.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>We use speech recognition to convert your voice into a text prompt.</string>
```
(You'll only have these folders after running `flutter create .` once, per the setup steps.)

## 9. Publishing to the Play Store / App Store

1. **App icon & name**: replace the default icon (use `flutter_launcher_icons` package) and set your final app name in `pubspec.yaml` and platform manifests.
2. **Versioning**: bump `version:` in `pubspec.yaml` before each release build.
3. **Backend must be deployed**, not `localhost` — deploy `backend/` to a real host (Render, Railway, Fly.io, a VPS, etc.), get an HTTPS URL, and update `backendBaseUrl` in `app_constants.dart` to that URL before building your release APK/IPA.
4. **Privacy policy**: required by both stores since the app uses the microphone and calls a third-party AI API — write a short page describing what data is sent (prompts, generated images) and host it anywhere (even a GitHub Pages link).
5. **Android release build**: `flutter build appbundle --release` → upload the `.aab` to Google Play Console.
6. **iOS release build** (needs a Mac + Apple Developer account): `flutter build ipa --release` → upload via Xcode/Transporter to App Store Connect.
7. Fill in each store's content rating questionnaire honestly (mention AI-generated image content).

## 10. Suggested next steps for your team

1. Run the backend + app, generate ~15–20 test images across styles for your report's "testing and evaluation" section.
2. Take before/after screenshots of the "Enhance with AI" feature for Section 8 of the Recommended Report Structure.
3. Add your team's names/roles and this project's ERD-less, simple data model (`GenerationResult`) to your Project Report.
4. If you want a bonus feature: add a "regenerate with a different style, same prompt" comparison view, or wire history to a real backend database (Postgres/MySQL) instead of local storage, to also cover the "database" grading line.
5. Ask me to generate the full Word (.docx) Project Report, or an ERD/architecture diagram, whenever you're ready — I can produce those directly.
