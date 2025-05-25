import 'dart:async';
import 'package:flutter/material.dart';
import '../models/viseme_data.dart';
import '../models/viseme_model.dart';

/// Controlador para sincronización labial fonética
class PhoneticLipSyncController {
  // Controladores de streams
  final _visemeController = StreamController<VisemeData>.broadcast();
  Stream<VisemeData> get visemeStream => _visemeController.stream;
  
  // Estado interno
  bool _isPlaying = false;
  String? _currentAudioPath;
  
  // Timer para simulación de visemas
  Timer? _visemeSimulationTimer;
  
  // Constructor
  PhoneticLipSyncController();
  
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
      
      // Iniciar simulación de visemas
      _startVisemeSimulation();
      
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
      _stopVisemeSimulation();
      
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
      _stopVisemeSimulation();
      
      // Notificar cambio de estado
      debugPrint('Audio detenido');
    } catch (e) {
      debugPrint('Error al detener audio: $e');
      rethrow;
    }
  }
  
  // Iniciar simulación de visemas
  void _startVisemeSimulation() {
    _stopVisemeSimulation(); // Asegurar que no haya simulación previa
    
    // Simular detección de visemas con un timer
    _visemeSimulationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isPlaying) {
        _emitRestViseme();
        return;
      }
      
      // Generar visema aleatorio para simulación
      final viseme = _generateRandomViseme();
      
      // Emitir visema
      _visemeController.add(viseme);
    });
  }
  
  // Generar visema aleatorio para simulación
  VisemeData _generateRandomViseme() {
    // Lista de fonemas para simulación
    final phonemes = ['A', 'E', 'I', 'O', 'U', 'B', 'M', 'P', 'rest'];
    
    // Seleccionar fonema aleatorio
    final phoneme = phonemes[DateTime.now().millisecondsSinceEpoch % phonemes.length];
    
    // Obtener visema correspondiente
    final viseme = VisemeModel.getVisemeForPhoneme(phoneme);
    
    // Generar nivel de audio aleatorio entre 0.1 y 0.9
    final audioLevel = 0.1 + (DateTime.now().millisecondsSinceEpoch % 80) / 100;
    
    // Calcular intensidad basada en el nivel de audio y el tipo de visema
    final baseIntensity = VisemeModel.getIntensityForViseme(viseme);
    final intensity = baseIntensity * audioLevel;
    
    // Generar frecuencia aleatoria (simulación)
    final frequency = 100.0 + (DateTime.now().millisecondsSinceEpoch % 900);
    
    return VisemeData(
      phoneme: phoneme,
      viseme: viseme,
      intensity: intensity,
      audioLevel: audioLevel,
      frequency: frequency.toDouble(),
    );
  }
  
  // Emitir visema de reposo
  void _emitRestViseme() {
    final restViseme = VisemeData(
      phoneme: 'rest',
      viseme: 'viseme_rest',
      intensity: 0.0,
      audioLevel: 0.0,
      frequency: 0.0,
    );
    
    _visemeController.add(restViseme);
  }
  
  // Generar comando JavaScript para sincronización labial
  String generateLipSyncCommand(VisemeData visemeData) {
    // En una implementación real, esto generaría un comando JavaScript
    // para controlar los blendshapes del modelo 3D
    
    // Ejemplo simplificado
    return '''
      const model = document.querySelector('model-viewer');
      if (model && model.model) {
        // Aplicar visema: ${visemeData.viseme}
        // Intensidad: ${visemeData.intensity}
      }
    ''';
  }
  
  // Detener simulación de visemas
  void _stopVisemeSimulation() {
    _visemeSimulationTimer?.cancel();
    _visemeSimulationTimer = null;
    _emitRestViseme();
  }
  
  // Liberar recursos
  void dispose() {
    _stopVisemeSimulation();
    _visemeController.close();
  }
}
