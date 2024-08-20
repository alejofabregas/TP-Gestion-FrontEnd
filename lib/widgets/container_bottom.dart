import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class ContainerBottom extends StatelessWidget {
  const ContainerBottom({
    super.key,
    this.text,
  });
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.13,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 149, 147, 151),
              border: Border.all(
                color: Colors.deepPurple[300]!,
                width: 1,
              )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Total a pagar",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.letterColorRegistration,
                ),
              ),
              const Spacer(),
              Text(
                text!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.letterColorRegistration,
                ),
              ),
              const SizedBox(
                width: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
