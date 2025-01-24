import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  int recordingCount = 0;
  List<String> recordings = [];
  AudioRecorder audioRecorder = AudioRecorder();
  AudioPlayer audioPlayer = AudioPlayer();
  String? recordingPath;
  bool isRecording = false;
  String? currentlyPlaying;

  Future<void> saveRecordings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recordings', recordings);
    await prefs.setInt('recordingCount', recordingCount);
  }

  Future<void> loadRecordings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recordings = prefs.getStringList('recordings') ?? [];
      recordingCount = prefs.getInt('recordingCount') ?? 0;
    });
  }

  Future<void> deleteRecording(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        setState(() {
          recordings.remove(filePath);
          recordingCount--;
        });
        await saveRecordings();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    loadRecordings();
  }

  @override
  void dispose() {
    super.dispose();
    saveRecordings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUi(),
      floatingActionButton: _recordingButton(),
    );
  }

  Widget _buildUi() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isRecording)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Recording.....................'),
              ],
            ),
          if (recordings.isNotEmpty && !isRecording)
            ListView.separated(
              shrinkWrap: true,
              itemCount: recordings.length,
              itemBuilder: (context, index) {
                final recording = recordings[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: recording == currentlyPlaying
                        ? const Icon(Icons.pause_circle)
                        : const Icon(Icons.play_circle),
                    title: Text(p.basename(recording)),
                    trailing: PopupMenuButton(onSelected: (String value) {
                      if (value == 'delete') {
                        deleteRecording(recording);
                      }
                    }, itemBuilder: (
                      BuildContext context,
                    ) {
                      return [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ];
                    }),
                    onTap: () async {
                      if (recording == currentlyPlaying) {
                        audioPlayer.pause();
                        setState(() {
                          currentlyPlaying = null;
                        });
                      } else {
                        if (currentlyPlaying != null) {
                          await audioPlayer.stop();
                        }
                        await audioPlayer.setFilePath(recording);
                        audioPlayer.play();
                        setState(() {
                          currentlyPlaying = recording;
                        });
                        audioPlayer.playerStateStream.listen((state) {
                          if (state.processingState ==
                              ProcessingState.completed) {
                            setState(() {
                              currentlyPlaying = null;
                            });
                          }
                        });
                      }
                    },
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              },
            ),
          if (recordingPath == null && recordings.isEmpty && isRecording)
            const Center(
              child: Text(
                textAlign: TextAlign.center,
                'No recording found, click the button to start recording',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _recordingButton() {
    return FloatingActionButton(
      onPressed: () async {
        if (isRecording) {
          String? filePath = await audioRecorder.stop();
          if (filePath != null) {
            setState(() {
              isRecording = false;
              recordingPath = filePath;
              recordings.add(filePath); // Save the full path
            });
            await saveRecordings();
          }
        } else {
          if (await audioRecorder.hasPermission()) {
            final Directory? downloadsDir = await getDownloadsDirectory();
            if (downloadsDir == null) {
              throw Exception('No downloads directory');
            }
            recordingCount++;
            final String uniqueFileName = 'recording$recordingCount.mp3';
            final String audioPath = p.join(downloadsDir.path, uniqueFileName);
            await audioRecorder.start(const RecordConfig(), path: audioPath);
            setState(() {
              isRecording = true;
              recordingPath = null;
            });
          }
        }
      },
      child: isRecording ? const Icon(Icons.stop) : const Icon(Icons.mic),
    );
  }
}
