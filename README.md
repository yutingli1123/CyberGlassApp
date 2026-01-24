# CyberGlass App

A Flutter-based mobile application powered by Gemini 2.5 Flash API, designed to interface with CyberGlass hardware. This app enables real-time, low-latency bidirectional voice and video conversations with an AI assistant.

## Features

-   **Gemini 2.5 Flash Integration**: Uses WebSocket for real-time, bidirectional communication with Google's Gemini 2.5 Flash model.
-   **Low-Latency Audio Streaming**:
    -   Records audio (PCM 16-bit, 16kHz) and streams it to Gemini.
    -   Receives and plays back generated response audio (24kHz).
    -   Includes built-in echo cancellation and noise suppression.
-   **Smart Interaction**:
    -   **Interruptibility**: Automatically stops playback when the user speaks.
    -   **Silence Detection**: Detects when the user finishes speaking to trigger processing.
    -   **Haptic Feedback**: Provides tactile feedback for key interaction states (e.g., latency masking).
-   **Image & Video Capabilities**: Supports sending images and video frames to Gemini for multimodal context.
-   **Bluetooth Integration**: Connects with CyberGlass hardware via BLE (Bluetooth Low Energy) using `flutter_blue_plus`.
-   **Visual Interface**: Features a dynamic, animated orb interface that visualizes connection states (Listening, Processing, Speaking, Paused).

## Architecture

The project follows a clean architecture pattern within the `lib/` directory:

-   `domain/`: Contains business logic and service definitions.
    -   `services/gemini_live_service.dart`: The core service handling the WebSocket connection and audio/video streaming logic.
    -   `services/bluetooth_service.dart`: Manages BLE connections.
-   `presentation/`: Contains UI code.
    -   `views/connection_view.dart`: The main UI screen.
    -   `viewmodels/connection_viewmodel.dart`: Manages state and logic for the connection view using Riverpod.
-   `data/`: Data models and repositories.

## Requirements

-   **Flutter SDK**: `^3.9.2`
-   **Gemini API Key**: A valid Google Gemini API Key with access to the `gemini-2.5-flash-native-audio-preview` or equivalent model.

## Installation & Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/cyber_glass_app.git
    cd cyber_glass_app
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the application:**
    You **must** provide your Gemini API key at runtime using the `--dart-define` flag.

    ```bash
    flutter run --dart-define=GEMINI_API_KEY=YOUR_ACTUAL_API_KEY
    ```

    *Optional:* You can also specify a custom system prompt:
    ```bash
    flutter run \
      --dart-define=GEMINI_API_KEY=YOUR_API_KEY \
      --dart-define=GEMINI_SYSTEM_PROMPT="You are a helpful assistant..."
    ```

## Build

To build the application for release, use the following commands. Note that the API key must be baked into the build using `--dart-define`.

### Android (APK)

```bash
flutter build apk --release --dart-define=GEMINI_API_KEY=YOUR_API_KEY
```

### Android (App Bundle)

```bash
flutter build appbundle --release --dart-define=GEMINI_API_KEY=YOUR_API_KEY
```

### iOS

```bash
flutter build ios --release --no-codesign --dart-define=GEMINI_API_KEY=YOUR_API_KEY
```
*Note: You will need to archive and sign via Xcode for App Store distribution.*

## Permissions

The app requires the following permissions (handled automatically or via `Info.plist`/`AndroidManifest.xml`):

-   **Microphone**: For capturing voice input.
-   **Bluetooth**: For connecting to CyberGlass hardware.

## License

This project is licensed under the **GNU General Public License v3.0**. See the [LICENSE](LICENSE) file for details.
