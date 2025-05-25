import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LipSyncController {
  // Mapeo de fonemas a valores de blendshapes
  final Map<String, double> phonemeToBlendshape = {
    'A': 0.7,   // Boca abierta
    'E': 0.5,   // Boca semi-abierta, labios estirados
    'I': 0.3,   // Boca pequeña, labios estirados
    'O': 0.6,   // Boca redondeada
    'U': 0.4,   // Boca pequeña, redondeada
    'rest': 0.0 // Boca cerrada
  };
  
  // Método para obtener el valor de blendshape basado en la intensidad del audio
  double getBlendshapeValue(double audioLevel) {
    if (audioLevel < 0.1) return phonemeToBlendshape['rest'] ?? 0.0;
    if (audioLevel < 0.3) return phonemeToBlendshape['I'] ?? 0.3;
    if (audioLevel < 0.5) return phonemeToBlendshape['E'] ?? 0.5;
    if (audioLevel < 0.7) return phonemeToBlendshape['U'] ?? 0.4;
    if (audioLevel < 0.9) return phonemeToBlendshape['O'] ?? 0.6;
    return phonemeToBlendshape['A'] ?? 0.7;
  }
  
  // Método para generar comandos JavaScript para animar el modelo 3D
  String generateLipSyncCommand(double blendshapeValue) {
    // Esta función generará el comando JavaScript para manipular los morph targets del modelo
    return '''
      (function() {
        const model = document.querySelector('model-viewer');
        if (model && model.model) {
          // Acceder a los morph targets del modelo (si están disponibles)
          const morphTargets = model.model.morphTargetDictionary;
          if (morphTargets) {
            // Buscar morph targets relacionados con la boca
            const mouthTargets = ['mouthOpen', 'jawOpen', 'viseme_aa', 'viseme_oh'];
            mouthTargets.forEach(target => {
              const idx = morphTargets[target];
              if (idx !== undefined) {
                model.model.morphTargetInfluences[idx] = ${blendshapeValue};
              }
            });
          }
        }
      })();
    ''';
  }
}

class Avatar3DScreen extends StatefulWidget {
  const Avatar3DScreen({Key? key}) : super(key: key);

  @override
  State<Avatar3DScreen> createState() => _Avatar3DScreenState();
}

class _Avatar3DScreenState extends State<Avatar3DScreen> {
  final player = AudioPlayer();
  final lipSyncController = LipSyncController();
  bool isPlaying = false;
  String? currentAudioPath;
  double animationValue = 0.0;
  Timer? _timer;
  final random = Random();
  ModelViewer? modelViewer;
  String modelViewerHtml = '';

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
    _prepareModelViewerHtml();
  }

  void _prepareModelViewerHtml() {
    // Preparar HTML personalizado para el ModelViewer con soporte para JavaScript
    modelViewerHtml = '''
      <model-viewer id="avatar-model" 
        src="assets/avatar.glb" 
        alt="Avatar 3D" 
        camera-controls 
        auto-rotate="false" 
        ar="false"
        exposure="1"
        shadow-intensity="1"
        environment-image="neutral"
        style="width: 100%; height: 100%;">
      </model-viewer>
      <script>
        // Función para actualizar la animación facial
        function updateFacialAnimation(value) {
          const model = document.getElementById('avatar-model');
          if (model && model.model) {
            // Implementación específica para el modelo de Ready Player Me
            // Esto puede variar según la estructura del modelo
            try {
              // Buscar nodos relacionados con la boca
              const scene = model.model.scene;
              scene.traverse((node) => {
                if (node.name.includes('mouth') || node.name.includes('jaw') || 
                    node.name.includes('lip') || node.name.includes('viseme')) {
                  // Aplicar transformación basada en el valor de animación
                  if (node.morphTargetInfluences) {
                    for (let i = 0; i < node.morphTargetInfluences.length; i++) {
                      if (i === 0) { // Primer morph target (generalmente apertura de boca)
                        node.morphTargetInfluences[i] = value;
                      }
                    }
                  }
                }
              });
            } catch (e) {
              console.error('Error al animar el modelo:', e);
            }
          }
        }
      </script>
    ''';
  }

  void _setupAudioPlayer() {
    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          isPlaying = false;
          _stopLipSync();
        });
      }
    });
  }

  Future<void> _playAudio(String path) async {
    if (currentAudioPath == path && isPlaying) {
      await player.pause();
      setState(() {
        isPlaying = false;
        _stopLipSync();
      });
      return;
    }

    try {
      if (currentAudioPath != path) {
        await player.setAsset(path);
        currentAudioPath = path;
      }
      
      await player.play();
      setState(() {
        isPlaying = true;
        _startLipSync();
      });
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _startLipSync() {
    _stopLipSync(); // Ensure any existing timer is cancelled
    
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // Obtener nivel de audio o usar valores aleatorios para la demostración
      final newValue = random.nextDouble() * 0.8;
      
      setState(() {
        animationValue = newValue;
        
        // Aplicar animación facial al modelo 3D
        final blendshapeValue = lipSyncController.getBlendshapeValue(newValue);
        final jsCommand = lipSyncController.generateLipSyncCommand(blendshapeValue);
        
        // Ejecutar JavaScript en el ModelViewer (en una implementación real)
        // modelViewer?.executeJavaScript(jsCommand);
      });
    });
  }

  void _stopLipSync() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      animationValue = 0.0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar 3D con Lipsync'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black87,
              child: ModelViewer(
                backgroundColor: const Color.fromARGB(255, 30, 30, 50),
                src: 'assets/avatar.glb',
                alt: 'Avatar 3D',
                ar: false,
                autoRotate: false,
                cameraControls: true,
                autoPlay: true,
                // En una implementación completa, se usaría JavaScript para controlar
                // los morph targets del modelo basados en el audio
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[900],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nivel de animación: ${(animationValue * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: animationValue,
                    backgroundColor: Colors.grey[700],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.deepPurple.withOpacity(0.7 + animationValue * 0.3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _playAudio('assets/audio/sample1.mp3'),
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                        label: const Text('Reproducir Audio'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Aquí se implementaría la funcionalidad para grabar audio
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Función de grabación en desarrollo'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.mic),
                        label: const Text('Grabar Audio'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
