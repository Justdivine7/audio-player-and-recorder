
A simple yet powerful Flutter application that allows users to record and play audio effortlessly. The app is theme-aware (light/dark mode), supports offline storage, and features real-time audio visualizations.

✨ Features
🎧 Record & Play Audio
Record high-quality audio using the record package and play it back with the just_audio package.

🌗 Adaptive Theming
The UI automatically adapts to the system's light or dark mode.

🔍 Search Functionality
Easily search through saved recordings by filename.

💾 Persistent Storage
Recordings are saved locally using shared_preferences for quick access and state management.

📂 File Management
Utilizes path_provider to manage recording storage within app directories.

📊 Live Visualizer
Real-time waveform visualization for both recording and playback powered by mini_music_visualizer.


📦 Dependencies

Package	Description
just_audio:	Audio playback
record:	Audio recording
shared_preferences:	Local storage for saved data
path_provider:	Access to device storage paths
mini_music_visualizer:	Waveform visualizer during audio


🚀 Getting Started
Clone the repository

git clone https://github.com/your-username/flutter-audio-recorder-player.git
cd flutter-audio-recorder-player

Install dependencies

flutter pub get
Run the app
flutter run


📂 Folder Structure (Brief)

lib/
│
├── main.dart                    # App entry point
├── widgets/                     # Custom widgets (e.g., build body)
├── screen/                      # App screens
└── theme/                      # Light & dark mode themes


🙌 Contribution
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

📄 License
This project is open-sourced under the MIT License.
