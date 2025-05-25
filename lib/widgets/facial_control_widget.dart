import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../controllers/phonetic_lipsync_controller.dart';

/// Widget para controlar las expresiones faciales y blendshapes del avatar 3D
class FacialControlWidget extends StatefulWidget {
  final String modelPath;
  final PhoneticLipSyncController lipSyncController;

  const FacialControlWidget({
    Key? key,
    required this.modelPath,
    required this.lipSyncController,
  }) : super(key: key);

  @override
  State<FacialControlWidget> createState() => _FacialControlWidgetState();
}

class _FacialControlWidgetState extends State<FacialControlWidget> {
  // Controlador para el ModelViewer
  dynamic _modelViewer;
  
  // Estado de las expresiones faciales
  double _blinkRate = 0.1; // Frecuencia de parpadeo (0-1)
  double _eyeOpenness = 1.0; // Apertura de ojos (0-1)
  double _browRaise = 0.0; // Elevación de cejas (0-1)
  double _jawOffset = 0.0; // Desplazamiento de mandíbula (0-1)
  
  // Temporizadores para animaciones automáticas
  Timer? _blinkTimer;
  Timer? _microExpressionsTimer;
  
  // Mapa de blendshapes disponibles en el modelo (para referencia)
  final Map<String, List<String>> _facialFeatures = {
    'Ojos': [
      'eyeBlinkLeft',
      'eyeBlinkRight',
      'eyeSquintLeft',
      'eyeSquintRight',
      'eyeWideLeft',
      'eyeWideRight'
    ],
    'Cejas': [
      'browDownLeft',
      'browDownRight',
      'browInnerUp',
      'browOuterUpLeft',
      'browOuterUpRight'
    ],
    'Boca': [
      'jawOpen',
      'jawForward',
      'jawLeft',
      'jawRight',
      'mouthClose',
      'mouthDimpleLeft',
      'mouthDimpleRight',
      'mouthFrownLeft',
      'mouthFrownRight',
      'mouthFunnel',
      'mouthLeft',
      'mouthLowerDownLeft',
      'mouthLowerDownRight',
      'mouthOpen',
      'mouthPucker',
      'mouthRight',
      'mouthRollLower',
      'mouthRollUpper',
      'mouthShrugLower',
      'mouthShrugUpper',
      'mouthSmileLeft',
      'mouthSmileRight',
      'mouthStretchLeft',
      'mouthStretchRight',
      'mouthUpperUpLeft',
      'mouthUpperUpRight',
      'mouthPress',
      'mouthPressLeft',
      'mouthPressRight'
    ],
    'Mejillas': [
      'cheekPuff',
      'cheekSquintLeft',
      'cheekSquintRight'
    ],
    'Nariz': [
      'noseSneerLeft',
      'noseSneerRight'
    ],
    'Lengua': [
      'tongueOut'
    ]
  };

  @override
  void initState() {
    super.initState();
    // Iniciar animaciones automáticas
    _startBlinking();
    _startMicroExpressions();
    
    // Suscribirse al stream de visemas
    widget.lipSyncController.visemeStream.listen(_handleVisemeUpdate);
  }
  
  @override
  void dispose() {
    _blinkTimer?.cancel();
    _microExpressionsTimer?.cancel();
    super.dispose();
  }
  
  // Iniciar parpadeo automático
  void _startBlinking() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // Calcular ciclo de parpadeo
      final blinkInterval = 2000 + (10000 * (1 - _blinkRate)); // 2-12 segundos
      final blinkDuration = 200; // 200ms para un parpadeo
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final cyclePosition = now % blinkInterval;
      
      // Determinar si estamos en un parpadeo
      if (cyclePosition < blinkDuration) {
        // Calcular la posición en el parpadeo (0-1)
        final blinkPosition = cyclePosition / blinkDuration;
        
        // Parábola para simular parpadeo natural (rápido al cerrar, más lento al abrir)
        double eyeOpen;
        if (blinkPosition < 0.5) {
          // Cerrar ojo (más rápido)
          eyeOpen = 1.0 - (blinkPosition * 2);
        } else {
          // Abrir ojo (más lento)
          eyeOpen = (blinkPosition - 0.5) * 2;
        }
        
        // Aplicar apertura de ojo
        setState(() {
          _eyeOpenness = eyeOpen * _eyeOpenness;
        });
        
        // Aplicar blendshapes de parpadeo
        _applyBlendshape('eyeBlinkLeft', 1.0 - _eyeOpenness);
        _applyBlendshape('eyeBlinkRight', 1.0 - _eyeOpenness);
      } else {
        // Fuera del parpadeo, ojos abiertos
        setState(() {
          _eyeOpenness = 1.0;
        });
        
        // Resetear blendshapes de parpadeo
        _applyBlendshape('eyeBlinkLeft', 0.0);
        _applyBlendshape('eyeBlinkRight', 0.0);
      }
    });
  }
  
  // Iniciar micro-expresiones aleatorias
  void _startMicroExpressions() {
    _microExpressionsTimer?.cancel();
    _microExpressionsTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      // Aplicar micro-expresiones sutiles aleatorias
      if (widget.lipSyncController.isPlaying) {
        // Durante el habla, añadir movimientos sutiles de cejas
        final random = DateTime.now().millisecondsSinceEpoch / 1000;
        final browMovement = (math.sin(random) * 0.2) + 0.1; // Valor entre 0.1 y 0.3
        
        setState(() {
          _browRaise = browMovement;
        });
        
        // Aplicar elevación de cejas
        _applyBlendshape('browInnerUp', _browRaise);
        
        // Movimiento sutil de mandíbula
        final jawMovement = (math.sin(random * 1.3) * 0.15) + 0.05; // Valor entre 0.05 y 0.2
        setState(() {
          _jawOffset = jawMovement;
        });
        
        // No aplicar directamente, se combinará con visemas
      } else {
        // En reposo, expresiones más sutiles
        setState(() {
          _browRaise = 0.0;
          _jawOffset = 0.0;
        });
        
        // Resetear blendshapes
        _applyBlendshape('browInnerUp', 0.0);
      }
    });
  }
  
  // Manejar actualizaciones de visemas
  void _handleVisemeUpdate(VisemeData visemeData) {
    // Combinar visema con expresiones faciales
    _applyVisemeWithExpressions(visemeData);
  }
  
  // Aplicar visema combinado con expresiones faciales
  void _applyVisemeWithExpressions(VisemeData visemeData) {
    // Obtener comando JavaScript para el visema
    final lipSyncCommand = widget.lipSyncController.generateLipSyncCommand(visemeData);
    
    // Ejecutar comando en el ModelViewer
    _executeJavaScript(lipSyncCommand);
    
    // Añadir movimientos de mandíbula basados en intensidad del visema
    final jawIntensity = visemeData.intensity * 0.7 + _jawOffset;
    _applyBlendshape('jawOpen', jawIntensity);
    
    // Añadir movimientos sutiles de mejillas para visemas específicos
    if (visemeData.viseme == 'viseme_oh' || visemeData.viseme == 'viseme_ou') {
      _applyBlendshape('cheekPuff', visemeData.intensity * 0.3);
    }
    
    // Añadir movimientos de lengua para visemas específicos
    if (visemeData.viseme == 'viseme_th' || visemeData.viseme == 'viseme_dd') {
      _applyBlendshape('tongueOut', visemeData.intensity * 0.2);
    }
  }
  
  // Aplicar un blendshape específico
  void _applyBlendshape(String blendshapeName, double value) {
    final command = '''
      (function() {
        const model = document.querySelector('model-viewer');
        if (model && model.model) {
          const morphTargets = model.model.morphTargetDictionary;
          if (morphTargets) {
            const idx = morphTargets['$blendshapeName'];
            if (idx !== undefined) {
              model.model.morphTargetInfluences[idx] = $value;
            }
          }
        }
      })();
    ''';
    
    _executeJavaScript(command);
  }
  
  // Ejecutar JavaScript en el ModelViewer
  void _executeJavaScript(String script) {
    // En una implementación real, esto ejecutaría JavaScript en el ModelViewer
    // Para el prototipo, solo imprimimos el script
    debugPrint('Executing JS: ${script.substring(0, min(50, script.length))}...');
    
    // Si el ModelViewer está disponible, ejecutar el script
    if (_modelViewer != null) {
      // Aquí iría la implementación real
      // _modelViewer.executeJavaScript(script);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black87,
            child: Center(
              child: Text(
                'Avatar 3D con Lipsync Avanzado',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ),
        // Controles de depuración para expresiones faciales (opcional)
        if (false) // Desactivado en producción
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[900],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Frecuencia de parpadeo: ${(_blinkRate * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white)),
                Slider(
                  value: _blinkRate,
                  onChanged: (value) {
                    setState(() {
                      _blinkRate = value;
                    });
                    _startBlinking(); // Reiniciar con nueva frecuencia
                  },
                  min: 0.0,
                  max: 1.0,
                ),
                Text('Elevación de cejas: ${(_browRaise * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white)),
                Slider(
                  value: _browRaise,
                  onChanged: (value) {
                    setState(() {
                      _browRaise = value;
                    });
                    _applyBlendshape('browInnerUp', _browRaise);
                  },
                  min: 0.0,
                  max: 1.0,
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  // Función auxiliar para limitar la longitud de cadenas
  int min(int a, int b) => a < b ? a : b;
}

// Clase Timer simulada para pruebas
class Timer {
  final Duration duration;
  final Function(Timer) callback;
  
  Timer.periodic(this.duration, this.callback);
  
  void cancel() {
    // Simulación
  }
}
