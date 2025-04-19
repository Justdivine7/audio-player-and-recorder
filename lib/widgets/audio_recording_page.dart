import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AudioRecordingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AudioRecordingPage extends StatefulWidget {
  const AudioRecordingPage({super.key});

  @override
  State<AudioRecordingPage> createState() => _AudioRecordingPageState();
}

class _AudioRecordingPageState extends State<AudioRecordingPage> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final RecorderController _recorderController = RecorderController();

  bool isRecording = false;
  String? recordingPath;
  int recordingCount = 0;
  List<String> recordings = [];

  @override
  void dispose() {
    _recorderController.dispose();
    super.dispose();
  }

  Future<void> _saveRecordings() async {
    // You can store recordings to shared_preferences, Hive, etc.
    debugPrint('Saved recordings: $recordings');
  }

  Future<void> _toggleRecording() async {
    if (isRecording) {
      // Stop recording
      final path = await _audioRecorder.stop();
      setState(() {
        isRecording = false;
        recordingPath = path;
      });
      if (path != null) {
        setState(() => recordings.add(path));
      }
      await _saveRecordings();
    } else {
      // Start recording
      if (await _audioRecorder.hasPermission()) {
        final downloadsDir = await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
        final newCount = recordingCount + 1;
        setState(() => recordingCount = newCount);

        final filePath = p.join(downloadsDir.path, 'recording$newCount.mp3');
        await _audioRecorder.start(const RecordConfig(), path: filePath);

        // Start wave visualizer
        await _recorderController.record(path: filePath);

        setState(() {
          isRecording = true;
          recordingPath = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Studio Audio Recorder'),
        backgroundColor: Colors.grey.shade800,
      ),
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Press the mic to record...',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 30),
          AudioWaveforms(
            enableGesture: false,
            size: Size(MediaQuery.of(context).size.width, 100.0),
            recorderController: _recorderController,
            waveStyle: const WaveStyle(
              waveColor: Colors.greenAccent,
              showMiddleLine: true,
              extendWaveform: true,
              spacing: 6,
              waveThickness: 3.0,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey.shade700,
        foregroundColor: Colors.white,
        onPressed: _toggleRecording,
        child: Icon(isRecording ? Icons.stop : Icons.mic),
      ),
    );
  }
}
