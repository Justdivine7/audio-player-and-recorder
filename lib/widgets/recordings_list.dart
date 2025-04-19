import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:path/path.dart' as p;
class RecordingsList extends StatelessWidget {
  final bool isRecording;
  final TextEditingController searchController;
  final List<String> recordings;
  final String? currentlyPlaying;
  final Future<void> Function(String) deleteRecording;
  final AudioPlayer audioPlayer;

  final void Function(String?) onCurrentlyPlayingChanged;
  const RecordingsList(
      {super.key,
      required this.isRecording,
      required this.searchController,
      required this.recordings,
      this.currentlyPlaying,
      required this.deleteRecording,
      required this.audioPlayer,
      required this.onCurrentlyPlayingChanged});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: recordings.length,
      itemBuilder: (context, index) {
        final recording = recordings[index];
        print(
            'Building ListTile for $recording, playing: ${audioPlayer.playing}');
        return Card(
          child: ListTile(
            tileColor: Theme.of(context).cardColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            leading: recording == currentlyPlaying
                ? StreamBuilder(
                    stream: audioPlayer.playerStateStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      return Icon(
                        playing
                            ? Icons.pause_circle_outline
                            : Icons.play_circle,
                        color: Theme.of(context).indicatorColor,
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
                        final playing = snapshot.data?.playing ?? false;
                        return MiniMusicVisualizer(
                          color: Theme.of(context).indicatorColor,
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
                  print('Audio paused, playing: ${audioPlayer.playing}');
                } else {
                  await audioPlayer.play();
                  print('Audio playing, playing: ${audioPlayer.playing}');
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
                      content: Text('Error playing $recording'),
                    ),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }
}
