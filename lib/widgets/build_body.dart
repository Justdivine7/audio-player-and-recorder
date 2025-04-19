import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:path/path.dart' as p;

class BuildBody extends StatelessWidget {
  final bool isRecording;
  final TextEditingController searchController;
  final List<String> recordings;
  final String? currentlyPlaying;
  final Future<void> Function(String) deleteRecording;
  final AudioPlayer audioPlayer;
  final RecorderController recorderController;
  // final String? recordingPath;
  final void Function(String?) onCurrentlyPlayingChanged;
  final void Function(String) searchFunction;
  const BuildBody(
      {super.key,
      required this.isRecording,
      required this.searchController,
      required this.recordings,
      required this.currentlyPlaying,
      required this.deleteRecording,
      required this.audioPlayer,
      // required this.recordingPath,
      required this.onCurrentlyPlayingChanged,
      required this.searchFunction,
      required this.recorderController});

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isRecording)
              Center(
                child: AudioWaveforms(
                  enableGesture: false,
                  size: Size(size.width * 0.5, size.height * 0.3),
                  recorderController: recorderController,
                  // waveStyle: WaveStyle(
                  //   waveColor: Colors.greenAccent,
                  //   extendWaveform: true,
                  //   showMiddleLine: true,
                  //   spacing: 6,
                  //   waveThickness: 2.5,
                  // ),
                ),
              )
            else if (recordings.isEmpty)
              const Text(
                textAlign: TextAlign.center,
                'No recording found, click the button to start recording',
                style: TextStyle(
                  fontSize: 18,
                ),
              )
            else ...[
              TextField(
                controller: searchController,
                onChanged: searchFunction,
                onSubmitted: searchFunction,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.shade600,
                      width: 2,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.shade400,
                    ),
                  ),
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.025),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: recordings.length,
                  itemBuilder: (context, index) {
                    final recording = recordings[index];
                    return Card(
                      child: ListTile(
                        leading: recording == currentlyPlaying
                            ? const Icon(Icons.pause_circle)
                            : const Icon(Icons.play_circle),
                        title: Text(p.basename(recording)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            recording == currentlyPlaying
                                ? const MiniMusicVisualizer(
                                    color: Colors.red,
                                    width: 4,
                                    height: 15,
                                    radius: 2,
                                    animate: true,
                                  )
                                : const SizedBox(),
                            PopupMenuButton(
                              onSelected: (String value) {
                                if (value == 'delete') {
                                  deleteRecording(recording);
                                }
                              },
                              itemBuilder: (
                                BuildContext context,
                              ) {
                                return [
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ];
                              },
                            ),
                          ],
                        ),
                        onTap: () async {
                          if (recording == currentlyPlaying) {
                            if (audioPlayer.playing) {
                              await audioPlayer.pause();
                            } else {
                              await audioPlayer.play();
                            }
                          } else {
                            if (currentlyPlaying != null) {
                              await audioPlayer.stop();
                            }
                            await audioPlayer.setFilePath(recording);
                            audioPlayer.play();
                            onCurrentlyPlayingChanged(recording);
                            audioPlayer.playerStateStream.listen((state) {
                              if (state.processingState ==
                                  ProcessingState.completed) {
                                onCurrentlyPlayingChanged(null);
                              }
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
