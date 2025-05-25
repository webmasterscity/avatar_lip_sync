import 'package:flutter/material.dart';

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
