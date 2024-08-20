import 'package:flutter/material.dart';
import 'package:splitwise/services/backend_service.dart';

import '../providers/providers.dart';

class AbandonGroup extends StatelessWidget {
  const AbandonGroup({
    super.key,
    required this.backendService,
    required this.groupData,
    required this.profileProvider,
  });

  final BackendService backendService;
  final Map<String, dynamic> groupData;
  final ProfileProvider profileProvider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              return AlertDialog(
                elevation: 40,
                title: const Text("Salir del Grupo"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.circular(15)),
                content: const Text("¿Estas seguro de salir del grupo?"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancelar',
                          style: TextStyle(color: Colors.blue))),
                  TextButton(
                      onPressed: () async {
                        final response =
                            await backendService.removeUserFromGroup(
                                groupData["id"], profileProvider.profile!.uid);
                        if (response.statusCode != 200) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                'Hubo un error al salir al usuario del grupo'),
                          ));
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Aceptar',
                        style: TextStyle(color: Colors.red),
                      )),
                ],
              );
            });
      },
      child: Material(
        color: Colors.transparent,
        elevation: 8,
        child: Container(
          height: 45,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 144, 40, 33),
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          child: const Center(
              child: Text('Abandonar Grupo',
                  style: TextStyle(color: Colors.white, fontSize: 16))),
        ),
      ),
    );
  }
}
