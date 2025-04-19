import 'dart:io';

import 'package:audio_player/widgets/build_body.dart';
import 'package:audio_player/widgets/recording_button.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int recordingCount = 0;
  List<String> recordings = [];
  AudioRecorder audioRecorder = AudioRecorder();
  AudioPlayer audioPlayer = AudioPlayer();
  RecorderController recorderController = RecorderController();
  String? recordingPath;
  bool isRecording = false;
  String? currentlyPlaying;
  TextEditingController searchController = TextEditingController();
  List<String> filteredRecordings = [];

  Future<void> saveRecordings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recordings', recordings);
    await prefs.setInt('recordingCount', recordingCount);
  }

  Future<void> loadRecordings() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedRecordings = prefs.getStringList('recordings') ?? [];
    final loadedCount = prefs.getInt('recordingCount') ?? 0;

    setState(() {
      recordings = loadedRecordings;
      recordingCount = loadedCount;
      filteredRecordings = loadedRecordings;
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

  void searchRecordings(String query) {
    List<String> searchResult = [];

    if (query.isEmpty) {
      setState(() {
        searchResult = recordings;
      });
    } else {
      searchResult = recordings.where((record) {
        final name = p.basename(record).toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
      setState(() {
        filteredRecordings = searchResult;
      });
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
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Row(
          children: [
            Text(
              'Recorder',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: BuildBody(
          isRecording: isRecording,
          searchController: searchController,
          recordings: filteredRecordings,
          currentlyPlaying: currentlyPlaying,
          deleteRecording: deleteRecording,
          audioPlayer: audioPlayer,
          // recordingPath: recordingPath,
          searchFunction: searchRecordings,
          recorderController: recorderController,
          onCurrentlyPlayingChanged: (value) {
            setState(() {
              currentlyPlaying = value;
            });
          }),
      floatingActionButton: RecordingButton(
          isRecording: isRecording,
          recordingPath: recordingPath,
          audioRecorder: audioRecorder,
          saveRecordings: saveRecordings,
          recordingCount: recordingCount,
          onRecordingStateChanged: (val) {
            setState(() {
              isRecording = val;
            });
          },
          onRecordingPathChanged: (val) {
            setState(() {
              recordingPath = val;
            });
          },
          onAddRecording: (path) {
            setState(() {
              recordings.add(path);
            });
          },
          onRecordingCountChanged: (val) {
            setState(() {
              recordingCount = val;
            });
          }),
    );
  }
}
