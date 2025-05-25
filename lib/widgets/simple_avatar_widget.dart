import 'package:flutter/material.dart';

class SimpleAvatarWidget extends StatelessWidget {
  final double animationValue;
  
  const SimpleAvatarWidget({
    Key? key,
    required this.animationValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Avatar Simple',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 40 + (animationValue * 20),
                  height: 20 + (animationValue * 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Intensidad: ${(animationValue * 100).toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
