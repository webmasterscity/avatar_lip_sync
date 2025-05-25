import 'package:flutter/material.dart';
import '../controllers/advanced_lipsync_controller.dart';
import '../widgets/facial_control_widget.dart';

class AdvancedAvatarScreen extends StatefulWidget {
  const AdvancedAvatarScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedAvatarScreen> createState() => _AdvancedAvatarScreenState();
}

class _AdvancedAvatarScreenState extends State<AdvancedAvatarScreen> {
  // Controlador avanzado de lipsync con interpolación
  late AdvancedLipSyncController _lipSyncController;
  
  // Estado de la UI
  bool _isPlaying = false;
  double _animationValue = 0.0;
  String _currentPhoneme = 'rest';
  String _currentViseme = 'viseme_rest';
  
  // Configuración de interpolación
  double _transitionDuration = 100.0;
  double _anticipationFactor = 0.2;
  
  @override
  void initState() {
    super.initState();
    
    // Inicializar controlador con configuración por defecto
    _lipSyncController = AdvancedLipSyncController(
      baseTransitionDuration: _transitionDuration,
      anticipationFactor: _anticipationFactor,
      transitionCurve: Curves.easeInOut,
    );
    
    // Suscribirse al stream de visemas interpolados
    _lipSyncController.interpolatedVisemeStream.listen(_handleVisemeUpdate);
  }
  
  @override
  void dispose() {
    _lipSyncController.dispose();
    super.dispose();
  }
  
  // Manejar actualización de visema
  void _handleVisemeUpdate(VisemeData visemeData) {
    setState(() {
      _animationValue = visemeData.intensity;
      _currentPhoneme = visemeData.phoneme;
      _currentViseme = visemeData.viseme;
    });
  }
  
  // Reproducir audio de muestra
  Future<void> _playAudio(String path) async {
    setState(() {
      _isPlaying = true;
    });
    
    await _lipSyncController.playAudio(path);
  }
  
  // Seleccionar y reproducir archivo de audio
  Future<void> _pickAndPlayAudio() async {
    try {
      // En una implementación real, usaríamos FilePicker
      // Para el prototipo, usamos un audio de muestra
      await _playAudio('assets/audio/sample1.mp3');
    } catch (e) {
      debugPrint('Error picking audio: $e');
      // Usar audio de muestra como fallback
      await _playAudio('assets/audio/sample1.mp3');
    }
  }
  
  // Actualizar configuración de interpolación
  void _updateInterpolationSettings() {
    // En una implementación real, recrearíamos el controlador
    // Para el prototipo, solo actualizamos el estado
    setState(() {
      // La configuración ya está actualizada en el estado
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar 3D con Lipsync Avanzado'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Avatar 3D con control facial
          Expanded(
            flex: 3,
            child: FacialControlWidget(
              modelPath: 'assets/avatar.glb',
              lipSyncController: _lipSyncController,
            ),
          ),
          
          // Panel de información y controles
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[900],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información de visema actual
                  Text(
                    'Fonema: $_currentPhoneme | Visema: $_currentViseme',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  
                  // Indicador de intensidad
                  Text(
                    'Intensidad: ${(_animationValue * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                  LinearProgressIndicator(
                    value: _animationValue,
                    backgroundColor: Colors.grey[700],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.deepPurple.withOpacity(0.7 + _animationValue * 0.3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Configuración de interpolación
                  Text(
                    'Duración de transición: ${_transitionDuration.toStringAsFixed(0)}ms',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Slider(
                    value: _transitionDuration,
                    min: 50,
                    max: 200,
                    divisions: 15,
                    label: _transitionDuration.toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() {
                        _transitionDuration = value;
                      });
                      _updateInterpolationSettings();
                    },
                  ),
                  
                  Text(
                    'Factor de anticipación: ${(_anticipationFactor * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Slider(
                    value: _anticipationFactor,
                    min: 0.0,
                    max: 0.5,
                    divisions: 10,
                    label: (_anticipationFactor * 100).toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() {
                        _anticipationFactor = value;
                      });
                      _updateInterpolationSettings();
                    },
                  ),
                  
                  // Controles de audio
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _playAudio('assets/audio/sample1.mp3'),
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                        label: const Text('Audio de Muestra'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _pickAndPlayAudio,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Seleccionar Audio'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
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
