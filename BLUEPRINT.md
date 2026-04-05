## Azure Voice Micro App — Blueprint  
https://github.com/Ghenghis/AzureVoiceMicro

\> **One purpose:** User speaks → mic auto-transcribes → plays back instantly as the selected Azure AI voice.  
\> **Platforms:** Android (phone/tablet) + Windows (desktop/touch screen)  
\> **Input:** Touch AND mouse — no buttons required, fully hands-free

## Table of Contents

1.  [App Concept](#1-app-concept)
2.  [Recommended Tech Stack](#2-recommended-tech-stack)
3.  [Architecture Overview](#3-architecture-overview)
4.  [Project Structure](#4-project-structure)
5.  [Azure Setup](#5-azure-setup)
6.  [Core App Flow](#6-core-app-flow)
7.  [UI Design](#7-ui-design)
8.  [Flutter Implementation Guide](#8-flutter-implementation-guide)
9.  [Voice Selection Screen](#9-voice-selection-screen)
10.  [Auto-Transcription Engine](#10-auto-transcription-engine)
11.  [TTS Playback Engine](#11-tts-playback-engine)
12.  [Touch + Mouse Input Handling](#12-touch--mouse-input-handling)
13.  [Build — Android](#13-build--android)
14.  [Build — Windows](#14-build--windows)
15.  [Alternative Stack: React Native](#15-alternative-stack-react-native)
16.  [Alternative Stack: Capacitor PWA](#16-alternative-stack-capacitor-pwa)
17.  [Settings & Credential Storage](#17-settings--credential-storage)
18.  [Key Code Snippets](#18-key-code-snippets)

## 1\. App Concept

```plaintext
┌─────────────────────────────────────────┐
│            AZURE VOICE MICRO            │
│  ┌───────────────────────────────────┐  │
│  │  🎤  Listening...                 │  │
│  │  "Hello, how are you today"       │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ◉  Aria (Neural) — en-US              │
│  ○  Jenny (Neural) — en-US             │
│  ○  Guy (Neural) — en-US               │
│  ○  Emma (Neural) — en-GB              │
│                                         │
│  [  ▶ HOLD TO SPEAK / AUTO MODE  ]     │
└─────────────────────────────────────────┘
```

### What it does

*   Microphone always listening (auto mode) or on hold-to-speak (manual mode)
*   Azure Speech Services transcribes speech in real-time
*   Text immediately sent to Azure Neural TTS
*   AI voice plays through speakers
*   User selects the output voice from a scrollable list

### What it does NOT do

*   No chat, no AI responses, no translation
*   No recording to file
*   No account creation
*   Just: **voice in → AI voice out**

## 2\. Recommended Tech Stack

### Primary Recommendation: Flutter (Dart)

| Feature         | Support                               |
| --------------- | ------------------------------------- |
| Android         | ✅ Native APK                          |
| Windows         | ✅ Native EXE                          |
| Touch           | ✅ Built-in gesture system             |
| Mouse           | ✅ Pointer events (hover, click, drag) |
| Single codebase | ✅ One repo → both platforms           |
| Azure REST API  | ✅ `http` package                      |
| Microphone      | ✅ `speech_to_text` package            |
| Audio playback  | ✅ `just_audio` or `audioplayers`      |
| Performance     | ✅ Compiled native                     |

Flutter is the strongest choice because:

*   **Single Dart codebase** compiles to both Android APK and Windows EXE natively
*   Microsoft's Azure REST API works over `http` calls — no SDK lock-in
*   Touch gestures and mouse/pointer events handled identically via Flutter's `GestureDetector` and `Listener`
*   UI renders at 60/120fps on both platforms

## 3\. Architecture Overview

```plaintext
┌──────────────────────────────────────────────────────────┐
│                     FLUTTER APP                          │
│                                                          │
│  ┌─────────────┐   ┌──────────────┐   ┌───────────────┐ │
│  │  MicService │   │  VoiceState  │   │  AudioService │ │
│  │             │──▶│  (Provider)  │──▶│               │ │
│  │ speech_to_  │   │              │   │ just_audio /  │ │
│  │ text plugin │   │ - transcript │   │ audioplayers  │ │
│  │             │   │ - selectedV  │   │               │ │
│  └─────────────┘   │ - isListening│   └───────────────┘ │
│                    │ - isSpeaking │                      │
│                    └──────┬───────┘                      │
│                           │                              │
│                    ┌──────▼───────┐                      │
│                    │ AzureTTS     │                      │
│                    │ Service      │                      │
│                    │              │                      │
│                    │ REST POST to │                      │
│                    │ Azure TTS    │                      │
│                    │ endpoint     │                      │
│                    └──────────────┘                      │
└──────────────────────────────────────────────────────────┘
         │                               │
   Azure Speech                    Azure TTS
   Cognitive Svcs                  Cognitive Svcs
   (STT endpoint)                  (TTS endpoint)
```

### State Management

Use **Provider** (simple) or **Riverpod** (recommended for larger apps).

## 4\. Project Structure

```plaintext
azure_voice_micro/
├── android/                    # Android native config
│   └── app/
│       └── src/main/
│           └── AndroidManifest.xml   # RECORD_AUDIO permission
├── windows/                    # Windows native config
├── lib/
│   ├── main.dart               # Entry point
│   ├── app.dart                # MaterialApp + theme
│   ├── models/
│   │   └── azure_voice.dart    # Voice data model
│   ├── services/
│   │   ├── azure_tts_service.dart    # POST to Azure TTS REST
│   │   ├── mic_service.dart          # speech_to_text wrapper
│   │   └── credential_service.dart   # Secure key storage
│   ├── providers/
│   │   └── voice_state.dart          # App state (Provider/Riverpod)
│   ├── screens/
│   │   ├── main_screen.dart          # Primary UI
│   │   └── voice_picker_screen.dart  # Azure voice list
│   └── widgets/
│       ├── mic_indicator.dart        # Animated mic orb
│       ├── transcript_display.dart   # Live transcript
│       └── voice_card.dart           # Voice selection tile
├── pubspec.yaml                # Dependencies
├── .env                        # API key (git-ignored)
└── README.md
```

## 5\. Azure Setup

### Step 1: Create Azure Cognitive Services Resource

1.  Go to [portal.azure.com](https://portal.azure.com)
2.  Create → **Azure AI Services** (multi-service) or **Speech Service**
3.  Region: pick closest to users (e.g., `eastus`, `westeurope`)
4.  Pricing: **Free F0** for development (5 hours STT/month, 0.5M TTS chars/month)

### Step 2: Get Credentials

From your Azure resource → **Keys and Endpoint**:

```plaintext
Key 1:    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   (32-char hex)
Region:   eastus
Endpoint: https://eastus.api.cognitive.microsoft.com/
```

### Step 3: Azure TTS Endpoint

```plaintext
POST https://{region}.tts.speech.microsoft.com/cognitiveservices/v1

Headers:
  Ocp-Apim-Subscription-Key: {your_key}
  Content-Type: application/ssml+xml
  X-Microsoft-OutputFormat: audio-16khz-128kbitrate-mono-mp3

Body (SSML):
  <speak version="1.0" xml:lang="en-US">
    <voice xml:lang="en-US" name="en-US-AriaNeural">
      Hello world
    </voice>
  </speak>
```

### Step 4: Azure STT (Speech-to-Text)

The `speech_to_text` Flutter plugin can use either:

*   **Device built-in STT** (Google/Windows) — free, no API key needed
*   **Azure Speech SDK** — better accuracy, needs key

\> **Recommendation:** Use the device built-in STT (Google on Android, Windows Speech on desktop) for transcription — it's free, works offline, and requires no extra setup. Only Azure TTS needs the API key.

## 6\. Core App Flow

```plaintext
App Launch
     │
     ▼
Load saved credentials + selected voice from secure storage
     │
     ▼
Start MicService (continuous listening)
     │
     ├── User speaks
     │        │
     │        ▼
     │   STT recognizes phrase (partial/final)
     │        │
     │        ▼
     │   On FINAL result → send text to AzureTTSService
     │        │
     │        ▼
     │   Azure returns MP3 audio bytes
     │        │
     │        ▼
     │   AudioService.play(audioBytes)
     │        │
     │        ▼
     │   AI voice plays through speakers ◀──────────────┐
     │                                                   │
     └── User selects different voice                   │
              │                                          │
              ▼                                          │
         VoiceState.selectedVoice = newVoice ───────────┘
```

## 7\. UI Design

### Layout (Portrait + Landscape adaptive)

```plaintext
┌────────────────────────────────────────┐
│  AZURE VOICE MICRO           ⚙️        │ ← Settings icon (top right)
├────────────────────────────────────────┤
│                                        │
│         🎙️ [ANIMATED ORB]             │ ← Pulsing when listening
│                                        │   Glowing when speaking TTS
│  ┌────────────────────────────────┐   │
│  │  "What you said goes here..."  │   │ ← Live transcript (read-only)
│  └────────────────────────────────┘   │
│                                        │
├────────────────────────────────────────┤
│  OUTPUT VOICE                          │
│  ┌──────────────────────────────────┐  │
│  │ ◉  Aria Neural    🇺🇸 en-US   ▶ │  │ ← Selected voice row
│  └──────────────────────────────────┘  │
│                                        │
│  [    CHANGE VOICE    ]                │ ← Opens voice picker
│                                        │
└────────────────────────────────────────┘
```

### Touch/Mouse Interactions

| Gesture                 | Action                                      |
| ----------------------- | ------------------------------------------- |
| Tap mic orb             | Toggle auto-listen on/off                   |
| Long-press mic orb      | Hold-to-speak mode                          |
| Tap voice row           | Open voice picker                           |
| Scroll voice list       | Scroll voices (touch scroll or mouse wheel) |
| Hover voice row (mouse) | Highlight on hover                          |
| Tap settings ⚙️          | Open settings sheet                         |

### Adaptive Input — `GestureDetector` + `MouseRegion`

Flutter handles both with the same widget tree:

```plaintext
MouseRegion(         // mouse hover highlight
  onEnter: (_) =&gt; setState(() =&gt; _hovered = true),
  onExit:  (_) =&gt; setState(() =&gt; _hovered = false),
  child: GestureDetector(   // touch + mouse click
    onTap: _selectVoice,
    onLongPress: _holdToSpeak,
    child: VoiceCard(...),
  ),
)
```

## 8\. Flutter Implementation Guide

### pubspec.yaml Dependencies

```plaintext
name: azure_voice_micro
description: Azure AI Voice - speak and hear yourself as any Azure neural voice

environment:
  sdk: '&gt;=3.0.0 &lt;4.0.0'
  flutter: '&gt;=3.16.0'

dependencies:
  flutter:
    sdk: flutter

  # State management
  provider: ^6.1.1              # or riverpod: ^2.5.1

  # Microphone / STT
  speech_to_text: ^6.6.0        # Device STT (free, no key)

  # HTTP for Azure TTS REST calls
  http: ^1.2.0

  # Audio playback
  just_audio: ^0.9.36           # Cross-platform audio player

  # Secure credential storage
  flutter_secure_storage: ^9.0.0

  # Permissions
  permission_handler: ^11.3.0

  # Environment / config
  flutter_dotenv: ^5.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - .env
```

### Android Permissions (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO">
<uses-permission android:name="android.permission.INTERNET">
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS">
```

### Windows Manifest

Add to `windows/runner/Runner.rc` — no special microphone manifest needed for Windows 10+, but ensure the app requests mic via `permission_handler`.

## 9\. Voice Selection Screen

```plaintext
// lib/screens/voice_picker_screen.dart

class VoicePickerScreen extends StatefulWidget {
  final String currentVoiceId;
  final Function(AzureVoice) onSelect;
  const VoicePickerScreen({required this.currentVoiceId, required this.onSelect});

  @override
  State<voicepickerscreen> createState() =&gt; _VoicePickerScreenState();
}

class _VoicePickerScreenState extends State<voicepickerscreen> {
  final _searchController = TextEditingController();
  List<azurevoice> _filtered = azureEnglishVoices;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select AI Voice')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search voices...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (q) =&gt; setState(() {
                _filtered = azureEnglishVoices
                    .where((v) =&gt; v.displayName.toLowerCase().contains(q.toLowerCase())
                               || v.locale.toLowerCase().contains(q.toLowerCase()))
                    .toList();
              }),
            ),
          ),

          // Voice list
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final voice = _filtered[i];
                final selected = voice.id == widget.currentVoiceId;

                return MouseRegion(  // ← mouse hover support
                  cursor: SystemMouseCursors.click,
                  child: ListTile(
                    leading: Icon(
                      selected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: selected ? Theme.of(context).colorScheme.primary : null,
                    ),
                    title: Text(voice.displayName,
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text('${voice.locale}  •  ${voice.gender}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      tooltip: 'Preview voice',
                      onPressed: () =&gt; _previewVoice(voice),
                    ),
                    selected: selected,
                    onTap: () {
                      widget.onSelect(voice);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _previewVoice(AzureVoice voice) async {
    final tts = context.read<voicestate>().ttsService;
    await tts.speak('Hello, I am ${voice.displayName}.', voice);
  }
}
```

### Azure Voice Data Model

```plaintext
// lib/models/azure_voice.dart

class AzureVoice {
  final String id;          // e.g. 'en-US-AriaNeural'
  final String displayName; // e.g. 'Aria'
  final String locale;      // e.g. 'en-US'
  final String gender;      // 'Female' | 'Male'
  final String style;       // 'neural' | 'standard'

  const AzureVoice({
    required this.id,
    required this.displayName,
    required this.locale,
    required this.gender,
    this.style = 'neural',
  });
}

// Curated English voices list (add more as needed)
const List<azurevoice> azureEnglishVoices = [
  AzureVoice(id: 'en-US-AriaNeural',      displayName: 'Aria',      locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-JennyNeural',     displayName: 'Jenny',     locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-GuyNeural',       displayName: 'Guy',       locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-EricNeural',      displayName: 'Eric',      locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-MichelleNeural',  displayName: 'Michelle',  locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-US-BrandonNeural',   displayName: 'Brandon',   locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-ChristopherNeural',displayName:'Christopher',locale: 'en-US', gender: 'Male'),
  AzureVoice(id: 'en-US-ElizabethNeural', displayName: 'Elizabeth', locale: 'en-US', gender: 'Female'),
  AzureVoice(id: 'en-GB-SoniaNeural',     displayName: 'Sonia',     locale: 'en-GB', gender: 'Female'),
  AzureVoice(id: 'en-GB-RyanNeural',      displayName: 'Ryan',      locale: 'en-GB', gender: 'Male'),
  AzureVoice(id: 'en-AU-NatashaNeural',   displayName: 'Natasha',   locale: 'en-AU', gender: 'Female'),
  AzureVoice(id: 'en-AU-WilliamNeural',   displayName: 'William',   locale: 'en-AU', gender: 'Male'),
  AzureVoice(id: 'en-CA-ClaraNeural',     displayName: 'Clara',     locale: 'en-CA', gender: 'Female'),
  AzureVoice(id: 'en-IN-NeerjaNeural',    displayName: 'Neerja',    locale: 'en-IN', gender: 'Female'),
  AzureVoice(id: 'en-US-AnaNeural',       displayName: 'Ana',       locale: 'en-US', gender: 'Female'),
  // Load full list dynamically from Azure API (see section 11)
];
```

## 10\. Auto-Transcription Engine

```plaintext
// lib/services/mic_service.dart

import 'package:speech_to_text/speech_to_text.dart';

class MicService {
  final SpeechToText _stt = SpeechToText();
  bool _available = false;

  Future<bool> initialize() async {
    _available = await _stt.initialize(
      onError: (e) =&gt; print('STT error: $e'),
      onStatus: (s) =&gt; print('STT status: $s'),
    );
    return _available;
  }

  // Auto-continuous listen — calls onResult for each final phrase
  Future<void> startListening({
    required Function(String text, bool isFinal) onResult,
  }) async {
    if (!_available) return;

    await _stt.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      listenFor: const Duration(seconds: 30),    // max session
      pauseFor: const Duration(seconds: 2),      // silence = phrase end
      listenMode: ListenMode.dictation,           // continuous
      cancelOnError: false,
      partialResults: true,                       // show interim text
    );
  }

  Future<void> stopListening() async {
    await _stt.stop();
  }

  bool get isListening =&gt; _stt.isListening;
}
```

\> **Note:** `speech_to_text` uses Google Speech on Android and Windows Speech Recognition on Windows — both are free, built-in, and require no API key. For higher accuracy, you can optionally replace with Azure Speech SDK direct HTTP calls.

## 11\. TTS Playback Engine

```plaintext
// lib/services/azure_tts_service.dart

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import '../models/azure_voice.dart';

class AzureTtsService {
  final String subscriptionKey;
  final String region;

  late final AudioPlayer _player = AudioPlayer();
  String? _cachedToken;
  DateTime? _tokenExpiry;

  AzureTtsService({required this.subscriptionKey, required this.region});

  // Speak text as selected voice
  Future<void> speak(String text, AzureVoice voice) async {
    if (text.trim().isEmpty) return;

    final ssml = '''
<speak version="1.0" xml:lang="${voice.locale}">
  <voice name="${voice.id}">${_escapeXml(text)}</voice>
</speak>''';

    final url = Uri.parse(
      'https://$region.tts.speech.microsoft.com/cognitiveservices/v1',
    );

    final response = await http.post(
      url,
      headers: {
        'Ocp-Apim-Subscription-Key': subscriptionKey,
        'Content-Type': 'application/ssml+xml',
        'X-Microsoft-OutputFormat': 'audio-16khz-128kbitrate-mono-mp3',
        'User-Agent': 'AzureVoiceMicro/1.0',
      },
      body: ssml,
    );

    if (response.statusCode != 200) {
      throw Exception('Azure TTS error ${response.statusCode}: ${response.body}');
    }

    // Play MP3 bytes directly
    await _player.stop();
    await _player.setAudioSource(
      _BytesAudioSource(response.bodyBytes),
    );
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  bool get isPlaying =&gt; _player.playing;

  String _escapeXml(String text) =&gt; text
      .replaceAll('&amp;', '&amp;')
      .replaceAll('&lt;', '&lt;')
      .replaceAll('&gt;', '&gt;')
      .replaceAll('"', '"');

  // Load full voice list dynamically from Azure
  Future<list<azurevoice>&gt; fetchVoiceList() async {
    final url = Uri.parse(
      'https://$region.tts.speech.microsoft.com/cognitiveservices/voices/list',
    );
    final response = await http.get(url, headers: {
      'Ocp-Apim-Subscription-Key': subscriptionKey,
    });
    if (response.statusCode != 200) return [];

    final List<dynamic> json = jsonDecode(response.body);
    return json
        .where((v) =&gt; (v['Locale'] as String).startsWith('en-'))
        .map((v) =&gt; AzureVoice(
              id: v['ShortName'],
              displayName: v['LocalName'],
              locale: v['Locale'],
              gender: v['Gender'],
            ))
        .toList();
  }
}

// In-memory byte stream for just_audio
class _BytesAudioSource extends StreamAudioSource {
  final Uint8List _bytes;
  _BytesAudioSource(this._bytes) : super(tag: 'azure-tts');

  @override
  Future<streamaudioresponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}
```

## 12\. Touch + Mouse Input Handling

Flutter handles touch and mouse through the same `GestureDetector` + `MouseRegion` combo. No platform branching needed.

### Animated Mic Orb (core widget)

```plaintext
// lib/widgets/mic_indicator.dart

class MicIndicator extends StatefulWidget {
  final bool isListening;
  final bool isSpeaking;
  final VoidCallback onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  const MicIndicator({
    required this.isListening,
    required this.isSpeaking,
    required this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
  });
  ...
}

class _MicIndicatorState extends State<micindicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSpeaking
        ? Colors.green
        : widget.isListening
            ? Colors.blue
            : Colors.grey.shade600;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) =&gt; setState(() =&gt; _hovering = true),
      onExit:  (_) =&gt; setState(() =&gt; _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPressStart: (_) =&gt; widget.onLongPressStart?.call(),
        onLongPressEnd:   (_) =&gt; widget.onLongPressEnd?.call(),
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, child) {
            final scale = (widget.isListening || widget.isSpeaking)
                ? 1.0 + _pulse.value * 0.15   // pulse animation
                : _hovering ? 1.05 : 1.0;      // hover scale (mouse)

            return Transform.scale(
              scale: scale,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                  border: Border.all(color: color, width: 3),
                  boxShadow: (widget.isListening || widget.isSpeaking)
                      ? [BoxShadow(color: color.withOpacity(0.4),
                                   blurRadius: 20 + _pulse.value * 20,
                                   spreadRadius: 4)]
                      : [],
                ),
                child: Icon(
                  widget.isSpeaking ? Icons.volume_up
                      : widget.isListening ? Icons.mic
                      : Icons.mic_none,
                  size: 48,
                  color: color,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

## 13\. Build — Android

### Prerequisites

*   Flutter SDK 3.16+
*   Android Studio with SDK 33+
*   Java 17

### Steps

```plaintext
# 1. Create project
flutter create azure_voice_micro --platforms=android,windows

# 2. Add dependencies (see pubspec.yaml above)
flutter pub get

# 3. Debug run on connected Android device
flutter run -d android

# 4. Build release APK
flutter build apk --release

# 5. Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android Signing (for distribution)

```plaintext
# Generate keystore
keytool -genkey -v -keystore azure-voice.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias azure-voice

# Add to android/key.properties:
storePassword=yourpass
keyPassword=yourpass
keyAlias=azure-voice
storeFile=../azure-voice.jks

# Build signed APK
flutter build apk --release
```

### Touch Targets

On Android, ensure touch targets are minimum 48×48dp. The mic orb at 120dp is well within spec.

## 14\. Build — Windows

### Prerequisites

*   Flutter SDK 3.16+ with Windows desktop enabled
*   Visual Studio 2022 (with "Desktop development with C++")
*   Windows 10/11

```plaintext
# Enable Windows desktop
flutter config --enable-windows-desktop

# Debug run on Windows
flutter run -d windows

# Build release EXE + installer files
flutter build windows --release

# Output: build/windows/x64/runner/Release/
#   azure_voice_micro.exe  ← main executable
```

### Package as Installer (optional)

Use **Inno Setup** or **NSIS** to wrap the output folder into a single `.exe` installer:

```plaintext
; installer.iss (Inno Setup script)
[Setup]
AppName=Azure Voice Micro
AppVersion=1.0.0
DefaultDirName={autopf}\AzureVoiceMicro
OutputBaseFilename=AzureVoiceMicroSetup
Compression=lzma
SolidCompression=yes

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{autoprograms}\Azure Voice Micro"; Filename: "{app}\azure_voice_micro.exe"
```

### Windows Microphone Permission

Windows 10+ requires user to grant microphone permission. The `permission_handler` plugin handles this automatically on first launch.

### Touch Screen Support on Windows

Flutter on Windows handles touch events natively through the Win32 `WM_TOUCH` and `WM_POINTER` messages. No extra code needed — `GestureDetector` works for both touch and mouse.

## 15\. Alternative Stack: React Native

If you prefer TypeScript (closer to the existing Voiced codebase):

```plaintext
Tech: React Native + @react-native-windows/windows
STT:  @react-native-community/voice
TTS:  Direct fetch to Azure REST (same as Voiced app)
State: Zustand or Redux Toolkit
```

```plaintext
# Create project
npx react-native@latest init AzureVoiceMicro --template react-native-template-typescript

# Add Windows support
cd AzureVoiceMicro
npx react-native-windows-init --overwrite

# Add voice package
npm install @react-native-voice/voice
```

### Pros / Cons vs Flutter

|                 | React Native                     | Flutter                           |
| --------------- | -------------------------------- | --------------------------------- |
| Language        | TypeScript ✅ (familiar)          | Dart (new)                        |
| Windows support | react-native-windows (Microsoft) | First-class native                |
| Android support | ✅ Mature                         | ✅ Mature                          |
| Touch + mouse   | Via PanResponder                 | Via GestureDetector + MouseRegion |
| Azure TTS       | `fetch()` REST calls             | `http` package REST calls         |
| Build size      | Larger                           | Smaller                           |

## 16\. Alternative Stack: Capacitor PWA

Quickest path if already using React/TypeScript — reuse code from the Voiced project:

```plaintext
# Create React app
npm create vite@latest azure-voice-micro -- --template react-ts

# Add Capacitor
npm install @capacitor/core @capacitor/cli
npm install @capacitor/android
npx cap init AzureVoiceMicro com.yourname.azurevoicemicro
npx cap add android

# Build and sync
npm run build
npx cap sync android

# Open in Android Studio
npx cap open android
```

### PWA on Windows

Deploy as a web app or install via Chrome/Edge as a PWA — no native EXE but works on all Windows browsers.

### Reuse from Voiced

Copy:

*   `src/services/AzureTTS.ts` → Azure TTS REST calls
*   `src/services/TauriCredentialsService.ts` → swap with `@capacitor/preferences`
*   Azure voice list data

## 17\. Settings & Credential Storage

Never hardcode API keys. Store them in secure platform storage.

### Flutter (flutter\_secure\_storage)

```plaintext
// lib/services/credential_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    wOptions: WindowsOptions(),  // DPAPI on Windows
  );

  static const _keySubscriptionKey = 'azure_subscription_key';
  static const _keyRegion          = 'azure_region';
  static const _keySelectedVoice   = 'azure_selected_voice';

  Future<void> saveCredentials(String key, String region) async {
    await _storage.write(key: _keySubscriptionKey, value: key);
    await _storage.write(key: _keyRegion, value: region);
  }

  Future&lt;({String? key, String region})&gt; loadCredentials() async {
    final key    = await _storage.read(key: _keySubscriptionKey);
    final region = await _storage.read(key: _keyRegion) ?? 'eastus';
    return (key: key, region: region);
  }

  Future<void> saveSelectedVoice(String voiceId) async {
    await _storage.write(key: _keySelectedVoice, value: voiceId);
  }

  Future<string?> loadSelectedVoice() async {
    return _storage.read(key: _keySelectedVoice);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

### Storage Backend per Platform

| Platform | Backend                              |
| -------- | ------------------------------------ |
| Android  | EncryptedSharedPreferences (AES-256) |
| Windows  | DPAPI (Windows Data Protection API)  |
| iOS      | Keychain                             |
| macOS    | Keychain                             |

## 18\. Key Code Snippets

### main.dart

```plaintext
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/voice_state.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = VoiceState();
  await state.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: state,
      child: const AzureVoiceMicroApp(),
    ),
  );
}

class AzureVoiceMicroApp extends StatelessWidget {
  const AzureVoiceMicroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Azure Voice Micro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
```

### VoiceState Provider (core state)

```plaintext
// lib/providers/voice_state.dart

class VoiceState extends ChangeNotifier {
  final MicService     _mic   = MicService();
  final CredentialService _creds = CredentialService();
  late final AzureTtsService ttsService;

  AzureVoice selectedVoice = azureEnglishVoices.first;
  String  transcript  = '';
  String  interimText = '';
  bool    isListening = false;
  bool    isSpeaking  = false;
  bool    isReady     = false;
  String? error;

  Future<void> initialize() async {
    final creds = await _creds.loadCredentials();
    if (creds.key == null) {
      error = 'No Azure credentials. Open settings to configure.';
      notifyListeners();
      return;
    }

    ttsService = AzureTtsService(
      subscriptionKey: creds.key!,
      region: creds.region,
    );

    final voiceId = await _creds.loadSelectedVoice();
    if (voiceId != null) {
      selectedVoice = azureEnglishVoices.firstWhere(
        (v) =&gt; v.id == voiceId,
        orElse: () =&gt; azureEnglishVoices.first,
      );
    }

    await _mic.initialize();
    isReady = true;
    notifyListeners();
    await startListening();  // auto-start
  }

  Future<void> startListening() async {
    isListening = true;
    notifyListeners();

    await _mic.startListening(
      onResult: (text, isFinal) {
        interimText = isFinal ? '' : text;
        if (isFinal &amp;&amp; text.isNotEmpty) {
          transcript += (transcript.isEmpty ? '' : '\n') + text;
          _speakText(text);
        }
        notifyListeners();
      },
    );
  }

  Future<void> _speakText(String text) async {
    isSpeaking = true;
    notifyListeners();

    try {
      await ttsService.speak(text, selectedVoice);
    } catch (e) {
      error = 'TTS error: $e';
    }

    isSpeaking = false;
    notifyListeners();

    // Resume listening after TTS finishes
    if (isListening) await startListening();
  }

  Future<void> selectVoice(AzureVoice voice) async {
    selectedVoice = voice;
    await _creds.saveSelectedVoice(voice.id);
    notifyListeners();
  }

  Future<void> toggleListening() async {
    if (isListening) {
      await _mic.stopListening();
      isListening = false;
    } else {
      await startListening();
    }
    notifyListeners();
  }
}
```

### Main Screen

```plaintext
// lib/screens/main_screen.dart

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<voicestate>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Azure Voice Micro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =&gt; Navigator.push(
              context, MaterialPageRoute(builder: (_) =&gt; const SettingsScreen())
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const Spacer(),

          // Animated mic orb
          MicIndicator(
            isListening: state.isListening,
            isSpeaking:  state.isSpeaking,
            onTap: state.toggleListening,
          ),

          const SizedBox(height: 32),

          // Live transcript
          TranscriptDisplay(
            text:    state.transcript,
            interim: state.interimText,
          ),

          const Spacer(),

          // Selected voice row + change button
          _VoiceRow(state: state),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _VoiceRow extends StatelessWidget {
  final VoiceState state;
  const _VoiceRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Icon(Icons.graphic_eq),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${state.selectedVoice.displayName}  •  ${state.selectedVoice.locale}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () =&gt; Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =&gt; VoicePickerScreen(
                  currentVoiceId: state.selectedVoice.id,
                  onSelect: state.selectVoice,
                ),
              ),
            ),
            child: const Text('Change Voice'),
          ),
        ],
      ),
    );
  }
}
```

## Quick Start Summary

```plaintext
# 1. Install Flutter
# https://docs.flutter.dev/get-started/install/windows

# 2. Create the project
flutter create azure_voice_micro --platforms=android,windows
cd azure_voice_micro

# 3. Replace pubspec.yaml with the one in section 8
flutter pub get

# 4. Create the files from sections 8-18 above

# 5. Add your Azure key to a .env file (git-ignored):
echo "AZURE_KEY=your32charkey" &gt;&gt; .env
echo "AZURE_REGION=eastus"     &gt;&gt; .env

# 6. Run on Windows desktop
flutter run -d windows

# 7. Run on Android (with device connected)
flutter run -d android

# 8. Build both releases
flutter build windows --release
flutter build apk --release
```

_Blueprint version 1.0 — Azure Voice Micro — Flutter (Android + Windows)_  
_Azure Cognitive Services · speech\_to\_text · just\_audio · flutter\_secure\_storage_  
\</string?>\</list