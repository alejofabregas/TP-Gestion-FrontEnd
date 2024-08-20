import 'package:flutter/material.dart';

class BackgroundExpense extends StatelessWidget {
  const BackgroundExpense({super.key});

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
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color.fromARGB(255, 9, 107, 187),
                const Color.fromARGB(255, 255, 255, 255),
                const Color.fromARGB(255, 255, 255, 255),
                const Color.fromARGB(255, 255, 255, 255),
              ],
              stops: [
                0.0,
                0.25,
                0.75,
                1.0
              ], // Define where each color starts. Here, white color starts at 0.0 and ends at 0.75, then blue color starts.
            ),
          ),
        ),
      ],
    );
  }
}
