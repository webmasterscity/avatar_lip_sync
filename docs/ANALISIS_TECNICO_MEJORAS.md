# Análisis de Requerimientos Técnicos para Mejoras de Lipsync

## 1. Análisis Fonético del Audio

### Bibliotecas y Tecnologías Recomendadas
- **flutter_tflite**: Para integrar modelos de TensorFlow Lite de reconocimiento de fonemas
- **flutter_fft**: Para análisis de frecuencia del audio en tiempo real
- **speech_to_text**: Para transcripción y análisis fonético básico
- **just_audio**: Ya implementado, para reproducción y análisis de audio

### Mapeo de Fonemas a Visemas
Necesitamos implementar un mapa completo de fonemas a visemas:

| Fonema | Visema | Descripción |
|--------|--------|-------------|
| A, AH, AW | viseme_aa | Boca abierta, labios relajados |
| B, M, P | viseme_mb | Labios cerrados |
| CH, J, SH | viseme_ch | Labios adelantados, ligeramente abiertos |
| D, L, N, T | viseme_dd | Punta de lengua tocando paladar |
| E, EH | viseme_ee | Boca semi-abierta, labios estirados |
| F, V | viseme_ff | Labio inferior tocando dientes superiores |
| G, K, NG | viseme_kk | Parte posterior de lengua elevada |
| I, IY | viseme_ih | Boca pequeña, labios estirados |
| O, OW | viseme_oh | Labios redondeados, boca ovalada |
| R, ER | viseme_rr | Labios ligeramente adelantados |
| S, Z | viseme_ss | Dientes casi cerrados, labios estirados |
| TH | viseme_th | Lengua entre dientes |
| U, UW | viseme_ou | Labios adelantados, redondeados |
| W | viseme_wq | Labios muy redondeados |
| Y | viseme_y | Boca pequeña, labios estirados |

### Procesamiento de Audio
1. Capturar buffer de audio en tiempo real
2. Aplicar FFT para análisis espectral
3. Extraer características relevantes para identificación de fonemas
4. Utilizar modelo pre-entrenado para clasificación de fonemas
5. Mapear fonemas identificados a visemas correspondientes

## 2. Mejora de Blendshapes y Control Facial

### Acceso a Blendshapes del Modelo GLB
- Investigar la estructura interna del modelo GLB de Ready Player Me
- Identificar los nombres de los morph targets disponibles
- Implementar acceso directo a estos morph targets mediante JavaScript

### Ampliación de Expresiones Faciales
- Añadir control de cejas para expresividad
- Implementar movimientos sutiles de mejillas
- Añadir control de párpados para parpadeo natural
- Incorporar movimientos de mandíbula sincronizados

### Integración con model_viewer_plus
- Extender la funcionalidad actual para permitir control más granular
- Implementar inyección de JavaScript para manipulación avanzada del modelo
- Crear una capa de abstracción para simplificar el control de expresiones

## 3. Interpolación Suave entre Visemas

### Algoritmo de Interpolación
- Implementar curvas Bezier para transiciones suaves
- Ajustar velocidad de transición según contexto fonético
- Añadir inercia y anticipación en movimientos labiales

### Parámetros de Control
- Duración base de transición: 50-150ms (ajustable)
- Curva de aceleración/desaceleración personalizable
- Factor de anticipación: 0.1-0.3 (para movimientos naturales)

### Optimización de Rendimiento
- Implementar caché de transiciones comunes
- Procesar cálculos de interpolación en un isolate separado
- Reducir carga de renderizado mediante priorización de blendshapes visibles

## Limitaciones Técnicas y Consideraciones

1. **Acceso a Blendshapes**: El control directo de blendshapes desde Flutter es limitado, requiere JavaScript
2. **Rendimiento**: El análisis fonético en tiempo real puede ser intensivo en CPU
3. **Compatibilidad**: No todos los modelos GLB tienen los mismos morph targets
4. **Precisión**: La detección de fonemas puede variar según calidad del audio y acento

## Dependencias Adicionales Requeridas

```yaml
dependencies:
  flutter:
    sdk: flutter
  model_viewer_plus: ^1.5.0
  just_audio: ^0.9.34
  flutter_fft: ^1.0.2
  speech_to_text: ^6.1.1
  flutter_tflite: ^1.0.4
  bezier: ^1.2.0
  isolate: ^2.1.1
```

## Próximos Pasos

1. Implementar prototipo de análisis fonético básico
2. Crear mapa de prueba de fonemas a visemas
3. Desarrollar sistema de interpolación entre visemas
4. Integrar los componentes en un controlador unificado
5. Probar con diferentes muestras de audio y ajustar parámetros
