import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/audio_controller.dart';
import '../widgets/simple_avatar_widget.dart';

class AvatarScreen extends StatelessWidget {
  const AvatarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar con Sincronización Labial'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AudioController>(
        builder: (context, audioController, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar con sincronización labial
                SimpleAvatarWidget(
                  audioIntensity: audioController.currentIntensity,
                  visemeIndex: audioController.currentViseme,
                ),
                
                const SizedBox(height: 30),
                
                // Información del audio actual
                if (audioController.currentAudioPath != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Audio: ${audioController.currentAudioPath!.split('/').last}',
                      style: const TextStyle(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                
                const SizedBox(height: 20),
                
                // Controles de audio
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: audioController.pickAndPlayAudio,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Seleccionar Audio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    
                    if (audioController.currentAudioPath != null) ...[
                      const SizedBox(width: 20),
                      IconButton(
                        onPressed: audioController.togglePlayback,
                        icon: Icon(
                          audioController.isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                        iconSize: 48,
                        color: Colors.blue,
                      ),
                      
                      const SizedBox(width: 20),
                      IconButton(
                        onPressed: audioController.stopPlayback,
                        icon: const Icon(Icons.stop),
                        iconSize: 48,
                        color: Colors.red,
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Indicador de intensidad
                if (audioController.isPlaying)
                  Column(
                    children: [
                      const Text(
                        'Intensidad del audio:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 300,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: audioController.currentIntensity,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
