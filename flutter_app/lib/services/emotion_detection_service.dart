import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';
import 'dart:math' as math;

class EmotionDetectionService {
  final FaceDetector _faceDetector;
  
  EmotionDetectionService()
      : _faceDetector = FaceDetector(
          options: FaceDetectorOptions(
            enableContours: true,
            enableClassification: true,
            enableLandmarks: true,
            enableTracking: true,
          ),
        );

  Future<String> detectEmotion(CameraImage image, int sensorOrientation) async {
    try {
      final InputImage inputImage = _convertCameraImage(image, sensorOrientation);
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      
      if (faces.isEmpty) {
        return 'neutral';
      }

      final Face face = faces.first;
      
      // Use ML Kit's face classification features
      final double? smilingProb = face.smilingProbability;
      final double? leftEyeOpenProb = face.leftEyeOpenProbability;
      final double? rightEyeOpenProb = face.rightEyeOpenProbability;

      // Advanced emotion detection logic
      return _classifyEmotion(
        smilingProb: smilingProb,
        leftEyeOpen: leftEyeOpenProb,
        rightEyeOpen: rightEyeOpenProb,
      );
    } catch (e) {
      print('Error detecting emotion: $e');
      return 'neutral';
    }
  }

  String _classifyEmotion({
    double? smilingProb,
    double? leftEyeOpen,
    double? rightEyeOpen,
  }) {
    // Default probabilities if null
    final smiling = smilingProb ?? 0.0;
    final leftEye = leftEyeOpen ?? 1.0;
    final rightEye = rightEyeOpen ?? 1.0;

    // Happy: High smiling probability
    if (smiling > 0.7) {
      return 'happy';
    }

    // Surprised: Wide eyes, moderate smile
    if (leftEye > 0.9 && rightEye > 0.9 && smiling > 0.3 && smiling < 0.7) {
      return 'surprised';
    }

    // Sad: Low smiling, slightly closed eyes
    if (smiling < 0.2 && (leftEye < 0.6 || rightEye < 0.6)) {
      return 'sad';
    }

    // Angry: Low smiling, tense eyes (medium open)
    if (smiling < 0.15 && leftEye > 0.4 && leftEye < 0.8 && rightEye > 0.4 && rightEye < 0.8) {
      return 'angry';
    }

    // Calm/Neutral: Moderate everything
    return 'calm';
  }

  InputImage _convertCameraImage(CameraImage image, int sensorOrientation) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final InputImageRotation imageRotation =
        _rotationIntToImageRotation(sensorOrientation);

    final InputImageFormat inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.nv21;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      inputImageData: inputImageData,
    );
  }

  InputImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}

// Required import for WriteBuffer
import 'dart:typed_data';
import 'dart:ui';
