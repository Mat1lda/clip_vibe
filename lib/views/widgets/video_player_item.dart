import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerItem({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController videoPlayerController;
  bool _isPlaying = true;
  bool _isInitialized = false;
  bool _isBuffering = false;
  bool _showControls = false;
  bool _isError = false;
  
  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }
  
  void _initializeVideoPlayer() async {
    try {
      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      
      // Listen for initialization completion
      await videoPlayerController.initialize();
      
      // Listen for playback state changes
      videoPlayerController.addListener(_videoListener);
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isPlaying = true;
        });
        
        videoPlayerController.play();
        videoPlayerController.setLooping(true);
      }
    } catch (e) {
      print("Error initializing video: $e");
      if (mounted) {
        setState(() {
          _isError = true;
        });
      }
    }
  }
  
  void _videoListener() {
    if (!mounted) return;
    
    // Handle buffering state
    final bool isBuffering = videoPlayerController.value.isBuffering;
    if (isBuffering != _isBuffering) {
      setState(() {
        _isBuffering = isBuffering;
      });
    }
    
    // Auto-hide controls after a delay
    if (_showControls) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _showControls && _isPlaying) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void videoCtrl() {
    setState(() {
      _showControls = true;
      
      if (_isPlaying) {
        _isPlaying = false;
        videoPlayerController.pause();
      } else {
        _isPlaying = true;
        videoPlayerController.play();
      }
    });
  }

  @override
  void dispose() {
    videoPlayerController.removeListener(_videoListener);
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 42),
              SizedBox(height: 12),
              Text(
                "Failed to load video",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }
    
    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: videoCtrl,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video player
            VideoPlayer(videoPlayerController),
            
            // Buffering indicator
            if (_isBuffering)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            
            // Play/pause controls
            if (_showControls || !_isPlaying)
              AnimatedOpacity(
                opacity: _showControls || !_isPlaying ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    iconSize: 50,
                    color: Colors.white,
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: videoCtrl,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}