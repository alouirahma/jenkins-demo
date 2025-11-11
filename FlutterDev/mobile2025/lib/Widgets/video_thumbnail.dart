// lib/Widgets/video_thumbnail.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoThumbnail extends StatefulWidget {
  final String? videoUrl;
  final String? fallbackImage;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const VideoThumbnail({
    super.key,  // super parameter
    this.videoUrl,
    this.fallbackImage,
    this.width = 60,
    this.height = 60,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  VideoPlayerController? _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
      await _controller!.initialize();
      if (!mounted) return;
      _controller!.setLooping(true);
      _controller!.setVolume(0);
      _controller!.play();
      setState(() {});
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void didUpdateWidget(covariant VideoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.dispose();
      _controller = null;
      _hasError = false;
      if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
        _initializeVideo();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoUrl == null || _controller == null || !_controller!.value.isInitialized || _hasError) {
      return _buildFallback();
    }

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: VideoPlayer(_controller!),
      ),
    );
  }

  Widget _buildFallback() {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Container(
        width: widget.width,
        height: widget.height,
        color: Colors.blue[100],
        child: widget.fallbackImage != null
            ? Image.network(
                widget.fallbackImage!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.event, color: Colors.blue),
              )
            : const Icon(Icons.event, color: Colors.blue),
      ),
    );
  }
}