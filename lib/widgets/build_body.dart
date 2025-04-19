import 'package:audio_player/widgets/recordings_list.dart';
import 'package:audio_player/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';

class BuildBody extends StatelessWidget {
  final bool isRecording;
  final TextEditingController searchController;
  final List<String> recordings;
  final String? currentlyPlaying;
  final Future<void> Function(String) deleteRecording;
  final AudioPlayer audioPlayer;
  final Future <void> Function() loadRecordings;

  final void Function(String?) onCurrentlyPlayingChanged;
  final void Function(String) searchFunction;
  const BuildBody({
    super.key,
    required this.isRecording,
    required this.searchController,
    required this.recordings,
    required this.currentlyPlaying,
    required this.deleteRecording,
    required this.audioPlayer,
    required this.onCurrentlyPlayingChanged,
    required this.searchFunction, required this.loadRecordings,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: isRecording || recordings.isEmpty
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecording)
              Center(
                  child: MiniMusicVisualizer(
                color: Theme.of(context).indicatorColor,
                width: size.width * 0.3,
                height: size.height * 0.3,
                animate: true,
              ))
            else if (recordings.isEmpty)
              Column(
                children: [
                  Icon(
                    Icons.mic_none,
                    size: size.height * 0.1,
                    color: Theme.of(context).cardColor,
                  ),
                  const Text(
                    textAlign: TextAlign.center,
                    'Welcome, click the button to start recording',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    child: SearchField(
                      loadRecordings: loadRecordings,
                        searchController: searchController,
                        searchFunction: searchFunction),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.025),
              Expanded(
                  child: RecordingsList(
                      isRecording: isRecording,
                      searchController: searchController,
                      recordings: recordings,
                      deleteRecording: deleteRecording,
                      audioPlayer: audioPlayer,
                      onCurrentlyPlayingChanged: onCurrentlyPlayingChanged)),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
