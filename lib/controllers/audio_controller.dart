import 'package:flutter/material.dart';
import 'dart:async';

/// Controlador de audio simplificado para la aplicación
class AudioController {
  // Estado del audio
  bool _isPlaying = false;
  String? _currentAudioPath;
  
  // Controladores de streams
  final _audioLevelController = StreamController<double>.broadcast();
  Stream<double> get audioLevelStream => _audioLevelController.stream;
  
  // Timer para simulación de audio
  Timer? _audioSimulationTimer;
  
  // Constructor
  AudioController();
  
  // Verificar si está reproduciendo
  bool get isPlaying => _isPlaying;
  
  // Obtener ruta de audio actual
  String? get currentAudioPath => _currentAudioPath;
  
  // Reproducir audio
  Future<void> playAudio(String path) async {
    if (_currentAudioPath == path && _isPlaying) {
      await pauseAudio();
      return;
    }

    try {
      // En una implementación real, aquí se cargaría y reproduciría el audio
      // Para el prototipo, solo actualizamos el estado
      _currentAudioPath = path;
      _isPlaying = true;
      
      // Iniciar simulación de niveles de audio
      _startAudioLevelSimulation();
      
      // Notificar cambio de estado
      debugPrint('Reproduciendo audio: $path');
    } catch (e) {
      debugPrint('Error al reproducir audio: $e');
      rethrow;
    }
  }
  
  // Pausar audio
  Future<void> pauseAudio() async {
    if (!_isPlaying) return;
    
    try {
      // En una implementación real, aquí se pausaría el audio
      // Para el prototipo, solo actualizamos el estado
      _isPlaying = false;
      _stopAudioLevelSimulation();
      
      // Notificar cambio de estado
      debugPrint('Audio pausado');
    } catch (e) {
      debugPrint('Error al pausar audio: $e');
      rethrow;
    }
  }
  
  // Detener audio
  Future<void> stopAudio() async {
    if (!_isPlaying && _currentAudioPath == null) return;
    
    try {
      // En una implementación real, aquí se detendría el audio
      // Para el prototipo, solo actualizamos el estado
      _isPlaying = false;
      _currentAudioPath = null;
      _stopAudioLevelSimulation();
      
      // Notificar cambio de estado
      debugPrint('Audio detenido');
    } catch (e) {
      debugPrint('Error al detener audio: $e');
      rethrow;
    }
  }
  
  // Iniciar simulación de niveles de audio
  void _startAudioLevelSimulation() {
    _stopAudioLevelSimulation(); // Asegurar que no haya simulación previa
    
    // Simular niveles de audio con un timer
    _audioSimulationTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isPlaying) {
        _audioLevelController.add(0.0);
        return;
      }
      
      // Generar nivel de audio aleatorio entre 0.1 y 0.9
      final audioLevel = 0.1 + (DateTime.now().millisecondsSinceEpoch % 80) / 100;
      _audioLevelController.add(audioLevel);
    });
  }
  
  // Detener simulación de niveles de audio
  void _stopAudioLevelSimulation() {
    _audioSimulationTimer?.cancel();
    _audioSimulationTimer = null;
    _audioLevelController.add(0.0); // Resetear nivel de audio
  }
  
  // Liberar recursos
  void dispose() {
    _stopAudioLevelSimulation();
    _audioLevelController.close();
  }
}
