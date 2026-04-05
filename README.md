# Azure Voice Micro

> **One purpose:** User speaks → mic auto-transcribes → plays back instantly as the selected Azure AI voice.

**Platforms:** Android (phone/tablet) + Windows (desktop/touch screen)  
**Input:** Touch AND mouse — no buttons required, fully hands-free

## What it does

- Microphone always listening (auto mode) or on hold-to-speak (manual mode)
- Azure Speech Services transcribes speech in real-time (device built-in STT — free)
- Text immediately sent to Azure Neural TTS REST API
- AI voice plays through speakers
- User selects the output voice from a scrollable list

## Quick Start

### 1. Prerequisites

- [Flutter SDK 3.16+](https://docs.flutter.dev/get-started/install/windows)
- Android Studio (for Android builds) or Visual Studio 2022 (for Windows builds)
- An [Azure Cognitive Services / Speech resource](https://portal.azure.com)

### 2. Clone & setup

```bash
git clone https://github.com/Ghenghis/AzureVoiceMicro.git
cd AzureVoiceMicro
flutter pub get
```

### 3. Configure Azure credentials

Copy `.env.example` to `.env` and fill in your key:

```bash
cp .env.example .env
```

```
AZURE_KEY=your32charkeyfromportalazurecom
AZURE_REGION=eastus
```

Or enter credentials at runtime via the in-app Settings screen (⚙️).

### 4. Run

```bash
# Windows desktop
flutter run -d windows

# Android (device connected)
flutter run -d android
```

### 5. Build releases

```bash
flutter build windows --release
flutter build apk --release
```

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── models/
│   └── azure_voice.dart         # Voice data model + curated list
├── services/
│   ├── azure_tts_service.dart   # Azure TTS REST calls + audio playback
│   ├── mic_service.dart         # speech_to_text wrapper
│   └── credential_service.dart  # Secure key storage (DPAPI / EncryptedSharedPrefs)
├── providers/
│   └── voice_state.dart         # App state (Provider)
├── screens/
│   ├── main_screen.dart         # Primary UI
│   ├── voice_picker_screen.dart # Scrollable Azure voice list
│   └── settings_screen.dart     # Azure credentials entry
└── widgets/
    ├── mic_indicator.dart        # Animated mic orb (pulse + glow)
    ├── transcript_display.dart   # Live + interim transcript
    └── voice_card.dart           # Voice selection tile
```

## Azure Setup

1. Go to [portal.azure.com](https://portal.azure.com)
2. Create → **Azure AI Services** (multi-service) or **Speech Service**
3. Region: pick closest (`eastus`, `westeurope`, etc.)
4. Pricing: **Free F0** — 5 hours STT/month, 0.5M TTS chars/month

From your resource → **Keys and Endpoint**, copy Key 1 and the region.

## Architecture

```
MicService (speech_to_text)
       │  final transcript
       ▼
VoiceState (Provider)  ──▶  AzureTtsService (http POST SSML)
       │                              │
       │                        Azure TTS API
       │                              │
       ▼                        MP3 audio bytes
  MainScreen UI                       │
                                AudioPlayer (just_audio)
```

## License

MIT
