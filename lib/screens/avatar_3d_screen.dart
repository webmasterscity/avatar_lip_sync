import 'package:flutter/material.dart';
import '../models/viseme_data.dart';
import '../controllers/phonetic_lipsync_controller.dart';

class Avatar3DScreen extends StatefulWidget {
  const Avatar3DScreen({Key? key}) : super(key: key);

  @override
  State<Avatar3DScreen> createState() => _Avatar3DScreenState();
}

class _Avatar3DScreenState extends State<Avatar3DScreen> {
  // Controlador para sincronización labial
  late PhoneticLipSyncController _lipSyncController;
  
  // Estado de la UI
  bool _isPlaying = false;
  double _animationValue = 0.0;
  String _currentPhoneme = 'rest';
  String _currentViseme = 'viseme_rest';
  
  @override
  void initState() {
    super.initState();
    
    // Inicializar controlador
    _lipSyncController = PhoneticLipSyncController();
    
    // Suscribirse al stream de visemas
    _lipSyncController.visemeStream.listen(_handleVisemeUpdate);
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
    
    // Aplicar visema al modelo 3D
    _applyVisemeToModel(visemeData);
  }
  
  // Aplicar visema al modelo 3D
  void _applyVisemeToModel(VisemeData visemeData) {
    // Generar comando JavaScript para animar el modelo
    final jsCommand = _lipSyncController.generateLipSyncCommand(visemeData);
    
    // En una implementación real, esto se ejecutaría en el ModelViewer
    // Para el prototipo, solo imprimimos el comando
    debugPrint('Aplicando visema: ${visemeData.viseme}');
  }
  
  // Reproducir audio de muestra
  Future<void> _playAudio(String path) async {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    
    if (_isPlaying) {
      await _lipSyncController.playAudio(path);
    } else {
      await _lipSyncController.pauseAudio();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar 3D con Lipsync'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Avatar 3D
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black87,
              child: ModelViewer(
                src: 'assets/avatar.glb',
                alt: 'Avatar 3D',
                ar: false,
                autoRotate: false,
                cameraControls: true,
                backgroundColor: const Color.fromARGB(0xFF, 0x18, 0x18, 0x18),
              ),
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
                  
                  // Controles de audio
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

// Clase ModelViewer simulada para el prototipo
class ModelViewer extends StatelessWidget {
  final String src;
  final String alt;
  final bool ar;
  final bool autoRotate;
  final bool cameraControls;
  final Color backgroundColor;

  const ModelViewer({
    Key? key,
    required this.src,
    required this.alt,
    this.ar = false,
    this.autoRotate = false,
    this.cameraControls = true,
    this.backgroundColor = Colors.transparent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.face,
            size: 100,
            color: Colors.white70,
          ),
          const SizedBox(height: 20),
          Text(
            'Modelo 3D: $alt',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            'Fuente: $src',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 20),
          const Text(
            'Simulación de ModelViewer para prototipo',
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
