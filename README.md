<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

This library contains code to convert YUV images from the [camera](https://pub.dev/packages/camera) 
package into RGB format. It also contains a widget to display the converted images.

## Features

The `CameraImagePainter` widget displays a live camera image in a Flutter UI.

The `rbgaBytesFrom()` function converts a `CameraImage` object into a `Uint8List` object containing
four bytes for each image pixel. The bytes are in the sequence Red, Green, Blue, Alpha.

The `makeImageFrom()` function converts a `Uint8List` representing an RGBA image into a 
[`dartui.Image`](https://api.flutter.dev/flutter/dart-ui/Image-class.html) object. 

## Getting started

Add the following to `pubspec.yaml` under `dependencies:`:
```yaml
  flutter_camera_data:
    git: https://github.com/gjf2a/flutter_camera_data
```

## Usage

Here is an [example](https://github.com/gjf2a/flutter_camera_data_demo) of using it in a 
practical interface.

```dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_camera_data/flutter_camera_data.dart';
import 'dart:math' as math;

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraController controller;
  late CameraImagePainter _livePicture;

  @override
  void initState() {
    super.initState();
    _livePicture = CameraImagePainter();
    controller = CameraController(_cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream((image) {
        setState(() {
          _livePicture.setImage(image).whenComplete(() {});
        });
      });
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
                title: const Text("This is a title")),
            body: Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Transform.rotate(angle: math.pi/2, child: CustomPaint(painter: _livePicture)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Grabbed: ${_livePicture.frameCount()} (${_livePicture.width()} x ${_livePicture.height()}) FPS: ${_livePicture.fps().toStringAsFixed(2)}"),
                        ],
                      ),
                    ]
                )
            )
        )
    );
  }
}
```

