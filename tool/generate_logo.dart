// Generates assets/icon/logo.png: black "SRPSKI" on white, 1024x1024.
// Uses block letters (no font load). Run from project root: dart run tool/generate_logo.dart

import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  const size = 1024;
  final image = img.Image(width: size, height: size, numChannels: 4);
  img.fill(image, color: img.ColorRgba8(255, 255, 255, 255));

  // Block-letter "SRPSKI" – each letter is a grid; we draw filled rects.
  // Layout: 6 letters, each ~140w, total ~840; vertical center ~400–624.
  const bar = 28; // stroke width
  const gap = 24;
  const letterWidth = 120;
  const letterHeight = 200;
  final startX = (size - (6 * (letterWidth + gap) - gap)) ~/ 2;
  final startY = (size - letterHeight) ~/ 2;
  final black = img.ColorRgba8(0, 0, 0, 255);

  void rect(int x1, int y1, int x2, int y2) {
    img.fillRect(
      image,
      x1: x1,
      y1: y1,
      x2: x2,
      y2: y2,
      color: black,
    );
  }

  int x = startX;
  final y = startY;
  final w = letterWidth;
  final h = letterHeight;
  final t = bar;

  // S: top bar, middle bar, bottom bar, left top vertical, right bottom vertical
  rect(x, y, x + w, y + t);
  rect(x, y + (h ~/ 2) - (t ~/ 2), x + w, y + (h ~/ 2) + (t ~/ 2));
  rect(x, y + h - t, x + w, y + h);
  rect(x, y + t, x + t, y + (h ~/ 2) - (t ~/ 2));
  rect(x + w - t, y + (h ~/ 2) + (t ~/ 2), x + w, y + h - t);
  x += w + gap;

  // R: left vertical, top bar, right top, right middle, diagonal
  rect(x, y, x + t, y + h);
  rect(x, y, x + w, y + t);
  rect(x + w - t, y, x + w, y + (h ~/ 2));
  rect(x + w - t, y + (h ~/ 2) + (t ~/ 2), x + w, y + h);
  rect(x + (w ~/ 2), y + (h ~/ 2), x + w - t, y + (h ~/ 2) + t);
  x += w + gap;

  // P: left vertical, top bar, right top
  rect(x, y, x + t, y + h);
  rect(x, y, x + w, y + t);
  rect(x + w - t, y, x + w, y + (h ~/ 2));
  rect(x + (w ~/ 2), y + (h ~/ 2) - (t ~/ 2), x + w - t, y + (h ~/ 2) + (t ~/ 2));
  x += w + gap;

  // S: same as first S
  rect(x, y, x + w, y + t);
  rect(x, y + (h ~/ 2) - (t ~/ 2), x + w, y + (h ~/ 2) + (t ~/ 2));
  rect(x, y + h - t, x + w, y + h);
  rect(x, y + t, x + t, y + (h ~/ 2) - (t ~/ 2));
  rect(x + w - t, y + (h ~/ 2) + (t ~/ 2), x + w, y + h - t);
  x += w + gap;

  // K: left vertical, top diagonal, bottom diagonal
  rect(x, y, x + t, y + h);
  rect(x + w - t, y, x + w, y + (h ~/ 2) - (t ~/ 2));
  rect(x + w - t, y + (h ~/ 2) + (t ~/ 2), x + w, y + h);
  rect(x + (w ~/ 2) - (t ~/ 2), y + (h ~/ 2) - (t ~/ 2), x + w, y + (h ~/ 2) + (t ~/ 2));
  x += w + gap;

  // I: top bar, bottom bar, middle vertical
  rect(x, y, x + w, y + t);
  rect(x, y + h - t, x + w, y + h);
  rect(x + (w ~/ 2) - (t ~/ 2), y + t, x + (w ~/ 2) + (t ~/ 2), y + h - t);

  final outDir = Directory('assets/icon');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);
  final file = File('assets/icon/logo.png');
  file.writeAsBytesSync(img.encodePng(image));
  print('Generated ${file.path}');
}
