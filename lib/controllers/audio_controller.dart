import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/viseme_model.dart';

class AudioController extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentAudioPath;
  bool _isPlaying = false;
  double _currentIntensity = 0.0;
  int _currentViseme = 0;
  Timer? _intensityTimer;
  
  // Getters
  String? get currentAudioPath => _currentAudioPath;
  bool get isPlaying => _isPlaying;
  double get currentIntensity => _currentIntensity;
  int get currentViseme => _currentViseme;
  
  AudioController() {
    _init();
  }
  
  Future<void> _init() async {
    // Solicitar permisos necesarios
    await [
      Permission.storage,
      Permission.microphone,
    ].request();
    
    // Configurar listener para cambios en el estado de reproducción
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });
  }
  
  Future<void> pickAndPlayAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final path = file.path!;
        
        await _loadAndPlayAudio(path);
      }
    } catch (e) {
      debugPrint('Error al seleccionar audio: $e');
    }
  }
  
  Future<void> _loadAndPlayAudio(String path) async {
    try {
      await _audioPlayer.setFilePath(path);
      await _audioPlayer.play();
      
      _currentAudioPath = path;
      _startIntensitySimulation();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error al reproducir audio: $e');
    }
  }
  
  // Simula la detección de intensidad del audio en tiempo real
  // En una implementación real, esto utilizaría FFT para analizar el audio
  void _startIntensitySimulation() {
    _intensityTimer?.cancel();
    
    _intensityTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isPlaying) {
        _currentIntensity = 0.0;
        _currentViseme = VisemeModel.REST;
        notifyListeners();
        return;
      }
      
      // Simular variaciones de intensidad basadas en un patrón semi-aleatorio
      final time = DateTime.now().millisecondsSinceEpoch / 1000;
      final baseIntensity = (0.5 + 0.5 * Math.sin(time * 2)) * 0.7;
      final randomFactor = 0.3 * Math.random();
      
      _currentIntensity = (baseIntensity + randomFactor).clamp(0.0, 1.0);
      _currentViseme = VisemeModel.mapIntensityToViseme(_currentIntensity);
      
      notifyListeners();
    });
  }
  
  Future<void> togglePlayback() async {
    if (_currentAudioPath == null) return;
    
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }
  
  Future<void> stopPlayback() async {
    await _audioPlayer.stop();
    _currentIntensity = 0.0;
    _currentViseme = VisemeModel.REST;
    notifyListeners();
  }
  
  @override
  void dispose() {
    _intensityTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

// Clase auxiliar para funciones matemáticas
class Math {
  static double sin(double x) {
    return math.sin(x);
  }
  
  static double random() {
    return math.Random().nextDouble();
  }
}
