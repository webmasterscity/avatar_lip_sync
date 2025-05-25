import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Clase que implementa análisis fonético básico y mapeo a visemas
class PhoneticAnalyzer {
  // Mapa de fonemas a visemas (simplificado para prototipo inicial)
  static const Map<String, String> phonemeToViseme = {
    'A': 'viseme_aa',   // Como en "padre"
    'E': 'viseme_ee',   // Como en "mesa"
    'I': 'viseme_ih',   // Como en "piso"
    'O': 'viseme_oh',   // Como en "boca"
    'U': 'viseme_ou',   // Como en "luna"
    'B': 'viseme_mb',   // Como en "beso"
    'P': 'viseme_mb',   // Como en "peso"
    'M': 'viseme_mb',   // Como en "mesa"
    'F': 'viseme_ff',   // Como en "foco"
    'V': 'viseme_ff',   // Como en "vaso"
    'T': 'viseme_dd',   // Como en "taza"
    'D': 'viseme_dd',   // Como en "dedo"
    'S': 'viseme_ss',   // Como en "sopa"
    'Z': 'viseme_ss',   // Como en "zapato"
    'L': 'viseme_dd',   // Como en "luna"
    'R': 'viseme_rr',   // Como en "perro"
    'K': 'viseme_kk',   // Como en "casa"
    'G': 'viseme_kk',   // Como en "gato"
    'N': 'viseme_dd',   // Como en "nada"
    'CH': 'viseme_ch',  // Como en "chico"
    'J': 'viseme_ch',   // Como en "juego"
    'Y': 'viseme_y',    // Como en "yo"
    'W': 'viseme_wq',   // Como en "huevo"
    'TH': 'viseme_th',  // Como en "think" (inglés)
    'rest': 'viseme_rest' // Posición neutral
  };

  // Valores de intensidad para cada visema
  static const Map<String, double> visemeIntensity = {
    'viseme_aa': 0.8,   // Boca muy abierta
    'viseme_ee': 0.6,   // Boca semi-abierta, labios estirados
    'viseme_ih': 0.4,   // Boca pequeña, labios estirados
    'viseme_oh': 0.7,   // Labios redondeados
    'viseme_ou': 0.5,   // Labios adelantados, redondeados
    'viseme_mb': 0.1,   // Labios cerrados
    'viseme_ff': 0.3,   // Labio inferior tocando dientes superiores
    'viseme_dd': 0.4,   // Punta de lengua tocando paladar
    'viseme_kk': 0.5,   // Parte posterior de lengua elevada
    'viseme_ch': 0.4,   // Labios adelantados, ligeramente abiertos
    'viseme_ss': 0.3,   // Dientes casi cerrados, labios estirados
    'viseme_th': 0.3,   // Lengua entre dientes
    'viseme_rr': 0.5,   // Labios ligeramente adelantados
    'viseme_wq': 0.4,   // Labios muy redondeados
    'viseme_y': 0.4,    // Boca pequeña, labios estirados
    'viseme_rest': 0.0  // Posición neutral
  };

  // Simulación de análisis fonético basado en intensidad de audio
  // En una implementación real, esto utilizaría un modelo de ML para detectar fonemas
  String detectPhonemeFromAudio(double audioLevel, double frequency) {
    // Simulación simplificada para prototipo
    if (audioLevel < 0.1) return 'rest';
    
    // Simulación basada en intensidad y frecuencia
    // En una implementación real, esto sería reemplazado por un modelo de ML
    if (frequency < 200) {
      if (audioLevel > 0.7) return 'A';
      if (audioLevel > 0.5) return 'O';
      if (audioLevel > 0.3) return 'U';
      return 'M';
    } else if (frequency < 500) {
      if (audioLevel > 0.7) return 'E';
      if (audioLevel > 0.5) return 'I';
      if (audioLevel > 0.3) return 'D';
      return 'N';
    } else if (frequency < 1000) {
      if (audioLevel > 0.6) return 'S';
      if (audioLevel > 0.4) return 'F';
      if (audioLevel > 0.2) return 'T';
      return 'P';
    } else {
      if (audioLevel > 0.6) return 'CH';
      if (audioLevel > 0.4) return 'Z';
      if (audioLevel > 0.2) return 'R';
      return 'L';
    }
  }

  // Obtener el nombre del visema correspondiente a un fonema
  String getVisemeForPhoneme(String phoneme) {
    return phonemeToViseme[phoneme] ?? 'viseme_rest';
  }

  // Obtener la intensidad del visema
  double getVisemeIntensity(String viseme) {
    return visemeIntensity[viseme] ?? 0.0;
  }

  // Método principal para analizar audio y obtener visema
  VisemeData analyzeAudio(double audioLevel) {
    // En una implementación real, extraeríamos la frecuencia dominante del audio
    // Para el prototipo, simulamos con un valor aleatorio
    final frequency = 200.0 + Random().nextDouble() * 1000.0;
    
    // Detectar fonema basado en audio
    final phoneme = detectPhonemeFromAudio(audioLevel, frequency);
    
    // Obtener visema correspondiente
    final viseme = getVisemeForPhoneme(phoneme);
    
    // Obtener intensidad base del visema
    final intensity = getVisemeIntensity(viseme);
    
    // Ajustar intensidad según nivel de audio
    final adjustedIntensity = intensity * (0.5 + audioLevel * 0.5);
    
    return VisemeData(
      phoneme: phoneme,
      viseme: viseme,
      intensity: adjustedIntensity,
      audioLevel: audioLevel,
      frequency: frequency
    );
  }
}

/// Clase para almacenar datos de visema detectado
class VisemeData {
  final String phoneme;    // Fonema detectado
  final String viseme;     // Visema correspondiente
  final double intensity;  // Intensidad del visema (0.0-1.0)
  final double audioLevel; // Nivel de audio original
  final double frequency;  // Frecuencia dominante (Hz)

  VisemeData({
    required this.phoneme,
    required this.viseme,
    required this.intensity,
    required this.audioLevel,
    required this.frequency
  });

  @override
  String toString() {
    return 'VisemeData(phoneme: $phoneme, viseme: $viseme, intensity: ${intensity.toStringAsFixed(2)}, audioLevel: ${audioLevel.toStringAsFixed(2)}, frequency: ${frequency.toStringAsFixed(0)}Hz)';
  }
}

/// Controlador principal para análisis fonético y lipsync
class PhoneticLipSyncController {
  final phoneticAnalyzer = PhoneticAnalyzer();
  final player = AudioPlayer();
  
  // Estado actual
  VisemeData? currentViseme;
  bool isPlaying = false;
  String? currentAudioPath;
  
  // Controladores de streams
  final _visemeStreamController = StreamController<VisemeData>.broadcast();
  Stream<VisemeData> get visemeStream => _visemeStreamController.stream;
  
  // Timer para análisis periódico
  Timer? _analysisTimer;
  
  // Constructor
  PhoneticLipSyncController() {
    _setupAudioPlayer();
  }
  
  // Configurar reproductor de audio
  void _setupAudioPlayer() {
    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        isPlaying = false;
        _stopAnalysis();
      }
    });
  }
  
  // Reproducir audio
  Future<void> playAudio(String path) async {
    if (currentAudioPath == path && isPlaying) {
      await player.pause();
      isPlaying = false;
      _stopAnalysis();
      return;
    }

    try {
      if (currentAudioPath != path) {
        await player.setAsset(path);
        currentAudioPath = path;
      }
      
      await player.play();
      isPlaying = true;
      _startAnalysis();
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }
  
  // Iniciar análisis periódico
  void _startAnalysis() {
    _stopAnalysis(); // Asegurar que no haya análisis previos en curso
    
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      // En una implementación real, obtendríamos el nivel de audio actual
      // Para el prototipo, simulamos con valores aleatorios
      final random = Random();
      final audioLevel = random.nextDouble() * 0.8;
      
      // Analizar audio y obtener visema
      final visemeData = phoneticAnalyzer.analyzeAudio(audioLevel);
      
      // Actualizar estado y notificar a los listeners
      currentViseme = visemeData;
      _visemeStreamController.add(visemeData);
    });
  }
  
  // Detener análisis
  void _stopAnalysis() {
    _analysisTimer?.cancel();
    _analysisTimer = null;
    
    // Resetear a posición neutral
    final neutralViseme = VisemeData(
      phoneme: 'rest',
      viseme: 'viseme_rest',
      intensity: 0.0,
      audioLevel: 0.0,
      frequency: 0.0
    );
    
    currentViseme = neutralViseme;
    _visemeStreamController.add(neutralViseme);
  }
  
  // Generar comando JavaScript para animar el modelo 3D
  String generateLipSyncCommand(VisemeData visemeData) {
    return '''
      (function() {
        const model = document.querySelector('model-viewer');
        if (model && model.model) {
          // Acceder a los morph targets del modelo
          const morphTargets = model.model.morphTargetDictionary;
          if (morphTargets) {
            // Mapeo de visemas a morph targets específicos del modelo
            const visemeToMorphTarget = {
              'viseme_aa': ['mouthOpen', 'jawOpen'],
              'viseme_ee': ['mouthSmile', 'viseme_E'],
              'viseme_ih': ['viseme_I'],
              'viseme_oh': ['mouthRound', 'viseme_O'],
              'viseme_ou': ['mouthPucker', 'viseme_U'],
              'viseme_mb': ['mouthClose', 'jawClose'],
              'viseme_ff': ['mouthLowerInside'],
              'viseme_dd': ['tongueUp'],
              'viseme_kk': ['tongueBack'],
              'viseme_ch': ['mouthForward'],
              'viseme_ss': ['mouthNarrow'],
              'viseme_th': ['tongueFront'],
              'viseme_rr': ['mouthForward', 'tongueUp'],
              'viseme_wq': ['mouthRound', 'mouthForward'],
              'viseme_y': ['mouthSmile', 'mouthNarrow'],
              'viseme_rest': []
            };
            
            // Resetear todos los morph targets relacionados con la boca
            Object.keys(visemeToMorphTarget).forEach(viseme => {
              visemeToMorphTarget[viseme].forEach(morphName => {
                const idx = morphTargets[morphName];
                if (idx !== undefined) {
                  model.model.morphTargetInfluences[idx] = 0.0;
                }
              });
            });
            
            // Aplicar el visema actual
            const currentMorphTargets = visemeToMorphTarget['${visemeData.viseme}'] || [];
            currentMorphTargets.forEach(morphName => {
              const idx = morphTargets[morphName];
              if (idx !== undefined) {
                model.model.morphTargetInfluences[idx] = ${visemeData.intensity};
              }
            });
          }
        }
      })();
    ''';
  }
  
  // Liberar recursos
  void dispose() {
    _stopAnalysis();
    _visemeStreamController.close();
    player.dispose();
  }
}

// Clase simulada para pruebas
class AudioPlayer {
  Stream<PlayerState> get playerStateStream => Stream.value(PlayerState(ProcessingState.ready));
  
  Future<void> setAsset(String path) async {
    // Simulación
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  Future<void> play() async {
    // Simulación
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  Future<void> pause() async {
    // Simulación
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  void dispose() {
    // Simulación
  }
}

// Clases simuladas para pruebas
class PlayerState {
  final ProcessingState processingState;
  
  PlayerState(this.processingState);
}

enum ProcessingState {
  idle,
  loading,
  ready,
  buffering,
  completed,
}
