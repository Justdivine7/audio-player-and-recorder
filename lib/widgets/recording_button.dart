import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecordingButton extends StatelessWidget {
  final bool isRecording;
  final String? recordingPath;

  final AudioRecorder audioRecorder;
  final Future<void> Function() saveRecordings;
  final int recordingCount;
  final void Function(bool) onRecordingStateChanged;
  final void Function(String?) onRecordingPathChanged;
  final void Function(String) onAddRecording;
  final void Function(int) onRecordingCountChanged;

  const RecordingButton({
    super.key,
    required this.isRecording,
    required this.recordingPath,
    required this.audioRecorder,
    required this.saveRecordings,
    required this.recordingCount,
    required this.onRecordingStateChanged,
    required this.onRecordingPathChanged,
    required this.onAddRecording,
    required this.onRecordingCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 0,
      backgroundColor: Theme.of(context).indicatorColor,
      foregroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
      ),
      onPressed: () async {
        if (isRecording) {
          String? filePath = await audioRecorder.stop();
          onRecordingStateChanged(false);
          onRecordingPathChanged(filePath);
          if (filePath != null) {
            onAddRecording(filePath);
          }
          await saveRecordings();
        } else {
          if (await audioRecorder.hasPermission()) {
            Directory? downloadsDir = await getDownloadsDirectory();
            downloadsDir ?? await getApplicationDocumentsDirectory();
            if (downloadsDir == null) {
              throw Exception('No downloads directory');
            }
            final String audioPath =
                await getNextAvailableRecordingPath(downloadsDir);
            await audioRecorder.start(const RecordConfig(), path: audioPath);
            onRecordingStateChanged(true);
            onRecordingPathChanged(null);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Microphone permission denied'),
              ),
            );
          }
        }
      },
      child: isRecording ? const Icon(Icons.stop) : const Icon(Icons.mic),
    );
  }

  Future<String> getNextAvailableRecordingPath(Directory dir) async {
    int index = 1;
    String path;
    do {
      path = p.join(dir.path, 'recording$index.mp3');
      index++;
    } while (await File(path).exists());

    return path;
  }
}
