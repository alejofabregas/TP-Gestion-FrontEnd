// import 'package:fiufit/widgets/container_transparente.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class ContainerForSearchTypes extends StatelessWidget {
  const ContainerForSearchTypes({
    super.key,
    required int currentPage,
    required this.searchTypes,
    required this.index,
  }) : _currentPage = currentPage;

  final int _currentPage;
  final List<String> searchTypes;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          height: 30,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: _currentPage == index
                  ? Colors.deepPurple[300]!
                  : Colors.transparent,
              width: 1,
            ),
            color: _currentPage == index
                ? AppTheme.backgroundContainer
                : Colors.transparent,
          ),
          child: Text(
            searchTypes[index],
            style: TextStyle(
              color: _currentPage == index
                  ? AppTheme.letterColorRegistration
                  : Colors.grey[800],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class ContainerTransparente extends StatelessWidget {
  const ContainerTransparente({
    super.key,
    required this.widget,
  });

  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(62, 66, 107, 0.7),
            border: Border.all(color: Colors.deepPurple, width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: widget,
        ),
      ),
    );
  }
}
