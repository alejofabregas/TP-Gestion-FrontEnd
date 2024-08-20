import 'dart:ui';
import 'package:flutter/material.dart';

class ContainerDeError extends StatefulWidget {
  const ContainerDeError({
    super.key,
    required this.error,
    required this.resolucion,
    this.function,
    this.error_message,
  });
  final String error;
  final String resolucion;
  final Function? function;
  final String? error_message;

  @override
  State<ContainerDeError> createState() => _ContainerDeErrorState();
}

class _ContainerDeErrorState extends State<ContainerDeError> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Center(
      child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                    height: size.height * 0.45,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.deepPurple, width: 1),
                        color: const Color.fromRGBO(62, 66, 107, 0.7),
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => widget.function != null
                                  ? widget.function!()
                                  : null,
                              child: const FadeInImage(
                                  height: 125,
                                  width: 125,
                                  placeholder:
                                      AssetImage('assets/jar-loading.gif'),
                                  image:
                                      AssetImage('assets/mono_cargando.jpg')),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              widget.error,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              widget.resolucion,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w300),
                            ),
                            if (widget.error_message != null)
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Error Message'),
                                          content: Text(widget.error_message!),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Close'),
                                            ),
                                          ],
                                        );
                                      });
                                },
                                child: const Text('Ver Error'),
                              ),
                          ]),
                    )),
              ))),
    );
  }
}
