import 'package:flutter/material.dart';

class BackgroundStart extends StatelessWidget {
  const BackgroundStart({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/home_screen.png',
          fit: BoxFit.cover,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 9, 107, 187).withOpacity(0.8),
                Colors.purple.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
