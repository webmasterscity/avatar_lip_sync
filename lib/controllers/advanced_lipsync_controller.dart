import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/viseme_data.dart';
import '../models/viseme_model.dart';

/// Controlador avanzado para sincronización labial con interpolación suave
class AdvancedLipSyncController {
  // Configuración de interpolación
  final double baseTransitionDuration;  // Duración base de transición en ms
  final double anticipationFactor;      // Factor de anticipación (0.0-1.0)
  final Curve transitionCurve;          // Curva de interpolación
  
  // Controladores de streams
  final _interpolatedVisemeController = StreamController<VisemeData>.broadcast();
  Stream<VisemeData> get interpolatedVisemeStream => _interpolatedVisemeController.stream;
  
  // Estado interno
  VisemeData _currentViseme = VisemeData(
    phoneme: 'rest',
    viseme: 'viseme_rest',
    intensity: 0.0,
    audioLevel: 0.0,
    frequency: 0.0,
  );
  
  // Cola de visemas para procesamiento avanzado
  final List<VisemeData> _visemeQueue = [];
  
  // Timer para simulación de visemas
  Timer? _visemeSimulationTimer;
  
  // Constructor
  AdvancedLipSyncController({
    this.baseTransitionDuration = 120.0,
    this.anticipationFactor = 0.25,
    this.transitionCurve = Curves.easeInOut,
  });
  
  // Reproducir audio y comenzar simulación de visemas
  Future<void> playAudio(String path) async {
    // En una implementación real, aquí se reproduciría el audio
    // y se analizaría para detectar fonemas
    
    // Para el prototipo, iniciamos una simulación de visemas
    _startVisemeSimulation();
  }
  
  // Iniciar simulación de visemas
  void _startVisemeSimulation() {
    _stopVisemeSimulation(); // Asegurar que no haya simulación previa
    
    // Simular detección de visemas con un timer
    _visemeSimulationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // Generar visema aleatorio para simulación
      final viseme = _generateRandomViseme();
      
      // Procesar visema con interpolación avanzada
      _processViseme(viseme);
    });
  }
  
  // Generar visema aleatorio para simulación
  VisemeData _generateRandomViseme() {
    // Lista de fonemas para simulación
    final phonemes = ['A', 'E', 'I', 'O', 'U', 'B', 'M', 'P', 'rest'];
    
    // Seleccionar fonema aleatorio con tendencia a mantener el actual
    final shouldChange = Random().nextDouble() > 0.7;
    final phoneme = shouldChange 
        ? phonemes[Random().nextInt(phonemes.length)]
        : _currentViseme.phoneme;
    
    // Obtener visema correspondiente
    final viseme = VisemeModel.getVisemeForPhoneme(phoneme);
    
    // Generar nivel de audio aleatorio entre 0.1 y 0.9
    final audioLevel = 0.1 + (Random().nextDouble() * 0.8);
    
    // Calcular intensidad basada en el nivel de audio y el tipo de visema
    final baseIntensity = VisemeModel.getIntensityForViseme(viseme);
    final intensity = baseIntensity * audioLevel;
    
    // Generar frecuencia aleatoria (simulación)
    final frequency = 100.0 + (Random().nextDouble() * 900.0);
    
    return VisemeData(
      phoneme: phoneme,
      viseme: viseme,
      intensity: intensity,
      audioLevel: audioLevel,
      frequency: frequency,
    );
  }
  
  // Procesar visema con interpolación avanzada
  void _processViseme(VisemeData newViseme) {
    // Añadir a la cola de visemas
    _visemeQueue.add(newViseme);
    
    // Mantener cola con tamaño máximo
    if (_visemeQueue.length > 5) {
      _visemeQueue.removeAt(0);
    }
    
    // Calcular visema interpolado
    final interpolatedViseme = _interpolateVisemes();
    
    // Actualizar visema actual
    _currentViseme = interpolatedViseme;
    
    // Emitir visema interpolado
    _interpolatedVisemeController.add(interpolatedViseme);
  }
  
  // Interpolar entre visemas para transiciones suaves
  VisemeData _interpolateVisemes() {
    // Si no hay suficientes visemas en la cola, devolver el actual
    if (_visemeQueue.length < 2) {
      return _visemeQueue.isNotEmpty ? _visemeQueue.first : _currentViseme;
    }
    
    // Obtener visema actual y siguiente
    final currentViseme = _visemeQueue[_visemeQueue.length - 2];
    final targetViseme = _visemeQueue[_visemeQueue.length - 1];
    
    // Calcular factor de interpolación (0.0-1.0)
    // En una implementación real, esto dependería del tiempo transcurrido
    final interpolationFactor = 0.5;
    
    // Aplicar curva de interpolación
    final curvedFactor = transitionCurve.transform(interpolationFactor);
    
    // Interpolar intensidad con anticipación
    final interpolatedIntensity = _interpolateWithAnticipation(
      currentViseme.intensity,
      targetViseme.intensity,
      curvedFactor,
    );
    
    // Crear visema interpolado
    return VisemeData(
      phoneme: targetViseme.phoneme,
      viseme: targetViseme.viseme,
      intensity: interpolatedIntensity,
      audioLevel: targetViseme.audioLevel,
      frequency: targetViseme.frequency,
    );
  }
  
  // Interpolar con factor de anticipación
  double _interpolateWithAnticipation(double start, double end, double factor) {
    // Aplicar anticipación para movimientos más naturales
    final anticipatedEnd = end * (1.0 + anticipationFactor);
    
    // Interpolar con anticipación
    double result = start + (anticipatedEnd - start) * factor;
    
    // Limitar a rango válido (0.0-1.0)
    return result.clamp(0.0, 1.0);
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
    
    // Resetear a posición neutral
    final restViseme = VisemeData(
      phoneme: 'rest',
      viseme: 'viseme_rest',
      intensity: 0.0,
      audioLevel: 0.0,
      frequency: 0.0,
    );
    
    _currentViseme = restViseme;
    _visemeQueue.clear();
    _interpolatedVisemeController.add(restViseme);
  }
  
  // Liberar recursos
  void dispose() {
    _stopVisemeSimulation();
    _interpolatedVisemeController.close();
  }
}
