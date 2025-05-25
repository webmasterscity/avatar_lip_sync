import 'package:flutter/material.dart';

/// Clase que define los diferentes visemas (posiciones de labios) para sincronización labial
class VisemeModel {
  static const String rest = 'viseme_rest';      // Posición neutral
  static const String aViseme = 'viseme_aa';     // Como en "padre"
  static const String eViseme = 'viseme_ee';     // Como en "mesa"
  static const String iViseme = 'viseme_ih';     // Como en "piso"
  static const String oViseme = 'viseme_oh';     // Como en "boca"
  static const String uViseme = 'viseme_ou';     // Como en "luna"
  static const String consonant = 'viseme_mb';   // Consonantes genéricas
  
  // Mapeo de fonemas a visemas (simplificado)
  static String getVisemeForPhoneme(String phoneme) {
    switch (phoneme.toUpperCase()) {
      case 'A': return aViseme;
      case 'E': return eViseme;
      case 'I': return iViseme;
      case 'O': return oViseme;
      case 'U': return uViseme;
      case 'B':
      case 'M':
      case 'P': return consonant;
      default: return rest;
    }
  }
  
  // Obtener intensidad recomendada para un visema
  static double getIntensityForViseme(String viseme) {
    switch (viseme) {
      case aViseme: return 0.8;  // Boca muy abierta
      case eViseme: return 0.6;  // Boca semi-abierta, labios estirados
      case iViseme: return 0.4;  // Boca pequeña, labios estirados
      case oViseme: return 0.7;  // Labios redondeados
      case uViseme: return 0.5;  // Labios adelantados, redondeados
      case consonant: return 0.3; // Labios cerrados o casi cerrados
      default: return 0.0;       // Posición neutral
    }
  }
}
