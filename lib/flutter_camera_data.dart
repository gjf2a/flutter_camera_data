library flutter_camera_data;

import 'dart:typed_data';
import 'dart:ui' as dartui;

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';

class CameraImagePainter extends CustomPainter {
  late dartui.Image _lastImage;
  bool _initialized = false;
  int _width = 0, _height = 0;
  DateTime _start = DateTime.now();
  double _fps = 0.0;
  int _frameCount = 0;

  Future<void> setImage(CameraImage img) async {
    if (!_initialized) {
      _start = DateTime.now();
      _initialized = true;
    }
    _lastImage = await makeImageFrom(rgbaBytesFrom(img), img.width, img.height);
    _width = _lastImage.width;
    _height = _lastImage.height;
    _frameCount += 1;
    Duration elapsed = DateTime.now().difference(_start);
    _fps = _frameCount / elapsed.inSeconds;
  }

  double fps() {return _fps;}
  int frameCount() {return _frameCount;}
  int width() {return _width;}
  int height() {return _height;}

  @override
  void paint(Canvas canvas, Size size) {
    if (_initialized) {
      canvas.drawImage(_lastImage, Offset(-_width/2, -_height/2), Paint());
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => _initialized;
}

// Adapted from: https://stackoverflow.com/a/57604820/906268
Uint8List rgbaBytesFrom(CameraImage img) {
  final int uvRowStride = img.planes[1].bytesPerRow;
  final int uvPixelStride = img.planes[1].bytesPerPixel!;
  Uint8List proc = Uint8List(img.width * img.height * 4);
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      final int uvIndex = uvPixelStride * (x~/2) + uvRowStride * (y~/2);
      final int yIndex = y * img.width + x;
      final int procIndex = yIndex * 4;
      final int yp = img.planes[0].bytes[yIndex];
      final int up = img.planes[1].bytes[uvIndex];
      final int vp = img.planes[2].bytes[uvIndex];
      proc[procIndex] = (yp + vp * 1436 ~/ 1024 - 179).clamp(0, 255);
      proc[procIndex + 1] = (yp - up * 46549 ~/ 131072 + 44 - vp * 93604 ~/ 131072 + 91).clamp(0, 255);
      proc[procIndex + 2] = (yp + up * 1814 ~/ 1024 - 227).clamp(0, 255);
      proc[procIndex + 3] = 255;
    }
  }
  return proc;
}

// This is super-clunky. I wonder if there's a better way...
Future<dartui.Image> makeImageFrom(Uint8List intensities, int width, int height) async {
  dartui.ImmutableBuffer rgba = await dartui.ImmutableBuffer.fromUint8List(intensities);
  dartui.Codec c = await dartui.ImageDescriptor.raw(rgba, width: width, height: height, pixelFormat: dartui.PixelFormat.rgba8888).instantiateCodec(targetWidth: width, targetHeight: height);
  dartui.FrameInfo frame = await c.getNextFrame();
  dartui.Image result = frame.image.clone();
  frame.image.dispose();
  return result;
}