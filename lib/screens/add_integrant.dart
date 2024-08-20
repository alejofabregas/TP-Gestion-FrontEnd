import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitwise/providers/profile_provider.dart';
import 'package:splitwise/screens/display_group.dart';
import 'package:splitwise/services/backend_response.dart';
import 'package:splitwise/services/services.dart';

import '../services/firebase_service.dart';
import '../widgets/widgets.dart';
// import 'package:provider/provider.dart';

class AddIntegrantScreen extends StatelessWidget {
  const AddIntegrantScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as List<Object?>;
    final BackendService backendService =
        Provider.of<BackendService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Integrante'),
        centerTitle: true,
      ),
      body: AddIntegrant(
          profileProvider: arguments[0] as ProfileProvider,
          groupId: arguments[1] as int,
          backendService: backendService),
    );
  }
}

bool checkIfTheresMatch(userId, searchSnapshot) {
  return (searchSnapshot!.statusCode == 404 ||
      (searchSnapshot!.body.length == 1 &&
          userId == searchSnapshot!.body[0]['id']));
}

class AddIntegrant extends StatefulWidget {
  const AddIntegrant(
      {super.key,
      required this.profileProvider,
      required this.backendService,
      required this.groupId});

  final BackendService backendService;
  final ProfileProvider profileProvider;
  final int groupId;
  @override
  State<AddIntegrant> createState() => _AddIntegrantState();
}

class _AddIntegrantState extends State<AddIntegrant> {
  final TextEditingController _searchController = TextEditingController();

  BackendResponse? searchSnapshot;
  initiateSearch() {
    widget.backendService
        .getMatchingUsernameOrEmail(_searchController.text)
        .then((value) => setState(() {
              setState(() {
                searchSnapshot = value;
              });
            }));
  }

  Widget _searchList() {
    if (searchSnapshot == null) {
      return Container();
    }
    if (checkIfTheresMatch(
        widget.profileProvider.profile!.uid, searchSnapshot)) {
      return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Icon(
              Icons.search,
              size: 100,
              color: const Color.fromARGB(255, 15, 15, 15).withOpacity(0.4),
            ),
            Text('No se encontraron resultados para ${_searchController.text}',
                style: TextStyle(
                    color: const Color.fromARGB(255, 3, 3, 3).withOpacity(0.4)))
          ]));
    }
    if (searchSnapshot!.statusCode != 200) {
      return Center(
        child: ContainerDeError(
          error: "Hubo un error recopilando los datos de los usuarios",
          resolucion: "Trata de recargar la pagina",
          error_message: searchSnapshot!.errorMessage,
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (_, i) {
        return widget.profileProvider.profile!.uid !=
                searchSnapshot!.body[i]['id']
            ? ListMessageName(
                email: searchSnapshot!.body[i]['email'],
                username: searchSnapshot!.body[i]['username'],
                uid: searchSnapshot!.body[i]['id'],
                profileProvider: widget.profileProvider,
                groupId: widget.groupId,
              )
            : Container();
      },
      separatorBuilder: (_, i) => const Divider(),
      itemCount: searchSnapshot!.body.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                      hintText: 'Buscar Usuario',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      filled: true,
                      fillColor: Colors.transparent,
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                  onSubmitted: (value) => initiateSearch()),
            ),
            Expanded(child: _searchList())
          ],
        ),
      ),
    );
  }
}

class ListMessageName extends StatelessWidget {
  const ListMessageName({
    required this.username,
    required this.email,
    required this.profileProvider,
    required this.uid,
    required this.groupId,
    super.key,
  });
  final String username;
  final String email;
  final String uid;
  final ProfileProvider profileProvider;
  final groupId;
  @override
  Widget build(BuildContext context) {
    final BackendService backendService =
        Provider.of<BackendService>(context, listen: false);
    return ListTile(
        title: Text(username),
        subtitle: Text(email),
        onTap: () {
          showDialog(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return AlertDialog(
                  elevation: 20,
                  title: Text('Agregar a $username'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.circular(15)),
                  content: Text(
                      '¿Estás seguro de que quieres agregar a $username a su grupo?'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancelar',
                            style: TextStyle(color: Colors.red))),
                    TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final response =
                              await backendService.addIntegrant(groupId, uid);
                          if (response.statusCode == 201) {
                            final BackendResponse responseToken =
                                await backendService.getFirebaseUserToken(uid);
                            print(
                                "THE RESPONSE TOKEN IS : ${responseToken.body} and status code is : ${responseToken.statusCode}");
                            if (responseToken.statusCode == 200) {
                              FirebaseApi firebaseApi = FirebaseApi();
                              final body =
                                  "Se te ha invitado a un grupo, revisa tu perfil para aceptar la invitacion";
                              firebaseApi.sendNotification(
                                  title: "Invitacion a grupo",
                                  body: body,
                                  token: responseToken.body);
                            }
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Hubo un error al agregar a $username a su grupo'),
                            ));
                          }
                        },
                        child: Text('Aceptar'))
                  ],
                );
              });
        });
  }
}
