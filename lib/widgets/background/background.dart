import 'dart:math';

import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  const Background({super.key});

  final boxDecoration = const BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [
        0.2,
        0.8
      ],
          colors: [
        Color(0xff2E305F),
        Color(0xff2E2333),
      ]));
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          decoration: boxDecoration,
        ),
        Positioned(
            top: size.height * 0.1,
            left: -size.width * 0.15,
            child: const _ColoredBox(size: 100, rotate: 5, circular: 20)),
        Positioned(
            top: size.height * 0.3,
            left: size.width * 0.7,
            child: const _ColoredBox(size: 180, rotate: 4, circular: 20)),
        Positioned(
            top: size.height * 0.7,
            left: size.width * 0.3,
            child: const _ColoredBox(size: 180, rotate: 3, circular: 20)),
        Positioned(
            top: size.height * 0.4,
            left: size.width * 0.3,
            child: const _ColoredBox(size: 100, rotate: 6, circular: 20)),
        Positioned(
            top: size.height * 0.05,
            left: size.width * 0.4,
            child: const _ColoredBox(size: 120, rotate: 3, circular: 20)),
        Positioned(
            top: size.height * 0.01,
            left: size.width * 0.1,
            child: const _ColoredBox(size: 50, rotate: 3, circular: 5)),
        Positioned(
            top: size.height * 0.5,
            left: size.width * 0.05,
            child: const _ColoredBox(size: 110, rotate: 3, circular: 15)),
        Positioned(
            top: size.height * 0.01,
            left: size.width * 0.8,
            child: const _ColoredBox(size: 90, rotate: 5, circular: 10)),
      ],
    );
  }
}

class _ColoredBox extends StatelessWidget {
  const _ColoredBox(
      {required this.size, required this.rotate, required this.circular});

  final double size;
  final double rotate;
  final double circular;
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -pi / rotate,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(circular),
            gradient: const LinearGradient(colors: [
              Color.fromRGBO(40, 32, 102, 0),
              Color.fromRGBO(39, 31, 133, 1)
            ])),
      ),
    );
  }
}
