import 'package:flutter/material.dart';
import 'dart:async';
import '../controllers/phonetic_lipsync_controller.dart';
import '../models/viseme_data.dart';

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

class _FacialControlWidgetState extends State<FacialControlWidget> with SingleTickerProviderStateMixin {
  // Estado de animación
  late AnimationController _animationController;
  double _mouthOpenValue = 0.0;
  double _smileValue = 0.0;
  double _eyeBlinkValue = 0.0;
  
  // Estado de visema
  String _currentViseme = 'viseme_rest';
  double _visemeIntensity = 0.0;
  
  // Características faciales
  final Map<String, double> _facialFeatures = {
    'eyeBlink': 0.0,
    'mouthOpen': 0.0,
    'smile': 0.0,
    'browRaise': 0.0,
    'jawOpen': 0.0,
  };
  
  // Timer para parpadeo
  Timer? _blinkTimer;
  
  @override
  void initState() {
    super.initState();
    
    // Inicializar controlador de animación
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    // Suscribirse al stream de visemas
    widget.lipSyncController.visemeStream.listen(_handleVisemeUpdate);
    
    // Iniciar parpadeo aleatorio
    _startRandomBlinking();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _blinkTimer?.cancel();
    super.dispose();
  }
  
  // Manejar actualización de visema
  void _handleVisemeUpdate(VisemeData visemeData) {
    setState(() {
      _currentViseme = visemeData.viseme;
      _visemeIntensity = visemeData.intensity;
      
      // Actualizar valores de animación según el visema
      _updateAnimationValues(visemeData);
    });
    
    // Aplicar visema al modelo 3D
    _applyVisemeToModel(visemeData);
  }
  
  // Actualizar valores de animación según el visema
  void _updateAnimationValues(VisemeData visemeData) {
    switch (visemeData.viseme) {
      case 'viseme_aa': // A
        _mouthOpenValue = 0.8 * visemeData.intensity;
        _smileValue = 0.2 * visemeData.intensity;
        break;
      case 'viseme_ee': // E
        _mouthOpenValue = 0.5 * visemeData.intensity;
        _smileValue = 0.7 * visemeData.intensity;
        break;
      case 'viseme_ih': // I
        _mouthOpenValue = 0.3 * visemeData.intensity;
        _smileValue = 0.8 * visemeData.intensity;
        break;
      case 'viseme_oh': // O
        _mouthOpenValue = 0.7 * visemeData.intensity;
        _smileValue = 0.1 * visemeData.intensity;
        break;
      case 'viseme_ou': // U
        _mouthOpenValue = 0.4 * visemeData.intensity;
        _smileValue = 0.0;
        break;
      case 'viseme_mb': // Consonantes
        _mouthOpenValue = 0.1 * visemeData.intensity;
        _smileValue = 0.3 * visemeData.intensity;
        break;
      default: // Reposo
        _mouthOpenValue = 0.0;
        _smileValue = 0.1;
        break;
    }
  }
  
  // Aplicar visema al modelo 3D
  void _applyVisemeToModel(VisemeData visemeData) {
    // En una implementación real, esto se ejecutaría en el ModelViewer
    // Para el prototipo, solo actualizamos el estado
    debugPrint('Aplicando visema: ${visemeData.viseme} con intensidad ${visemeData.intensity}');
  }
  
  // Iniciar parpadeo aleatorio
  void _startRandomBlinking() {
    // Cancelar timer existente si hay
    _blinkTimer?.cancel();
    
    // Crear nuevo timer con intervalo aleatorio
    final randomInterval = 1000 + (DateTime.now().millisecondsSinceEpoch % 4000);
    _blinkTimer = Timer.periodic(Duration(milliseconds: randomInterval), (timer) {
      // Realizar parpadeo
      _blink();
      
      // Cambiar intervalo para próximo parpadeo
      timer.cancel();
      _startRandomBlinking();
    });
  }
  
  // Realizar parpadeo
  void _blink() {
    // Cerrar ojos
    setState(() {
      _eyeBlinkValue = 1.0;
    });
    
    // Abrir ojos después de un breve momento
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _eyeBlinkValue = 0.0;
        });
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Stack(
        children: [
          // Modelo 3D (simulado para el prototipo)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cara simulada
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    children: [
                      // Ojos
                      Positioned(
                        top: 60,
                        left: 50,
                        child: _buildEye(),
                      ),
                      Positioned(
                        top: 60,
                        right: 50,
                        child: _buildEye(),
                      ),
                      
                      // Boca
                      Positioned(
                        bottom: 60,
                        left: 0,
                        right: 0,
                        child: _buildMouth(),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Información de visema
                Text(
                  'Visema: $_currentViseme',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Intensidad: ${(_visemeIntensity * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Overlay de información
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Modelo 3D simulado',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Construir ojo
  Widget _buildEye() {
    return Container(
      width: 30,
      height: 30 * (1.0 - _eyeBlinkValue),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 10 * (1.0 - _eyeBlinkValue),
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
  
  // Construir boca
  Widget _buildMouth() {
    return Center(
      child: Container(
        width: 80 + (_smileValue * 20),
        height: 20 + (_mouthOpenValue * 40),
        decoration: BoxDecoration(
          color: Colors.red.shade900,
          borderRadius: BorderRadius.circular(
            10 + (_smileValue * 20),
          ),
        ),
      ),
    );
  }
}
