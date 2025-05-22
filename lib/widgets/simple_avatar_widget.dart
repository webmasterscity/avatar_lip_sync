import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// Widget personalizado que implementa un avatar simple con sincronización labial
/// utilizando animaciones de Rive generadas programáticamente
class SimpleAvatarWidget extends StatefulWidget {
  final double audioIntensity;
  final int visemeIndex;

  const SimpleAvatarWidget({
    Key? key,
    this.audioIntensity = 0.0,
    this.visemeIndex = 0,
  }) : super(key: key);

  @override
  State<SimpleAvatarWidget> createState() => _SimpleAvatarWidgetState();
}

class _SimpleAvatarWidgetState extends State<SimpleAvatarWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        painter: AvatarPainter(
          audioIntensity: widget.audioIntensity,
          visemeIndex: widget.visemeIndex,
        ),
      ),
    );
  }
}

/// CustomPainter que dibuja un avatar simple con diferentes posiciones de labios
/// basadas en la intensidad del audio y el índice de visema
class AvatarPainter extends CustomPainter {
  final double audioIntensity;
  final int visemeIndex;

  AvatarPainter({
    required this.audioIntensity,
    required this.visemeIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Dibujar cara
    final facePaint = Paint()
      ..color = Colors.yellow.shade200
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.9, facePaint);

    // Dibujar ojos
    final eyePaint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.fill;
    
    // Ojo izquierdo
    canvas.drawCircle(
      Offset(center.dx - radius * 0.3, center.dy - radius * 0.2),
      radius * 0.08,
      eyePaint,
    );
    
    // Ojo derecho
    canvas.drawCircle(
      Offset(center.dx + radius * 0.3, center.dy - radius * 0.2),
      radius * 0.08,
      eyePaint,
    );

    // Dibujar boca según el visema
    final mouthPaint = Paint()
      ..color = Colors.red.shade900
      ..style = PaintingStyle.fill;

    // Posición base de la boca
    final mouthTop = center.dy + radius * 0.2;
    final mouthLeft = center.dx - radius * 0.25;
    final mouthRight = center.dx + radius * 0.25;
    
    switch (visemeIndex) {
      case 0: // REST - Boca cerrada
        final mouthPath = Path()
          ..moveTo(mouthLeft, mouthTop)
          ..lineTo(mouthRight, mouthTop)
          ..lineTo(mouthRight, mouthTop + radius * 0.02)
          ..lineTo(mouthLeft, mouthTop + radius * 0.02)
          ..close();
        canvas.drawPath(mouthPath, mouthPaint);
        break;
        
      case 1: // A_VISEME - Boca muy abierta
        final mouthHeight = radius * 0.3 * audioIntensity;
        final mouthRect = Rect.fromLTRB(
          mouthLeft, 
          mouthTop, 
          mouthRight, 
          mouthTop + mouthHeight
        );
        canvas.drawOval(mouthRect, mouthPaint);
        
        // Interior de la boca
        final innerMouthPaint = Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.fill;
        final innerRect = Rect.fromLTRB(
          mouthLeft + radius * 0.05, 
          mouthTop + radius * 0.02, 
          mouthRight - radius * 0.05, 
          mouthTop + mouthHeight - radius * 0.02
        );
        canvas.drawOval(innerRect, innerMouthPaint);
        break;
        
      case 2: // E_VISEME - Boca estirada
        final mouthHeight = radius * 0.1 * audioIntensity;
        final mouthPath = Path()
          ..moveTo(mouthLeft - radius * 0.1, mouthTop)
          ..lineTo(mouthRight + radius * 0.1, mouthTop)
          ..lineTo(mouthRight, mouthTop + mouthHeight)
          ..lineTo(mouthLeft, mouthTop + mouthHeight)
          ..close();
        canvas.drawPath(mouthPath, mouthPaint);
        break;
        
      case 3: // I_VISEME - Boca estrecha
        final mouthHeight = radius * 0.1 * audioIntensity;
        final mouthWidth = radius * 0.2;
        final mouthRect = Rect.fromLTRB(
          center.dx - mouthWidth / 2, 
          mouthTop, 
          center.dx + mouthWidth / 2, 
          mouthTop + mouthHeight
        );
        canvas.drawOval(mouthRect, mouthPaint);
        break;
        
      case 4: // O_VISEME - Boca redondeada
        final mouthSize = radius * 0.2 * audioIntensity;
        final mouthRect = Rect.fromLTRB(
          center.dx - mouthSize, 
          mouthTop, 
          center.dx + mouthSize, 
          mouthTop + mouthSize
        );
        canvas.drawOval(mouthRect, mouthPaint);
        
        // Interior de la boca
        final innerMouthPaint = Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.fill;
        final innerSize = mouthSize * 0.7;
        final innerRect = Rect.fromLTRB(
          center.dx - innerSize, 
          mouthTop + (mouthSize - innerSize) / 2, 
          center.dx + innerSize, 
          mouthTop + (mouthSize + innerSize) / 2
        );
        canvas.drawOval(innerRect, innerMouthPaint);
        break;
        
      case 5: // U_VISEME - Labios proyectados
        final mouthSize = radius * 0.15 * audioIntensity;
        final mouthRect = Rect.fromLTRB(
          center.dx - mouthSize * 0.7, 
          mouthTop, 
          center.dx + mouthSize * 0.7, 
          mouthTop + mouthSize
        );
        canvas.drawOval(mouthRect, mouthPaint);
        
        // Interior de la boca
        final innerMouthPaint = Paint()
          ..color = Colors.black87
          ..style = PaintingStyle.fill;
        final innerSize = mouthSize * 0.5;
        final innerRect = Rect.fromLTRB(
          center.dx - innerSize * 0.7, 
          mouthTop + (mouthSize - innerSize) / 2, 
          center.dx + innerSize * 0.7, 
          mouthTop + (mouthSize + innerSize) / 2
        );
        canvas.drawOval(innerRect, innerMouthPaint);
        break;
        
      case 6: // CONSONANT - Posición para consonantes
        final mouthHeight = radius * 0.15 * audioIntensity;
        final mouthPath = Path()
          ..moveTo(mouthLeft, mouthTop)
          ..lineTo(mouthRight, mouthTop)
          ..lineTo(mouthRight - radius * 0.05, mouthTop + mouthHeight)
          ..lineTo(mouthLeft + radius * 0.05, mouthTop + mouthHeight)
          ..close();
        canvas.drawPath(mouthPath, mouthPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant AvatarPainter oldDelegate) {
    return oldDelegate.audioIntensity != audioIntensity || 
           oldDelegate.visemeIndex != visemeIndex;
  }
}
