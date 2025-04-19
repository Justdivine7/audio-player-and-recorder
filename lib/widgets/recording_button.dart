import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
      backgroundColor: Colors.grey.shade700,
      foregroundColor: Colors.white,
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
            final int newCount = recordingCount + 1;
            onRecordingCountChanged(newCount);
            final String uniqueFileName = 'recording$newCount.mp3';
            final String audioPath = p.join(downloadsDir.path, uniqueFileName);
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
}
