import 'dart:math' as math;
import 'dart:ui';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';

import '../commen/display_provider.dart';

extension WindowControllerFocusExt on WindowController {
  /// Brings the window to front & gives it attention.
  /// Works by showing the window and pulsing `alwaysOnTop`.
  Future<void> focus() async {
    try {
      await show(); // ensure visible
    } catch (_) {}

    // Pulse alwaysOnTop to steal focus without leaving it pinned
    try {
      await show();
      await Future.delayed(const Duration(milliseconds: 60));
    } catch (_) {
      print("did not focus");
      // Some platforms may not support alwaysOnTop; ignore safely.
    }
  }
}

// ---------- 2) WindowController extension (generic) ----------

extension WindowPlacementX on WindowController {
  /// Center a fixed-size frame on the display under the cursor.
  Future<void> setFixedCenteredOnCursor({
    required DisplayProvider displays,
    double width = 520,
    double height = 420,
  }) async {
    final d = await _pickDisplayUnderCursor(displays);
    final wa = _workArea(d);
    final left = wa.left + (wa.width - width) / 2;
    final top = wa.top + (wa.height - height) / 2;
    await setFrame(Rect.fromLTWH(left, top, width, height));
  }

  /// Size to a percentage of work area and center.
  Future<void> setRelativeCentered({
    required DisplayProvider displays,
    bool useCursorDisplay = true,
    double widthPercent = 0.8,
    double heightPercent = 0.8,
    double minWidth = 900,
    double minHeight = 600,
    double maxWidth = 2000,
    double maxHeight = 1400,
  }) async {
    final display = useCursorDisplay
        ? await _pickDisplayUnderCursor(displays)
        : await displays.getPrimaryDisplay();

    final wa = _workArea(display);

    final targetW = wa.width * widthPercent;
    final targetH = wa.height * heightPercent;

    final w = targetW.clamp(minWidth, maxWidth);
    final h = targetH.clamp(minHeight, maxHeight);

    final left = wa.left + (wa.width - w) / 2;
    final top = wa.top + (wa.height - h) / 2;

    await setFrame(Rect.fromLTWH(left, top, w, h));
  }

  // ---------- helpers ----------

  Future<Object> _pickDisplayUnderCursor(DisplayProvider displays) async {
    final pt = await displays.getCursorPoint();
    final all = await displays.getAllDisplays();
    if (all.isEmpty) return await displays.getPrimaryDisplay();

    final hit = _displayForPoint(all, pt);
    if (hit != null) return hit;

    // nearest by center distance
    Object best = all.first;
    double bestDist = double.infinity;
    for (final d in all) {
      final r = _workArea(d);
      final c = Offset(r.left + r.width / 2, r.top + r.height / 2);
      final dx = c.dx - pt.dx, dy = c.dy - pt.dy;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist < bestDist) {
        bestDist = dist;
        best = d;
      }
    }
    return best;
  }

  Object? _displayForPoint(List<Object> displays, Offset pt) {
    for (final d in displays) {
      if (_workArea(d).contains(pt)) return d;
    }
    return null;
  }

  _Rect _workArea(Object display) {
    final dyn = display as dynamic;

    // Try visible/work area first; fall back to full bounds; tolerate missing fields.
    final Size? visSize = (dyn?.visibleSize is Size)
        ? dyn.visibleSize as Size
        : null;
    final Offset? visPos = (dyn?.visiblePosition is Offset)
        ? dyn.visiblePosition as Offset
        : null;

    final Size size = visSize ?? (dyn?.size as Size);
    final Offset pos =
        visPos ?? (dyn?.visiblePosition ?? dyn?.position as Offset);

    final double scale = (dyn?.scaleFactor is num)
        ? (dyn.scaleFactor as num).toDouble()
        : 1.0;

    final left = pos.dx / scale;
    final top = pos.dy / scale;
    final w = size.width / scale;
    final h = size.height / scale;

    return _Rect(left, top, w, h);
  }
}

class _Rect {
  final double left, top, width, height;

  const _Rect(this.left, this.top, this.width, this.height);

  double get right => left + width;

  double get bottom => top + height;

  bool contains(Offset p) =>
      p.dx >= left && p.dx <= right && p.dy >= top && p.dy <= bottom;
}
