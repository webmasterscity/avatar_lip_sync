import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../controllers/phonetic_lipsync_controller.dart';

/// Clase para manejar la interpolación suave entre visemas
class VisemeInterpolator {
  // Historial de visemas recientes para interpolación
  final List<VisemeHistoryEntry> _visemeHistory = [];
  
  // Configuración de interpolación
  final double _baseTransitionDuration; // Duración base en milisegundos
  final double _anticipationFactor; // Factor de anticipación (0.0-1.0)
  final Curve _transitionCurve; // Curva de interpolación
  
  // Visema actual interpolado
  VisemeData? _currentInterpolatedViseme;
  
  // Temporizador para actualización de interpolación
  Timer? _interpolationTimer;
  
  // Constructor con parámetros configurables
  VisemeInterpolator({
    double baseTransitionDuration = 100.0, // 100ms por defecto
    double anticipationFactor = 0.2, // 20% de anticipación por defecto
    Curve transitionCurve = Curves.easeInOut, // Curva suave por defecto
  }) : 
    _baseTransitionDuration = baseTransitionDuration,
    _anticipationFactor = anticipationFactor,
    _transitionCurve = transitionCurve;
  
  // Obtener el visema actual interpolado
  VisemeData? get currentInterpolatedViseme => _currentInterpolatedViseme;
  
  // Iniciar la interpolación
  void start() {
    _stopInterpolation(); // Asegurar que no haya interpolación previa en curso
    
    // Iniciar timer para actualización de interpolación (60fps)
    _interpolationTimer = Timer.periodic(const Duration(milliseconds: 16), _updateInterpolation);
  }
  
  // Detener la interpolación
  void stop() {
    _stopInterpolation();
    _visemeHistory.clear();
    _currentInterpolatedViseme = null;
  }
  
  // Método privado para detener el timer
  void _stopInterpolation() {
    _interpolationTimer?.cancel();
    _interpolationTimer = null;
  }
  
  // Añadir un nuevo visema al historial
  void addViseme(VisemeData viseme) {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Añadir nuevo visema al historial
    _visemeHistory.add(VisemeHistoryEntry(
      viseme: viseme,
      timestamp: now,
    ));
    
    // Limitar el historial a los últimos 10 visemas
    if (_visemeHistory.length > 10) {
      _visemeHistory.removeAt(0);
    }
    
    // Si no hay interpolación en curso, iniciarla
    if (_interpolationTimer == null) {
      start();
    }
  }
  
  // Actualizar la interpolación (llamado por el timer)
  void _updateInterpolation(Timer timer) {
    if (_visemeHistory.isEmpty) {
      return; // No hay visemas para interpolar
    }
    
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Limpiar visemas antiguos (más de 1 segundo)
    _visemeHistory.removeWhere((entry) => now - entry.timestamp > 1000);
    
    if (_visemeHistory.isEmpty) {
      return; // Todos los visemas eran antiguos
    }
    
    // Obtener el visema más reciente
    final latestEntry = _visemeHistory.last;
    
    // Si solo hay un visema o es muy reciente, usarlo directamente
    if (_visemeHistory.length == 1 || now - latestEntry.timestamp < 20) {
      _currentInterpolatedViseme = latestEntry.viseme;
      return;
    }
    
    // Encontrar los dos visemas más cercanos al tiempo actual para interpolación
    VisemeHistoryEntry? prevEntry;
    VisemeHistoryEntry? nextEntry;
    
    // Calcular tiempo de transición basado en la duración base y el contexto fonético
    final transitionDuration = _calculateTransitionDuration(
      latestEntry.viseme.phoneme, 
      _visemeHistory[_visemeHistory.length - 2].viseme.phoneme
    );
    
    // Tiempo de anticipación
    final anticipationTime = transitionDuration * _anticipationFactor;
    
    // Tiempo proyectado para el próximo visema
    final projectedNextTime = latestEntry.timestamp + transitionDuration.toInt();
    
    // Si estamos en anticipación del próximo visema
    if (now > projectedNextTime - anticipationTime.toInt()) {
      // Usar el visema actual como previo y anticipar el siguiente
      prevEntry = latestEntry;
      // El siguiente visema es una proyección basada en tendencias recientes
      nextEntry = _projectNextViseme();
    } else {
      // Buscar los dos visemas que rodean el tiempo actual
      for (int i = _visemeHistory.length - 1; i >= 0; i--) {
        if (_visemeHistory[i].timestamp <= now) {
          prevEntry = _visemeHistory[i];
          if (i < _visemeHistory.length - 1) {
            nextEntry = _visemeHistory[i + 1];
          }
          break;
        }
      }
      
      // Si no encontramos un previo, usar el más antiguo
      prevEntry ??= _visemeHistory.first;
      
      // Si no encontramos un siguiente, usar el más reciente
      nextEntry ??= _visemeHistory.last;
    }
    
    // Calcular el factor de interpolación (0.0-1.0)
    double t;
    if (prevEntry.timestamp == nextEntry.timestamp) {
      t = 1.0; // Evitar división por cero
    } else {
      t = (now - prevEntry.timestamp) / (nextEntry.timestamp - prevEntry.timestamp);
      t = t.clamp(0.0, 1.0); // Asegurar que esté en el rango [0,1]
    }
    
    // Aplicar la curva de interpolación
    t = _transitionCurve.transform(t);
    
    // Interpolar entre los dos visemas
    _currentInterpolatedViseme = _interpolateVisemes(prevEntry.viseme, nextEntry.viseme, t);
  }
  
  // Calcular la duración de transición basada en el contexto fonético
  double _calculateTransitionDuration(String currentPhoneme, String prevPhoneme) {
    // Duración base
    double duration = _baseTransitionDuration;
    
    // Ajustar duración según el contexto fonético
    
    // 1. Transiciones entre vocales: más suaves y lentas
    final vowels = ['A', 'E', 'I', 'O', 'U'];
    if (vowels.contains(currentPhoneme) && vowels.contains(prevPhoneme)) {
      duration *= 1.5; // 50% más lenta
    }
    
    // 2. Transiciones desde/hacia consonantes oclusivas: más rápidas
    final plosives = ['P', 'B', 'T', 'D', 'K', 'G'];
    if (plosives.contains(currentPhoneme) || plosives.contains(prevPhoneme)) {
      duration *= 0.7; // 30% más rápida
    }
    
    // 3. Transiciones desde/hacia consonantes fricativas: velocidad media
    final fricatives = ['F', 'V', 'S', 'Z', 'SH', 'TH'];
    if (fricatives.contains(currentPhoneme) || fricatives.contains(prevPhoneme)) {
      duration *= 0.9; // 10% más rápida
    }
    
    // 4. Transición desde/hacia silencio: más lenta
    if (currentPhoneme == 'rest' || prevPhoneme == 'rest') {
      duration *= 1.3; // 30% más lenta
    }
    
    return duration;
  }
  
  // Proyectar el próximo visema basado en tendencias recientes
  VisemeHistoryEntry _projectNextViseme() {
    // Si no hay suficiente historial, duplicar el último
    if (_visemeHistory.length < 3) {
      return VisemeHistoryEntry(
        viseme: _visemeHistory.last.viseme,
        timestamp: _visemeHistory.last.timestamp + 100, // +100ms en el futuro
      );
    }
    
    // Analizar la tendencia de los últimos 3 visemas
    final last = _visemeHistory.last;
    final prev = _visemeHistory[_visemeHistory.length - 2];
    final prevPrev = _visemeHistory[_visemeHistory.length - 3];
    
    // Calcular delta de intensidad
    final deltaIntensity1 = last.viseme.intensity - prev.viseme.intensity;
    final deltaIntensity2 = prev.viseme.intensity - prevPrev.viseme.intensity;
    
    // Calcular delta de tiempo
    final deltaTime1 = last.timestamp - prev.timestamp;
    final deltaTime2 = prev.timestamp - prevPrev.timestamp;
    
    // Proyectar próxima intensidad basada en tendencia
    final projectedIntensity = last.viseme.intensity + deltaIntensity1 * 0.7 + deltaIntensity2 * 0.3;
    
    // Proyectar próximo timestamp basado en tendencia
    final projectedTimestamp = last.timestamp + deltaTime1;
    
    // Crear visema proyectado (manteniendo el mismo fonema/visema pero con intensidad proyectada)
    return VisemeHistoryEntry(
      viseme: VisemeData(
        phoneme: last.viseme.phoneme,
        viseme: last.viseme.viseme,
        intensity: projectedIntensity.clamp(0.0, 1.0),
        audioLevel: last.viseme.audioLevel,
        frequency: last.viseme.frequency,
      ),
      timestamp: projectedTimestamp,
    );
  }
  
  // Interpolar entre dos visemas
  VisemeData _interpolateVisemes(VisemeData from, VisemeData to, double t) {
    // Si los visemas son iguales, no hay necesidad de interpolar
    if (from.viseme == to.viseme) {
      return VisemeData(
        phoneme: to.phoneme,
        viseme: to.viseme,
        intensity: _lerpDouble(from.intensity, to.intensity, t),
        audioLevel: _lerpDouble(from.audioLevel, to.audioLevel, t),
        frequency: _lerpDouble(from.frequency, to.frequency, t),
      );
    }
    
    // Para visemas diferentes, la interpolación es más compleja
    // En una implementación real, esto podría usar un mapa de compatibilidad entre visemas
    // para determinar cómo interpolar entre diferentes posiciones de boca
    
    // Para el prototipo, usamos interpolación simple de intensidad
    // y elegimos el visema destino cuando t > 0.5
    final viseme = t > 0.5 ? to.viseme : from.viseme;
    final phoneme = t > 0.5 ? to.phoneme : from.phoneme;
    
    return VisemeData(
      phoneme: phoneme,
      viseme: viseme,
      intensity: _lerpDouble(from.intensity, to.intensity, t),
      audioLevel: _lerpDouble(from.audioLevel, to.audioLevel, t),
      frequency: _lerpDouble(from.frequency, to.frequency, t),
    );
  }
  
  // Interpolación lineal entre dos doubles
  double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
  
  // Liberar recursos
  void dispose() {
    stop();
  }
}

/// Clase para almacenar un visema con su timestamp
class VisemeHistoryEntry {
  final VisemeData viseme;
  final int timestamp; // milliseconds since epoch
  
  VisemeHistoryEntry({
    required this.viseme,
    required this.timestamp,
  });
}

/// Controlador avanzado de lipsync con interpolación
class AdvancedLipSyncController extends PhoneticLipSyncController {
  // Interpolador de visemas
  final VisemeInterpolator interpolator;
  
  // Stream controller para visemas interpolados
  final _interpolatedVisemeController = StreamController<VisemeData>.broadcast();
  Stream<VisemeData> get interpolatedVisemeStream => _interpolatedVisemeController.stream;
  
  // Constructor
  AdvancedLipSyncController({
    double baseTransitionDuration = 100.0,
    double anticipationFactor = 0.2,
    Curve transitionCurve = Curves.easeInOut,
  }) : 
    interpolator = VisemeInterpolator(
      baseTransitionDuration: baseTransitionDuration,
      anticipationFactor: anticipationFactor,
      transitionCurve: transitionCurve,
    ),
    super() {
    // Suscribirse al stream de visemas original
    visemeStream.listen(_handleRawViseme);
    
    // Iniciar timer para emitir visemas interpolados (30fps)
    Timer.periodic(const Duration(milliseconds: 33), _emitInterpolatedViseme);
  }
  
  // Manejar visema crudo del analizador fonético
  void _handleRawViseme(VisemeData viseme) {
    // Añadir al interpolador
    interpolator.addViseme(viseme);
  }
  
  // Emitir visema interpolado actual
  void _emitInterpolatedViseme(Timer timer) {
    final interpolatedViseme = interpolator.currentInterpolatedViseme;
    if (interpolatedViseme != null) {
      _interpolatedVisemeController.add(interpolatedViseme);
    }
  }
  
  // Generar comando JavaScript para animar el modelo 3D con visema interpolado
  @override
  String generateLipSyncCommand(VisemeData visemeData) {
    // Usar el visema interpolado si está disponible
    final viseme = interpolator.currentInterpolatedViseme ?? visemeData;
    
    // Generar comando con el visema interpolado
    return super.generateLipSyncCommand(viseme);
  }
  
  // Liberar recursos
  @override
  void dispose() {
    interpolator.dispose();
    _interpolatedVisemeController.close();
    super.dispose();
  }
}
