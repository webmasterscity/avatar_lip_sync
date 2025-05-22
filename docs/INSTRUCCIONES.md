# Instrucciones para la App de Sincronización Labial de Avatar

Esta aplicación Flutter permite cargar un archivo de audio y visualizar un avatar que sincroniza los movimientos de sus labios con el sonido. A continuación, encontrarás instrucciones detalladas para ejecutar y probar la aplicación.

## Requisitos Previos

Para ejecutar esta aplicación, necesitarás:

1. **Flutter SDK** instalado (versión 3.0.0 o superior)
2. **Dart SDK** (incluido con Flutter)
3. Un entorno de desarrollo compatible:
   - Android Studio, VS Code o IntelliJ IDEA
   - Xcode (solo para macOS/iOS)

## Configuración del Entorno

1. **Verifica tu instalación de Flutter**:
   ```bash
   flutter doctor
   ```
   Asegúrate de que no haya problemas críticos en la salida.

2. **Plataformas Soportadas**:
   - Android
   - iOS
   - Windows
   - macOS
   - Linux (requiere dependencias adicionales)
   - Web (funcionalidad limitada)

## Ejecución de la Aplicación

### Opción 1: Desde un IDE

1. Abre el proyecto en tu IDE preferido (Android Studio, VS Code, etc.)
2. Selecciona un dispositivo o emulador
3. Presiona el botón "Run" o "Debug"

### Opción 2: Desde la Línea de Comandos

1. Navega al directorio raíz del proyecto:
   ```bash
   cd ruta/a/lip_sync_avatar
   ```

2. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

3. Si tienes múltiples dispositivos conectados, especifica uno:
   ```bash
   flutter run -d [id-del-dispositivo]
   ```

## Uso de la Aplicación

1. **Selección de Audio**:
   - Al iniciar la aplicación, verás un avatar con la boca cerrada
   - Presiona el botón "Seleccionar Audio" para elegir un archivo de audio de tu dispositivo
   - Formatos soportados: MP3, WAV, AAC

2. **Reproducción y Control**:
   - Una vez seleccionado el audio, comenzará a reproducirse automáticamente
   - El avatar sincronizará los movimientos de sus labios con el audio
   - Usa los botones de reproducción/pausa y detener para controlar la reproducción
   - El indicador de intensidad muestra la fuerza del audio en tiempo real

3. **Observación de la Sincronización**:
   - Observa cómo el avatar cambia entre diferentes posiciones de labios (visemas)
   - La sincronización se basa en la intensidad del audio
   - En esta versión, se utiliza una simulación de intensidad para demostrar la funcionalidad

## Notas para Desarrolladores

### Estructura del Proyecto

```
lib/
├── main.dart                  # Punto de entrada de la aplicación
├── screens/
│   └── avatar_screen.dart     # Pantalla principal con el avatar
├── widgets/
│   └── simple_avatar_widget.dart # Widget del avatar con visemas
├── controllers/
│   └── audio_controller.dart  # Control de reproducción y análisis de audio
└── models/
    └── viseme_model.dart      # Modelo para mapeo de audio a visemas
```

### Personalización

1. **Modificar el Avatar**:
   - Edita `simple_avatar_widget.dart` para cambiar la apariencia del avatar
   - Puedes ajustar colores, formas y tamaños

2. **Mejorar la Sincronización**:
   - Para una sincronización más precisa, implementa un análisis de frecuencia real
   - Modifica `audio_controller.dart` para usar FFT (Transformada Rápida de Fourier)
   - Considera usar el paquete `flutter_fft` para análisis de audio avanzado

3. **Añadir Nuevos Visemas**:
   - Expande `viseme_model.dart` para incluir más posiciones de labios
   - Mejora el mapeo entre fonemas y visemas para mayor precisión

## Solución de Problemas

1. **Problemas de Permisos**:
   - En dispositivos móviles, asegúrate de conceder permisos de almacenamiento y micrófono
   - En macOS/iOS, verifica los permisos en Info.plist

2. **Errores de Compilación**:
   - Ejecuta `flutter clean` seguido de `flutter pub get`
   - Verifica que todas las dependencias estén actualizadas

3. **Problemas de Rendimiento**:
   - Si la animación no es fluida, considera reducir la frecuencia de actualización
   - Modifica el intervalo en `_startIntensitySimulation()` en `audio_controller.dart`

## Requisitos Específicos por Plataforma

### Linux
Para ejecutar en Linux, necesitarás instalar dependencias adicionales:
```bash
sudo apt-get install cmake ninja-build pkg-config libgtk-3-dev clang
```

### Windows
No se requieren configuraciones adicionales.

### macOS
Asegúrate de tener Xcode instalado y configurado.

### Android
Configura un dispositivo físico o emulador.

### iOS
Requiere un Mac con Xcode y un dispositivo o simulador iOS.

## Limitaciones Actuales

1. La sincronización se basa principalmente en la intensidad del audio, no en el reconocimiento de fonemas
2. No hay persistencia de archivos de audio entre sesiones
3. La interfaz de usuario es básica y funcional, diseñada para demostrar la sincronización labial

## Próximos Pasos

Para mejorar esta aplicación, considera:

1. Implementar detección de fonemas para una sincronización más precisa
2. Añadir más expresiones faciales y animaciones
3. Permitir la personalización del avatar
4. Mejorar la interfaz de usuario con temas y animaciones
5. Añadir soporte para streaming de audio
