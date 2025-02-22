import 'package:flutter/material.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class RecorderScreen extends StatefulWidget {
  @override
  _RecorderScreenState createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  final Record _audioRecorder = Record();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isRecording = false;
  bool isPaused = false;
  String? filePath;
  List<String> recordings = [];

  @override
  void initState() {
    super.initState();
    _loadRecordings();
  }

  Future<void> _loadRecordings() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = dir.listSync();
      setState(() {
        recordings = files.map((e) => e.path).where((path) => path.endsWith('.m4a')).toList();
      });
    } catch (e) {
      print("Error loading recordings: $e");
    }
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();
      filePath = '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(path: filePath!);
      setState(() {
        isRecording = true;
        isPaused = false;
      });
    }
  }

  Future<void> _pauseRecording() async {
    await _audioRecorder.pause();
    setState(() {
      isPaused = true;
    });
  }

  Future<void> _resumeRecording() async {
    await _audioRecorder.resume();
    setState(() {
      isPaused = false;
    });
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    if (path != null) {
      setState(() {
        isRecording = false;
        isPaused = false;
        recordings.add(path);
      });
      _loadRecordings(); // Reload list
    }
  }

  Future<void> _playRecording(String path) async {
    await _audioPlayer.play(DeviceFileSource(path));
  }

  Future<void> _deleteRecording(String path) async {
    File file = File(path);
    if (await file.exists()) {
      await file.delete();
      setState(() {
        recordings.remove(path);
      });
    }
  }

  Widget _buildRecordingIndicator() {
    return isRecording
        ? Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(Icons.fiber_manual_record, color: Colors.red, size: 30),
          Text("Recording...", style: TextStyle(color: Colors.red, fontSize: 16))
        ],
      ),
    )
        : SizedBox();
  }

  Widget _buildRecordingList() {
    return recordings.isEmpty
        ? Center(child: Text("No recordings yet", style: TextStyle(color: Colors.white)))
        : ListView.builder(
      shrinkWrap: true,
      itemCount: recordings.length,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.black54,
          child: ListTile(
            title: Text("Recording ${index + 1}", style: TextStyle(color: Colors.white)),
            subtitle: Text(recordings[index], style: TextStyle(color: Colors.grey)),
            leading: Icon(Icons.music_note, color: Colors.blue),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.play_arrow, color: Colors.green),
                  onPressed: () => _playRecording(recordings[index]),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteRecording(recordings[index]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Voice Recorder")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildRecordingIndicator(),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: isRecording ? _pauseRecording : _startRecording,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: Text(isRecording ? "Pause" : "Start"),
              ),
              SizedBox(width: 10),
              if (isPaused)
                ElevatedButton(
                  onPressed: _resumeRecording,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: Text("Resume"),
                ),
              SizedBox(width: 10),
              if (isRecording)
                ElevatedButton(
                  onPressed: _stopRecording,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: Text("Stop"),
                ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(child: _buildRecordingList()),
        ],
      ),
    );
  }
}
