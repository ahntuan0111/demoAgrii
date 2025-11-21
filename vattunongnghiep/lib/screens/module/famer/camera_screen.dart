import 'package:agri_flutter/services/chatbox_ai_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:convert';


class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late Future<void> _initializeControllerFuture;
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  bool _isSendingImage = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _controller = CameraController(
          _cameras[0], // Use the first camera (usually back camera)
          ResolutionPreset.medium,
        );

        _initializeControllerFuture = _controller.initialize();
        await _initializeControllerFuture;
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể khởi động camera'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    if (_isCameraInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _sendImageToAI(XFile image) async {
    setState(() {
      _isSendingImage = true;
    });

    try {
      // Read image file as bytes
      final bytes = await image.readAsBytes();

      // Convert to base64
      final base64Image = base64Encode(bytes);

      // Send to backend using ApiService
      final response = await ApiService.analyzePlantImage(base64Image);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Phát hiện bệnh: ${response['disease']} (Độ tin cậy: ${(response['confidence'] * 100).toStringAsFixed(1)}%)',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Send the analysis result as a chat message
        Navigator.pop(context, {
          'type': 'image_analysis',
          'data': response,
          'message':
              'Hình ảnh cho thấy cây ${response['crop']} có thể bị ${response['disease']} với độ tin cậy ${(response['confidence'] * 100).toStringAsFixed(1)}%. ${response['aiResponse']}',
        });
      }
    } catch (e) {
      print('Error sending image to AI: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi khi gửi hình ảnh đến AI'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSendingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chụp ảnh'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isCameraInitialized
          ? FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      CameraPreview(_controller),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _isSendingImage
                              ? const CircularProgressIndicator()
                              : FloatingActionButton(
                                  heroTag: "camera_capture_button",
                                  onPressed: () async {
                                    try {
                                      final image = await _controller
                                          .takePicture();

                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Đang phân tích hình ảnh...',
                                            ),
                                            backgroundColor: Colors.blue,
                                          ),
                                        );

                                        await _sendImageToAI(image);
                                      }
                                    } catch (e) {
                                      print('Error taking picture: $e');
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Không thể chụp ảnh'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Icon(Icons.camera),
                                ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
