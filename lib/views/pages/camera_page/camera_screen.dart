import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/scheduler.dart';

import 'add_video_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}
class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  late List<CameraDescription> cameras;
  CameraController? cameraController;
  bool isRecording = false;
  bool isPause = false;
  XFile? videoFile;
  int cameraDirection = 0;
  bool _isInitializing = true;
  String? _errorMessage;
  Duration _recordingDuration = Duration.zero;
  late Timer _recordingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App lifecycle state changed - optimize camera resource usage
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up resources when app is inactive
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize camera when app is resumed
      if (cameraController != null) {
        startCamera(cameraDirection);
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });
      
      // Get available cameras
      cameras = await availableCameras();
      
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = "No cameras found on device";
          _isInitializing = false;
        });
        return;
      }
      
      await startCamera(cameraDirection);
      
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to initialize camera: $e";
        _isInitializing = false;
      });
    }
  }

  Future<void> startCamera(int direction) async {
    if (cameraController != null) {
      await cameraController!.dispose();
    }

    // Make sure direction is valid
    if (direction >= cameras.length) {
      direction = 0;
    }

    cameraController = CameraController(
        cameras[direction], 
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg
    );

    try {
      await cameraController!.initialize();
      setState(() {
        _isInitializing = false;
        cameraDirection = direction;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to initialize camera: $e";
        _isInitializing = false;
      });
    }
  }

  void _startRecordingTimer() {
    _recordingDuration = Duration.zero;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration = Duration(seconds: _recordingDuration.inSeconds + 1);
      });
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer.cancel();
    _recordingDuration = Duration.zero;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    if (isRecording) {
      _stopRecordingTimer();
    }
    super.dispose();
  }

  pickVideo(ImageSource src, BuildContext context) async {
    try {
      final video = await ImagePicker().pickVideo(source: src);
      if (video != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddVideoScreen(
              videoFile: File(video.path),
              videoPath: video.path,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking video: $e'))
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Initializing camera...', 
                style: TextStyle(color: Colors.white, fontSize: 16))
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(_errorMessage!, 
                style: const TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initializeCamera,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (cameraController?.value.isInitialized ?? false) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // Camera preview
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(0),
                        child: CameraPreview(cameraController!),
                      ),
                    ),
                    
                    // Top controls bar
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            if (isRecording)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: isPause ? Colors.yellow : Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatDuration(_recordingDuration),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.flash_off, color: Colors.white),
                              onPressed: () {
                                // Flash functionality could be added here
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Gallery button
                    InkWell(
                      onTap: () {
                        pickVideo(ImageSource.gallery, context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.photo_library, color: Colors.white, size: 28)
                      )
                    ),
                    // Camera controls
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isRecording) InkWell(
                          onTap: () async {
                            if (!isRecording) return;
                            if (!isPause) {
                              setState(() {
                                isPause = !isPause;
                              });
                              await cameraController!.pauseVideoRecording();
                              _recordingTimer.cancel();
                            } else {
                              setState(() {
                                isPause = !isPause;
                              });
                              await cameraController!.resumeVideoRecording();
                              _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                                setState(() {
                                  _recordingDuration = Duration(seconds: _recordingDuration.inSeconds + 1);
                                });
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPause ? Icons.play_arrow : Icons.pause,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Record button
                        GestureDetector(
                          onTap: () async {
                            if (!isRecording) {
                              try {
                                await cameraController!.startVideoRecording();
                                setState(() {
                                  isRecording = true;
                                });
                                _startRecordingTimer();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to start recording: $e'))
                                );
                              }
                            } else {
                              try {
                                setState(() {
                                  isRecording = false;
                                  isPause = false;
                                });
                                _stopRecordingTimer();
                                XFile videoFile = await cameraController!.stopVideoRecording();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AddVideoScreen(
                                      videoFile: File(videoFile.path),
                                      videoPath: videoFile.path,
                                    ),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to stop recording: $e'))
                                );
                              }
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: isRecording ? 80 : 70,
                            width: isRecording ? 80 : 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: isRecording ? 30 : 60,
                                width: isRecording ? 30 : 60,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: isRecording ? BoxShape.rectangle : BoxShape.circle,
                                  borderRadius: isRecording ? BorderRadius.circular(4) : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Camera switch button
                        InkWell(
                          onTap: () async {
                            if (isRecording) return; // Prevent camera switching during recording
                            setState(() => _isInitializing = true);
                            cameraDirection = cameraDirection == 0 ? 1 : 0;
                            await startCamera(cameraDirection);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.flip_camera_ios_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Spacer for alignment
                    const SizedBox(width: 40),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}