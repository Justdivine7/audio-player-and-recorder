import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
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
  TextEditingController searchController = TextEditingController();

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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // backgroundColor: Colors.grey.shade600,
      appBar: AppBar(
        title: const Text(
          'Recorder',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildUi(),
      floatingActionButton: _recordingButton(),
    );
  }

  Widget _buildUi() {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment:
              isRecording ? MainAxisAlignment.center : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isRecording
                ? const SizedBox()
                : TextField(
                    controller: searchController,
                    onChanged: (value) {},
                    onSubmitted: (value) {},
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
            const SizedBox(
              height: 20,
            ),
            if (isRecording)
              Center(
                child: MiniMusicVisualizer(
                  color: Colors.grey,
                  width: size.width * 0.3,
                  height: size.width * 0.5,
                  radius: 2,
                  animate: true,
                ),
              ),
            if (recordings.isNotEmpty && !isRecording)
              ListView.builder(
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
              ),
            if (recordingPath == null &&
                recordings.isEmpty &&
                isRecording == false)
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
      ),
    );
  }

  Widget _recordingButton() {
    return FloatingActionButton(
      backgroundColor: Colors.grey.shade700,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
      ),
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
