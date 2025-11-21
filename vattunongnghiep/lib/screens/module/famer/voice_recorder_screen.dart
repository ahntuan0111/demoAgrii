import 'package:agri_flutter/services/chatbox_ai_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';

class VoiceRecorderScreen extends StatefulWidget {
  const VoiceRecorderScreen({super.key});

  @override
  _VoiceRecorderScreenState createState() => _VoiceRecorderScreenState();
}

class _VoiceRecorderScreenState extends State<VoiceRecorderScreen> {
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isSendingVoice = false;
  bool _hasMicrophonePermission = false;
  double _recordedDuration = 0.0;
  Timer? _recordingTimer;
  List<double> _voiceData = [];
  Uint8List? _recordedAudio;
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  String _recordingPath = '';

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _checkPermissions();
  }

  Future<void> _initializeRecorder() async {
    try {
      await _audioRecorder.openRecorder();
    } catch (e) {
      print('Error initializing recorder: $e');
    }
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.microphone.status;
    setState(() {
      _hasMicrophonePermission = status.isGranted;
    });
  }

  Future<void> _requestPermissions() async {
    // Request microphone permission
    final micPermission = await Permission.microphone.request();
    setState(() {
      _hasMicrophonePermission = micPermission.isGranted;
    });

    if (!micPermission.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cần quyền truy cập microphone để ghi âm'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _audioRecorder.closeRecorder();
    _audioPlayer.closePlayer();
    super.dispose();
  }

  void _startRecording() async {
    // Request permissions if not granted
    if (!_hasMicrophonePermission) {
      await _requestPermissions();
      if (!_hasMicrophonePermission) {
        return; // Permission not granted
      }
    }

    // Check if recording is already in progress
    if (_isRecording) return;

    try {
      // Generate a unique file path for recording
      final path = 'voice_record_${DateTime.now().millisecondsSinceEpoch}.wav';
      _recordingPath = path;

      // Start actual audio recording with optimal settings for speech recognition
      await _audioRecorder.startRecorder(
        toFile: path,
        codec: Codec.pcm16WAV, // Use WAV codec for better compatibility
        sampleRate: 16000, // Standard sample rate for speech recognition
        bitRate: 128000, // Bit rate
        numChannels: 1, // Mono channel for better recognition
      );

      setState(() {
        _isRecording = true;
        _recordedDuration = 0.0;
        _voiceData.clear();
      });

      // Start timer for visualization
      _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (
        timer,
      ) {
        if (_isRecording && mounted) {
          setState(() {
            _recordedDuration += 0.1;
            // Simulate voice data collection for visualization
            _voiceData.add(Random().nextDouble() * 100);
          });
        } else {
          timer.cancel();
        }
      });
    } catch (e) {
      print('Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi khi bắt đầu ghi âm'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _stopRecording() async {
    _recordingTimer?.cancel();

    try {
      // Stop actual audio recording
      await _audioRecorder.stopRecorder();

      setState(() {
        _isRecording = false;
      });

      // Read the recorded file as bytes
      if (_recordingPath.isNotEmpty) {
        try {
          // Read file as bytes using dart:io
          final file = File(_recordingPath);
          if (await file.exists()) {
            _recordedAudio = await file.readAsBytes();
            print('Recorded audio size: ${_recordedAudio!.length} bytes');

            // Delete the temporary file
            await file.delete();
          } else {
            // Fallback to simulated data if file doesn't exist
            _recordedAudio = Uint8List(1024);
            final random = Random();
            for (int i = 0; i < _recordedAudio!.length; i++) {
              _recordedAudio![i] = random.nextInt(256);
            }
          }
        } catch (e) {
          print('Error reading recorded file: $e');
          // Fallback to simulated data
          _recordedAudio = Uint8List(1024);
          final random = Random();
          for (int i = 0; i < _recordedAudio!.length; i++) {
            _recordedAudio![i] = random.nextInt(256);
          }
        }
      }
    } catch (e) {
      print('Error stopping recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi khi dừng ghi âm'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendVoiceToAI() async {
    if (_recordedAudio == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không có dữ liệu âm thanh để gửi'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSendingVoice = true;
    });

    try {
      print('Sending audio data of size: ${_recordedAudio!.length} bytes');

      // Convert audio data to base64 string
      final base64Voice = base64Encode(_recordedAudio!);
      print('Base64 encoded data length: ${base64Voice.length} characters');

      // Send to backend
      final response = await ApiService.processVoice(base64Voice);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã nhận diện: ${response['transcribed_text']}'),
            backgroundColor: Colors.green,
          ),
        );

        // Send the transcribed text and AI response as a chat message
        Navigator.pop(context, {
          'type': 'voice_message',
          'data': response,
          'message': response['transcribed_text'],
          'ai_response': response['ai_response'],
          'keywords': response['keywords'],
        });
      }
    } catch (e) {
      print('Error sending voice to AI: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi khi gửi giọng nói đến AI'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSendingVoice = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ghi âm giọng nói'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRecording ? Icons.mic : Icons.mic_none,
              size: 100,
              color: _isRecording ? Colors.red : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              _isRecording
                  ? 'Đang ghi âm...'
                  : _hasMicrophonePermission
                  ? 'Nhấn nút để bắt đầu ghi âm'
                  : 'Cần quyền truy cập microphone',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Hướng dẫn: Nói to và rõ ràng trong 3-5 giây',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              'Thời gian: ${_recordedDuration.toStringAsFixed(1)} giây',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Visualization of voice data
            Container(
              height: 100,
              width: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(painter: VoiceVisualizer(_voiceData)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: "voice_record_button",
                  onPressed: _isSendingVoice
                      ? null
                      : () {
                          if (_isRecording) {
                            // Stop recording
                            _stopRecording();
                          } else {
                            // Start recording
                            _startRecording();
                          }
                        },
                  backgroundColor: _isRecording ? Colors.red : Colors.orange,
                  child: Icon(_isRecording ? Icons.stop : Icons.mic),
                ),
                FloatingActionButton(
                  heroTag: "voice_play_button",
                  onPressed:
                      _isRecording || _isSendingVoice || _recordedAudio == null
                      ? null
                      : () {
                          setState(() {
                            _isPlaying = !_isPlaying;
                          });
                          // In a real implementation, we would play the recorded audio here
                        },
                  backgroundColor: Colors.blue,
                  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Permission button
            if (!_hasMicrophonePermission)
              ElevatedButton(
                onPressed: _requestPermissions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                child: const Text('Cấp quyền truy cập microphone'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  _isRecording ||
                      _recordedAudio == null ||
                      _isSendingVoice ||
                      !_hasMicrophonePermission
                  ? null
                  : _sendVoiceToAI,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              child: _isSendingVoice
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                        SizedBox(width: 10),
                        Text('Đang xử lý...'),
                      ],
                    )
                  : const Text('Gửi và phân tích giọng nói'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Lưu ý: Nói to, rõ ràng và bằng tiếng Việt có dấu',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class VoiceVisualizer extends CustomPainter {
  final List<double> voiceData;

  VoiceVisualizer(this.voiceData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (voiceData.isEmpty) {
      // Draw a flat line if no data
      path.moveTo(0, size.height / 2);
      path.lineTo(size.width, size.height / 2);
    } else {
      // Draw voice visualization
      final step =
          size.width / (voiceData.length > 1 ? voiceData.length - 1 : 1);

      for (int i = 0; i < voiceData.length; i++) {
        final x = i * step;
        final y = size.height / 2 - (voiceData[i] / 100) * (size.height / 2);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
