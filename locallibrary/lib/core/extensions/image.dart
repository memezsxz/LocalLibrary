import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class LocalImage extends Image {
  LocalImage({
    super.key,
    required String absolutePath,
    super.width,
    super.height,
    super.fit,
  }) : super(
    image: FileImage(File(absolutePath)),
    // shows loader while decoding
    loadingBuilder: (context, child, progress) {
      if (progress == null) return child;
      return const Center(child: CircularProgressIndicator());
    },
    // nice fade-in
    frameBuilder: (context, child, frame, wasSync) {
      if (wasSync) return child;
      return AnimatedOpacity(
        opacity: frame == null ? 0 : 1,
        duration: const Duration(milliseconds: 220),
        child: child,
      );
    },
    // fallback UI on error
    errorBuilder: (context, err, stack) =>
    const Center(child: Icon(Icons.broken_image_outlined)),
  );

  /// Convenience when you have per-story relative paths.
  LocalImage.relative({
    Key? key,
    required String storageRoot,
    required String storyWattId,
    required String relativePath,
    double? width,
    double? height,
    BoxFit? fit,
  }) : this(
    key: key,
    absolutePath: path.join(storageRoot, storyWattId, relativePath),
    width: width,
    height: height,
    fit: fit,
  );

  static String getAbsolutePath(String storageRoot, String storyWattId, String relativePath) =>
      path.join(storageRoot, storyWattId, relativePath);
}
