import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'services/emotion_detection_service.dart';
import 'models/emotion_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Get available cameras
  final cameras = await availableCameras();
  final frontCamera = cameras.firstWhere(
    (camera) => camera.lensDirection == CameraLensDirection.front,
    orElse: () => cameras.first,
  );

  runApp(MoodMirrorApp(camera: frontCamera));
}

class MoodMirrorApp extends StatelessWidget {
  final CameraDescription camera;

  const MoodMirrorApp({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Mirror',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: MoodMirrorHome(camera: camera),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MoodMirrorHome extends StatefulWidget {
  final CameraDescription camera;

  const MoodMirrorHome({Key? key, required this.camera}) : super(key: key);

  @override
  State<MoodMirrorHome> createState() => _MoodMirrorHomeState();
}

class _MoodMirrorHomeState extends State<MoodMirrorHome> {
  CameraController? _cameraController;
  EmotionDetectionService? _emotionService;
  FlutterTts? _flutterTts;
  
  String _currentEmotion = 'calm';
  String _currentJoke = '';
  String? _currentSuggestion;
  bool _isProcessing = false;
  bool _cameraReady = false;
  bool _showDisclaimer = true;
  Timer? _detectionTimer;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      _showPermissionDialog();
      return;
    }

    // Initialize camera
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    try {
      await _cameraController!.initialize();
      setState(() {
        _cameraReady = true;
      });

      // Start image stream for emotion detection
      _startEmotionDetection();
    } catch (e) {
      print('Error initializing camera: $e');
    }

    // Initialize TTS
    _flutterTts = FlutterTts();
    await _flutterTts!.setLanguage("en-US");
    await _flutterTts!.setSpeechRate(0.5);
    await _flutterTts!.setVolume(1.0);

    // Initialize emotion detection service
    _emotionService = EmotionDetectionService();

    // Get initial joke
    _currentJoke = EmotionDatabase.getRandomJoke();
  }

  void _startEmotionDetection() {
    _detectionTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!_isProcessing && _cameraController != null && _cameraReady) {
        _isProcessing = true;
        
        try {
          _cameraController!.startImageStream((CameraImage image) async {
            if (!_isProcessing) return;
            
            final emotion = await _emotionService!.detectEmotion(
              image,
              widget.camera.sensorOrientation,
            );

            if (mounted && emotion != _currentEmotion) {
              setState(() {
                _currentEmotion = emotion;
                _currentJoke = EmotionDatabase.getRandomJoke();
                _currentSuggestion = EmotionDatabase.getSuggestion(emotion);
              });

              // Speak the mood
              final emotionData = EmotionDatabase.getEmotionData(emotion);
              await _flutterTts?.speak(emotionData.mood);
            }

            await _cameraController!.stopImageStream();
            _isProcessing = false;
          });
        } catch (e) {
          _isProcessing = false;
          print('Error in emotion detection: $e');
        }
      }
    });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'Mood Mirror needs camera access to detect emotions. '
          'Please grant camera permission in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    final colorHex = EmotionDatabase.getEmotionData(emotion).color;
    return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    _cameraController?.dispose();
    _emotionService?.dispose();
    _flutterTts?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showDisclaimer) {
      return _buildDisclaimerScreen();
    }

    final emotionData = EmotionDatabase.getEmotionData(_currentEmotion);
    final emotionColor = _getEmotionColor(_currentEmotion);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              emotionColor.withOpacity(0.3),
              Colors.white,
              emotionColor.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Camera Preview
              Expanded(
                flex: 3,
                child: _buildCameraPreview(),
              ),
              
              // Mood Display
              Expanded(
                flex: 2,
                child: _buildMoodDisplay(emotionData, emotionColor),
              ),
              
              // Joke/Suggestion
              Expanded(
                flex: 2,
                child: _buildJokeSuggestion(),
              ),
              
              // Try Again Button
              _buildTryAgainButton(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimerScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade100,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_emotions,
                  size: 100,
                  color: Colors.purple,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Welcome to Mood Mirror! 😊',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.info_outline, size: 40, color: Colors.blue),
                      SizedBox(height: 15),
                      Text(
                        'DISCLAIMER',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'This app is for educational and fun purposes only.\n\n'
                        '✓ No images or videos are stored\n'
                        '✓ All processing happens on your device\n'
                        '✓ No data is uploaded to the cloud\n'
                        '✓ Not a medical or psychological tool\n\n'
                        'Enjoy exploring your emotions! 🎉',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showDisclaimer = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'I Understand - Let\'s Start!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.emoji_emotions, size: 32, color: Colors.purple),
              SizedBox(width: 10),
              Text(
                'Mood Mirror',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.purple),
            onPressed: () {
              setState(() {
                _showDisclaimer = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_cameraReady || _cameraController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: Colors.purple),
            SizedBox(height: 20),
            Text(
              'Initializing Camera...',
              style: TextStyle(fontSize: 16, color: Colors.purple),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: CameraPreview(_cameraController!),
      ),
    );
  }

  Widget _buildMoodDisplay(EmotionData emotionData, Color emotionColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: emotionColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emotionData.emoji,
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 10),
          Text(
            emotionData.emotion,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: emotionColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            emotionData.mood,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildJokeSuggestion() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade200, width: 2),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (_currentSuggestion != null) ...[
              const Icon(Icons.lightbulb, size: 32, color: Colors.orange),
              const SizedBox(height: 10),
              const Text(
                'Suggestion:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currentSuggestion!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
            ],
            const Icon(Icons.theater_comedy, size: 32, color: Colors.green),
            const SizedBox(height: 10),
            const Text(
              'Here\'s a joke for you:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentJoke,
              style: const TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTryAgainButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            _currentJoke = EmotionDatabase.getRandomJoke();
          });
          _flutterTts?.speak('Let me analyze your mood again');
        },
        icon: const Icon(Icons.refresh, size: 24),
        label: const Text(
          'Try Again',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
      ),
    );
  }
}
