import 'package:flutter/material.dart';
import 'package:splitwise/themes/app_theme.dart';

class RoundedContainer extends StatelessWidget {
  const RoundedContainer(
      {super.key,
      this.height,
      this.text,
      this.circularProgressIndicator,
      this.width,
      this.fontsize,
      this.bold,
      this.color});
  final String? text;
  final bool? bold;
  final CircularProgressIndicator? circularProgressIndicator;
  final Color? color;
  final double? fontsize;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? MediaQuery.of(context).size.height * 0.10,
      width: width ?? MediaQuery.of(context).size.width * 0.8,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Material(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: color ?? AppTheme.backgroundContainer,
              borderRadius: const BorderRadius.all(
                Radius.circular(15),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.gradientContainerLeft,
                  AppTheme.gradientContainerRight,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                circularProgressIndicator ??
                    Text(
                      text!,
                      style: TextStyle(
                        fontSize: fontsize ?? 20,
                        fontFamily: 'Calibri',
                        fontWeight: bold == true ? FontWeight.bold : null,
                        color: Colors.white,
                      ),
                    ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
