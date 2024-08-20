import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:splitwise/providers/providers.dart';
import 'package:splitwise/screens/bottom_nav/home.dart';
import 'package:splitwise/services/backend_response.dart';
import 'package:splitwise/widgets/widgets.dart';

import '../../services/backend_service.dart';

class InvitationScreen extends StatefulWidget {
  const InvitationScreen({Key? key});

  @override
  State<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen> {
  final RefreshController _refreshController = RefreshController();

  Future<void> _redraw() async {
    setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final BackendService backendService =
        Provider.of<BackendService>(context, listen: false);
    final arguments =
        ModalRoute.of(context)!.settings.arguments as List<Object?>;
    final ProfileProvider profileProvider = arguments[0] as ProfileProvider;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Invitations'),
          centerTitle: true,
        ),
        body: FutureBuilder(
            future:
                backendService.userInvitations(profileProvider.profile!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SpinKitWave(
                    color: Colors.indigo.withOpacity(0.5),
                    size: 50,
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null || snapshot.data!.statusCode != 200) {
                  return const ContainerDeError(
                      error: "Hubo un Error cargando tu usuario",
                      resolucion:
                          "Trata de recargar la pagina, sino intenta mas tarde");
                }
                BackendResponse response = snapshot.data as BackendResponse;
                return snapshot.data!.body.isEmpty
                    ? Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                            Icon(
                              Icons.search,
                              size: 100,
                              color: const Color.fromARGB(255, 15, 15, 15)
                                  .withOpacity(0.4),
                            ),
                            Text('No tienes invitaciones pendientes',
                                style: TextStyle(
                                    color: const Color.fromARGB(255, 3, 3, 3)
                                        .withOpacity(0.4)))
                          ]))
                    : SmartRefresher(
                        controller: _refreshController,
                        onRefresh: _redraw,
                        physics: const BouncingScrollPhysics(),
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(response.body[index]['name']),
                              subtitle: Text(response.body[index]['name']),
                              trailing: Container(
                                width: 100,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        backendService
                                            .declineInvitation(
                                                response.body[index]['id'],
                                                profileProvider.profile!.uid)
                                            .then((value) {
                                          if (value.statusCode == 200) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content:
                                                  Text("Invitation Rejected"),
                                            ));
                                            setState(() {});
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Error Rejecting Invitation"),
                                            ));
                                          }
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.check),
                                      onPressed: () {
                                        backendService
                                            .acceptInvitation(
                                                response.body[index]['id'],
                                                profileProvider.profile!.uid)
                                            .then((value) {
                                          if (value.statusCode == 200) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content:
                                                  Text("Invitation Accepted"),
                                            ));
                                            setState(() {});
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Error Accepting Invitation"),
                                            ));
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          itemCount: response.body.length,
                        ),
                      );
              } else {
                return const ContainerDeError(
                    error: "Hubo un Error cargando los grupos",
                    resolucion:
                        "Trata de recargar la pagina, sino intenta mas tarde");
              }
            }));
  }
}
