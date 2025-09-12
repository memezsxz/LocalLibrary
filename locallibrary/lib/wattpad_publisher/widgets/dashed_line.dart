import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class DashImageLine extends StatefulWidget {
  const DashImageLine({
    super.key,
    required this.assetPath,      // e.g. 'assets/icons/dash.png'
    this.axis = Axis.horizontal,  // Axis.vertical for a "column" of dashes
    this.length = double.infinity,// total length in the main axis
    this.dashExtent = 16,         // dash width (horizontal) OR height (vertical)
    this.thickness = 4,           // cross-axis thickness
    this.gap = 8,                 // space between dashes
    this.color,                   // optional tint
  });

  final String assetPath;
  final Axis axis;
  final double length;
  final double dashExtent;
  final double thickness;
  final double gap;
  final Color? color;

  @override
  State<DashImageLine> createState() => _DashImageLineState();
}

class _DashImageLineState extends State<DashImageLine> {
  ui.Image? _img;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await rootBundle.load(widget.assetPath);
    final image = await decodeImageFromList(data.buffer.asUint8List());
    if (mounted) setState(() => _img = image);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.axis == Axis.horizontal
        ? Size(widget.length, widget.thickness)
        : Size(widget.thickness, widget.length);

    if (_img == null) return SizedBox.fromSize(size: size);

    return SizedBox.fromSize(
      size: size,
      child: CustomPaint(
        painter: _DashImagePainter(
          image: _img!,
          axis: widget.axis,
          dashExtent: widget.dashExtent,
          thickness: widget.thickness,
          gap: widget.gap,
          tint: widget.color,
        ),
      ),
    );
  }
}

class _DashImagePainter extends CustomPainter {
  _DashImagePainter({
    required this.image,
    required this.axis,
    required this.dashExtent,
    required this.thickness,
    required this.gap,
    this.tint,
  });

  final ui.Image image;
  final Axis axis;
  final double dashExtent;
  final double thickness;
  final double gap;
  final Color? tint;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.medium;
    if (tint != null) {
      paint.colorFilter = ColorFilter.mode(tint!, BlendMode.srcATop);
    }

    final src = Rect.fromLTWH(
      0, 0, image.width.toDouble(), image.height.toDouble(),
    );

    if (axis == Axis.horizontal) {
      double x = 0;
      while (x < size.width) {
        final remaining = size.width - x;
        final w = remaining < dashExtent ? remaining : dashExtent;
        if (w <= 0) break;
        final dst = Rect.fromLTWH(x, 0, w, thickness);
        canvas.drawImageRect(image, src, dst, paint);
        x += w + gap;
      }
    } else {
      double y = 0;
      while (y < size.height) {
        final remaining = size.height - y;
        final h = remaining < dashExtent ? remaining : dashExtent;
        if (h <= 0) break;
        final dst = Rect.fromLTWH(0, y, thickness, h);
        canvas.drawImageRect(image, src, dst, paint);
        y += h + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashImagePainter old) {
    return old.image != image ||
        old.axis != axis ||
        old.dashExtent != dashExtent ||
        old.thickness != thickness ||
        old.gap != gap ||
        old.tint != tint;
  }
}
