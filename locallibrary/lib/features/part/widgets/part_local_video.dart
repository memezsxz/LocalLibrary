import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

class PartLocalVideo extends StatefulWidget {
  const PartLocalVideo({super.key, required this.absolutePath, this.fit});

  factory PartLocalVideo.relative({
    Key? key,
    required String storageRoot,
    required String storyWattId,
    required String relativePath,
    BoxFit? fit,
  }) => PartLocalVideo(
    key: key,
    absolutePath: path.join(storageRoot, storyWattId, relativePath),
    fit: fit,
  );

  final String absolutePath;
  final BoxFit? fit;

  @override
  State<PartLocalVideo> createState() => _PartLocalVideoState();
}

class _PartLocalVideoState extends State<PartLocalVideo> {
  late final VideoPlayerController _c;
  late final Future<void> _init;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.file(File(widget.absolutePath));
    _init = _c.initialize().then((_) => _c.setLooping(true));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return const Center(child: Icon(Icons.broken_image_outlined));
        }
        return GestureDetector(
          onTap: () => _c.value.isPlaying ? _c.pause() : _c.play(),
          child: AspectRatio(
            aspectRatio: _c.value.aspectRatio == 0
                ? 16 / 9
                : _c.value.aspectRatio,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                FittedBox(
                  fit: widget.fit ?? BoxFit.contain,
                  child: SizedBox(
                    width: _c.value.size.width,
                    height: _c.value.size.height,
                    child: VideoPlayer(_c),
                  ),
                ),
                VideoProgressIndicator(_c, allowScrubbing: true),
              ],
            ),
          ),
        );
      },
    );
  }
}
