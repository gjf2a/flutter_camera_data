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

Add the following to `pubspec.yaml`:
```yaml
  flutter_camera_data:
    git: https://github.com/gjf2a/flutter_camera_data
```

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
