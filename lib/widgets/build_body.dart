import 'package:audio_player/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:path/path.dart' as p;

class BuildBody extends StatelessWidget {
  final bool isRecording;
  final TextEditingController searchController;
  final List<String> recordings;
  final List<String> filteredRecordings;
  final String? currentlyPlaying;
  final Future<void> Function(String) deleteRecording;
  final AudioPlayer audioPlayer;
  final Future<void> Function() loadRecordings;

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
    required this.searchFunction,
    required this.loadRecordings,
    required this.filteredRecordings,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isRecording)
              Center(
                  child: MiniMusicVisualizer(
                color: Theme.of(context).indicatorColor,
                width: size.width * 0.26,
                height: size.height * 0.3,
                animate: true,
              ))
            else if (recordings.isEmpty && searchController.text.isEmpty)
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
                child: filteredRecordings.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: size.height * 0.1,
                            color: Theme.of(context).cardColor,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'No result found',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredRecordings.length,
                        itemBuilder: (context, index) {
                          final recording = filteredRecordings[index];
                          print(
                              'Building ListTile for $recording, playing: ${audioPlayer.playing}');
                          return Card(
                            child: ListTile(
                              tileColor: Theme.of(context).cardColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6)),
                              leading: recording == currentlyPlaying
                                  ? StreamBuilder(
                                      stream: audioPlayer.playerStateStream,
                                      builder: (context, snapshot) {
                                        final playing =
                                            snapshot.data?.playing ?? false;
                                        print('Player state: ${snapshot.data}');

                                        return Icon(
                                          playing
                                              ? Icons.pause_circle_outline
                                              : Icons.play_circle,
                                          color:
                                              Theme.of(context).indicatorColor,
                                        );
                                      })
                                  : const Icon(Icons.play_circle),
                              title: Text(p.basename(recording)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (recording == currentlyPlaying)
                                    StreamBuilder(
                                        stream: audioPlayer.playerStateStream,
                                        builder: (context, snapshot) {
                                          final playing =
                                              snapshot.data?.playing ?? false;
                                          print(
                                              'MiniMusicVisualizer isAnimating: $playing');

                                          return MiniMusicVisualizer(
                                            color: Theme.of(context)
                                                .indicatorColor,
                                            width: 4,
                                            height: 15,
                                            animate: playing,
                                          );
                                        }),
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
                                    print(
                                        'Audio paused, playing: ${audioPlayer.playing}');
                                  } else {
                                    await audioPlayer.play();
                                    print(
                                        'Audio playing, playing: ${audioPlayer.playing}');
                                  }
                                } else {
                                  await audioPlayer.stop();
                                  onCurrentlyPlayingChanged(null);
                                  try {
                                    await audioPlayer.setFilePath(recording);
                                    audioPlayer.play();
                                    onCurrentlyPlayingChanged(recording);
                                    print(
                                        'New audio started: $recording, playing: ${audioPlayer.playing}');
                                  } catch (e) {
                                    onCurrentlyPlayingChanged(null);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Error playing $recording'),
                                      ),
                                    );
                                  }
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
