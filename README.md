# Avatar Lip Sync 3D

Aplicación Flutter para sincronización labial de avatar 3D con audio en tiempo real.

![Avatar Lip Sync](docs/images/avatar_preview.png)

## Descripción

Esta aplicación permite sincronizar los movimientos labiales de un avatar 3D con audio en tiempo real o pregrabado. Utiliza técnicas avanzadas de análisis fonético, control facial y transiciones suaves para lograr una sincronización labial realista y natural.

## Características Principales

### 1. Análisis Fonético del Audio
- Detección de 25 fonemas mapeados a 15 visemas específicos
- Ajuste dinámico de intensidad según el nivel de audio
- Simulación de análisis espectral para determinar fonemas

### 2. Control Facial Avanzado
- Sistema de blendshapes para control preciso de expresiones faciales
- Parpadeo natural con timing variable y aleatorio
- Micro-expresiones faciales sincronizadas con el habla
- Movimientos coordinados de mandíbula, mejillas y lengua

### 3. Interpolación Suave entre Visemas
- Transiciones adaptativas según el contexto fonético
- Sistema de anticipación para movimientos más naturales
- Curvas de aceleración para animaciones orgánicas
- Proyección de tendencias basada en historial de visemas

## Requisitos

- Flutter 2.10.0 o superior
- Dart 2.16.0 o superior
- Dispositivo con soporte para renderizado 3D (OpenGL ES 3.0 o superior)
- Espacio de almacenamiento: 100MB mínimo

## Instalación

1. Clona este repositorio:
```bash
git clone https://github.com/webmasterscity/avatar_lip_sync.git
```

2. Navega al directorio del proyecto:
```bash
cd avatar_lip_sync
```

3. Instala las dependencias:
```bash
flutter pub get
```

4. Ejecuta la aplicación:
```bash
flutter run
```

## Uso

### Modo Básico
1. Inicia la aplicación
2. Selecciona un archivo de audio o utiliza el micrófono
3. Observa cómo el avatar mueve los labios sincronizados con el audio

### Modo Avanzado
1. Navega a la pantalla "Avatar 3D con Lipsync Avanzado"
2. Ajusta los parámetros de sincronización:
   - Duración de transición (50-200ms)
   - Factor de anticipación (0-50%)
3. Selecciona un archivo de audio o utiliza el micrófono
4. Observa la sincronización labial avanzada con transiciones suaves

## Personalización

### Avatar Personalizado
Puedes crear tu propio avatar 3D realista visitando [Ready Player Me](https://readyplayer.me):
1. Crea un avatar personalizado (con foto o manualmente)
2. Descarga el modelo en formato GLB
3. Reemplaza el archivo `assets/avatar.glb` en el proyecto

### Ajustes de Sincronización
Modifica los parámetros en `lib/controllers/advanced_lipsync_controller.dart`:
- `baseTransitionDuration`: Duración base de transición entre visemas
- `anticipationFactor`: Factor de anticipación para movimientos naturales
- Mapeo de fonemas a visemas en `PhoneticAnalyzer.phonemeToViseme`

## Arquitectura

La aplicación está estructurada en tres capas principales:

1. **Capa de UI**: Widgets y pantallas para la interfaz de usuario
   - `lib/screens/`: Pantallas principales
   - `lib/widgets/`: Componentes reutilizables

2. **Capa de Control**: Lógica de sincronización labial
   - `lib/controllers/phonetic_lipsync_controller.dart`: Análisis fonético básico
   - `lib/controllers/advanced_lipsync_controller.dart`: Interpolación y control avanzado

3. **Capa de Modelo**: Datos y estructuras
   - `lib/models/`: Definiciones de datos y estructuras

## Limitaciones Actuales

- La detección de fonemas es simulada; una implementación real requeriría análisis de audio avanzado
- No todos los modelos GLB tienen los mismos blendshapes, lo que puede afectar la calidad
- El rendimiento puede variar en dispositivos de gama baja
- La integración JavaScript para control de blendshapes puede tener limitaciones en algunas plataformas

## Próximos Pasos

- Implementar análisis de audio real con FFT
- Integrar modelo ML para detección precisa de fonemas
- Optimizar rendimiento con procesamiento en isolates
- Mejorar compatibilidad con diferentes estructuras de modelos 3D

## Documentación Adicional

- [Análisis Técnico de Mejoras](docs/ANALISIS_TECNICO_MEJORAS.md)
- [Mejoras de Lipsync Avanzado](docs/MEJORAS_LIPSYNC_AVANZADO.md)
- [Resultados de Pruebas](docs/RESULTADOS_PRUEBAS.md)

## Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## Créditos

- Avatar 3D: [Ready Player Me](https://readyplayer.me)
- Modelo de visemas: Basado en investigaciones de Disney y Carnegie Mellon University
- Implementación Flutter: Desarrollado por Manus Agent
