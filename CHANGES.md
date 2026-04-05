# AzureVoiceMicro — Change Log & Implementation Status

> Tracks every file created, updated, and pending since project inception.  
> Updated: April 2026 — v1.1

---

## Project Overview

**Goal:** Standalone Flutter micro-app. User speaks → mic auto-transcribes → Azure Neural TTS plays back instantly as the selected AI voice. No server, no login, no complex UI. Works on Android (phone/tablet) + Windows (desktop/touch screen).

**Status:** Core app scaffolded and functional. Call mode documented in blueprint, implementation pending.

---

## Files Created (Initial Scaffold)

### Root / Config

| File | Status | Description |
|---|---|---|
| `pubspec.yaml` | ✅ Done | Dependencies: `provider`, `speech_to_text`, `http`, `just_audio`, `flutter_secure_storage`, `permission_handler`, `flutter_dotenv` |
| `README.md` | ✅ Done | Quick start, project structure, Azure setup, architecture diagram |
| `.env.example` | ✅ Done | Template with `AZURE_KEY` and `AZURE_REGION` placeholders |
| `.gitignore` | ✅ Done | Excludes `.env`, `*.jks`, `*.keystore`, `android/key.properties`, build artifacts |
| `BLUEPRINT.md` | ✅ Done | Full implementation guide (v1.1 — now includes §20 Call Mode) |
| `BLUEPRINT - Stock.md` | ✅ Done | Original unmodified blueprint snapshot |
| `CHANGES.md` | ✅ This file | Running change log |

---

### `lib/` — Dart Source Files

#### `lib/main.dart`
**Status:** ✅ Complete  
**What it does:**
- Calls `WidgetsFlutterBinding.ensureInitialized()`
- Creates `VoiceState` and calls `await state.initialize()` before `runApp`
- Wraps app in `ChangeNotifierProvider`
- `AzureVoiceMicroApp`: dark Material 3 theme seeded from `Colors.indigo`, no debug banner

---

#### `lib/models/azure_voice.dart`
**Status:** ✅ Complete  
**What it does:**
- `AzureVoice` data class: `id`, `displayName`, `locale`, `gender`, `style`
- `azureEnglishVoices` — hardcoded list of **22 Azure Neural voices**:
  - en-US: Aria, Jenny, Guy, Eric, Michelle, Brandon, Christopher, Elizabeth, Ana, Davis, Jason, Nancy, Tony
  - en-GB: Sonia, Ryan, Libby
  - en-AU: Natasha, William
  - en-CA: Clara, Liam
  - en-IN: Neerja, Prabhat

**Pending:** Dynamic fetch from Azure `/voices/list` endpoint (method exists in `AzureTtsService.fetchVoiceList()` but not yet wired to the picker)

---

#### `lib/providers/voice_state.dart`
**Status:** ✅ Complete (core), ⏳ Call mode pending  
**What it does:**
- `VoiceState extends ChangeNotifier` — single source of truth
- `initialize()`: loads credentials → creates `AzureTtsService` → loads saved voice → inits mic → calls `startListening()`
- `reinitialize(key, region)`: hot-reloads credentials without app restart
- `startListening()`: starts STT, on final result triggers `_speakText()`
- `_speakText(text)`: calls `ttsService.speak()`, sets `isSpeaking`, resumes listening after TTS completes
- `selectVoice(voice)`: updates state + persists via `CredentialService`
- `toggleListening()`: start/stop mic
- `clearTranscript()`, `clearError()`: housekeeping

**Pending additions for Call mode (see BLUEPRINT §20.4):**
```dart
bool isInCall = false;
Future<void> toggleCall() async { ... }
Future<void> _startCall() async { ... }
Future<void> _endCall() async { ... }
```

---

#### `lib/services/azure_tts_service.dart`
**Status:** ✅ Complete (REST + playback), ⏳ PCM output for call injection pending  
**What it does:**
- `speak(text, voice)`: builds SSML, POSTs to `https://{region}.tts.speech.microsoft.com/cognitiveservices/v1`
- Output format: `audio-16khz-128kbitrate-mono-mp3`
- `_BytesAudioSource extends StreamAudioSource`: feeds raw MP3 bytes to `just_audio` `AudioPlayer` without temp file
- `stop()`, `isPlaying` getter
- `_escapeXml()`: sanitises text for SSML
- `fetchVoiceList()`: fetches live voice list from Azure (not yet wired to UI)

**Pending for call mode:**
- `synthesizePcm(text, voice) → Uint8List` — returns raw PCM (WAV/PCM16) instead of MP3, for WebRTC injection

---

#### `lib/services/mic_service.dart`
**Status:** ✅ Complete  
**What it does:**
- Wraps `speech_to_text` (`SpeechToText`)
- `initialize()`: requests mic permission, returns bool
- `startListening(onResult)`: dictation mode, 30s max, 2s pause detection, partial results on
- `stopListening()`, `isListening`, `isAvailable` getters

---

#### `lib/services/credential_service.dart`
**Status:** ✅ Complete  
**What it does:**
- `FlutterSecureStorage` with:
  - Android: `AndroidOptions(encryptedSharedPreferences: true)` → EncryptedSharedPreferences (AES-256)
  - Windows: `WindowsOptions()` → DPAPI
- Keys stored: `azure_subscription_key`, `azure_region`, `azure_selected_voice`
- `saveCredentials()`, `loadCredentials()`, `saveSelectedVoice()`, `loadSelectedVoice()`, `clearAll()`

---

#### `lib/screens/main_screen.dart`
**Status:** ✅ Complete (base), ⏳ Call button pending  
**What it does:**
- `AppBar` with clear-transcript and settings icons
- `MaterialBanner` error display with "Open Settings" and "Dismiss" actions
- `MicIndicator` — centre-stage animated orb, tap to toggle
- Status text: "Listening..." / "Speaking..." / "Tap mic to start"
- `TranscriptDisplay` — scrollable transcript area
- `_VoiceRow` — current voice name + "Change Voice" button at bottom

**Pending additions for Call mode (see BLUEPRINT §20.6):**
```dart
_CallButton(state: state)  // toggleable green Call button between mic and voice row
```

---

#### `lib/screens/settings_screen.dart`
**Status:** ✅ Complete  
**What it does:**
- `TextEditingController` for key + region (defaults `eastus`)
- Obscured key field with eye toggle
- `FilledButton` "Save & Connect" → calls `VoiceState.reinitialize()`
- Snackbar feedback for success/error
- Free tier note at bottom

---

#### `lib/screens/voice_picker_screen.dart`
**Status:** ✅ Complete  
**What it does:**
- Search bar filtering by name, locale, or gender
- `ListView.builder` of `VoiceCard` tiles
- Preview button: calls `ttsService.speak("Hello, I am {name}.", voice)`
- On select: calls `onSelect(voice)` then pops

---

### `lib/widgets/`

#### `mic_indicator.dart`
**Status:** ✅ Complete  
- 120×120 circular animated orb with `AnimationController` pulse (1s repeat)
- States: idle (grey) → listening (blue + pulse) → speaking (green + pulse)
- `MouseRegion` hover scale for Windows mouse support
- `GestureDetector`: `onTap`, `onLongPressStart`, `onLongPressEnd` wired (for future hold-to-speak)
- `BoxShadow` glow scales with pulse animation

#### `transcript_display.dart`
**Status:** ✅ Complete  
- Fixed-width container, min 80 / max 200px height
- `RichText` with two spans: confirmed text (full opacity) + interim text (50% opacity, italic)
- `SingleChildScrollView(reverse: true)` auto-scrolls to bottom
- Empty state placeholder text

#### `voice_card.dart`
**Status:** ✅ Complete  
- `MouseRegion` hover highlight
- `AnimatedContainer` background tint (primary colour when selected)
- `ListTile`: radio icon, name (bold when selected), locale + gender subtitle
- Preview `IconButton` (play_circle_outline)

---

## `android/` — Native Android

**Status:** ⚠️ Default Flutter scaffold — requires additions for Call mode

### Changes needed for Call mode

1. **`AndroidManifest.xml`** — add permissions and service declarations (see BLUEPRINT §20.7):
   - `MANAGE_OWN_CALLS`
   - `FOREGROUND_SERVICE_MICROPHONE` (Android 14+ / API 34)
   - `FOREGROUND_SERVICE_PHONE_CALL` (Android 14+ / API 34)
   - `ConnectionService` service registration
   - `CallForegroundService` with `foregroundServiceType="microphone|phoneCall"`

2. **`AppConnectionService.kt`** — Kotlin class implementing `android.telecom.ConnectionService`
3. **`CallForegroundService.kt`** — keeps audio pipeline alive when app is backgrounded

---

## Dependencies Summary

### Currently in `pubspec.yaml`

| Package | Version | Purpose |
|---|---|---|
| `provider` | `^6.1.1` | State management |
| `speech_to_text` | `^6.6.0` | Device STT (free, on-device or cloud depending on OS) |
| `http` | `^1.2.0` | Azure TTS REST calls |
| `just_audio` | `^0.9.36` | MP3 audio playback from bytes |
| `flutter_secure_storage` | `^9.0.0` | Encrypted credential storage |
| `permission_handler` | `^11.3.0` | Runtime mic permission |
| `flutter_dotenv` | `^5.1.0` | `.env` file loading |

### To add for Call mode

| Package | Version | Purpose |
|---|---|---|
| `flutter_webrtc` | `^0.10.7` | P2P WebRTC audio call |

---

## Feature Status Matrix

| Feature | Implemented | Notes |
|---|---|---|
| Azure TTS REST call + MP3 playback | ✅ | `AzureTtsService.speak()` |
| Auto-transcription (STT on-device) | ✅ | `speech_to_text` |
| Voice selection (22 voices) | ✅ | `VoicePickerScreen` |
| Voice preview | ✅ | `VoicePickerScreen._previewVoice()` |
| Secure credential storage | ✅ | `flutter_secure_storage` DPAPI/EncryptedSharedPrefs |
| Persist selected voice across sessions | ✅ | `CredentialService.saveSelectedVoice()` |
| Animated mic orb (listening/speaking) | ✅ | `MicIndicator` with pulse animation |
| Mouse hover support (Windows) | ✅ | `MouseRegion` in `MicIndicator`, `VoiceCard` |
| Live interim transcript display | ✅ | `TranscriptDisplay` italic interim span |
| Error banner with settings shortcut | ✅ | `MaterialBanner` in `MainScreen` |
| Auto-restart listening after TTS | ✅ | `_speakText()` calls `startListening()` after `speak()` |
| Credential reinit without app restart | ✅ | `VoiceState.reinitialize()` |
| Dynamic voice list from Azure API | ⏳ Pending | `fetchVoiceList()` exists, not wired to picker |
| Hold-to-speak mode | ⏳ Pending | `onLongPressStart/End` wired in `MicIndicator`, not in `VoiceState` |
| Call mode (AI voice during call) | ⏳ Pending | See BLUEPRINT §20 |
| WebRTC call + `ConnectionService` | ⏳ Pending | Needs `flutter_webrtc`, `AppConnectionService.kt` |
| TTS → PCM output for call injection | ⏳ Pending | `synthesizePcm()` method needed in `AzureTtsService` |
| Multi-language voice support | ⏳ Pending | Model exists, only en-* listed |
| Windows call mode | ⏳ Pending | Windows has no `ConnectionService` equiv; WASAPI virtual mic possible |

---

## Known Issues / Gaps

1. **`.env.example` contains a real-looking key** — should be replaced with a placeholder like `your32charkey` before public release
2. **`speech_to_text` on Android** uses device speech recognition (Google or Samsung) which requires internet on most devices — no Azure STT SDK integrated yet
3. **`just_audio` on Windows** requires `windows_audio` optional dependency if issues arise with MP3 format
4. **`flutter_dotenv` loaded** in pubspec assets but `main.dart` does not currently call `await dotenv.load()` — credentials load purely from secure storage at runtime
5. **`fetchVoiceList()`** in `AzureTtsService` returns en-* only via a filter — should be exposed in a settings toggle to show all 400+ Azure voices

---

## Next Implementation Steps

### Priority 1 — Wire dynamic voice list
- Call `fetchVoiceList()` from `VoicePickerScreen` on first open
- Cache result in `VoiceState.dynamicVoices`
- Fall back to hardcoded `azureEnglishVoices` on error

### Priority 2 — Call Mode
1. Add `flutter_webrtc: ^0.10.7` to `pubspec.yaml`
2. Create `lib/services/call_service.dart` (see BLUEPRINT §20.5)
3. Add `isInCall` + `toggleCall()` to `VoiceState` (BLUEPRINT §20.4)
4. Add `_CallButton` widget to `MainScreen` (BLUEPRINT §20.6)
5. Add `synthesizePcm()` to `AzureTtsService`
6. Update `AndroidManifest.xml` (BLUEPRINT §20.7)
7. Write `AppConnectionService.kt` in Kotlin (reference: `telnyx-webrtc-android`)

### Priority 3 — Hold-to-speak
- `MicIndicator.onLongPressStart` → `VoiceState.startListening()`
- `MicIndicator.onLongPressEnd` → `VoiceState.stopListening()`
- Add mode toggle (auto-listen vs hold-to-speak) in `SettingsScreen`

---

## Blueprint Change History

| Version | Date | Change |
|---|---|---|
| 1.0 | Apr 2026 | Initial blueprint — full Flutter app structure, Azure setup, all screens/services/widgets |
| 1.1 | Apr 2026 | Added §20 Call Mode — Android services research, WebRTC approach, toggle button UI, manifest additions, GitHub reference projects |

---

_AzureVoiceMicro — maintained as a standalone micro-app blueprint_  
_Stack: Flutter 3.16+ · Dart 3 · Azure Cognitive Services · flutter\_webrtc_
