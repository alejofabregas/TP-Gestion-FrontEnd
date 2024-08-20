import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:splitwise/models/models.dart';
import 'package:splitwise/providers/profile_provider.dart';
import 'package:splitwise/services/backend_response.dart';
import 'package:splitwise/services/backend_service.dart';
import 'package:splitwise/widgets/widgets.dart';

class ListGroups extends StatefulWidget {
  const ListGroups({Key? key, required this.profileProvider}) : super(key: key);
  final ProfileProvider profileProvider;
  @override
  State<ListGroups> createState() => _ListGroupsState();
}

Future<List<BackendResponse<dynamic>>> fetchData(
    BackendService backendService, ProfileProvider profileProvider) async {
  BackendResponse userGroups =
      await backendService.userGroups(profileProvider.profile!.uid);
  BackendResponse invitations =
      await backendService.userInvitations(profileProvider.profile!.uid);

  return [userGroups, invitations];
}

class _ListGroupsState extends State<ListGroups> {
  final RefreshController _refreshController = RefreshController();

  Future<void> _redraw() async {
    setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final BackendService backendService =
        Provider.of<BackendService>(context, listen: false);
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        color: Colors.white,
      ),
      child: FutureBuilder(
        future: fetchData(
          backendService,
          widget.profileProvider,
        ),
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
            if (snapshot.data == null || snapshot.data![0].statusCode != 200) {
              return InkWell(
                onTap: _redraw,
                child: ContainerDeError(
                    function: _redraw,
                    error: "Hubo un Error cargando los grupos",
                    resolucion:
                        "Trata de recargar la pagina tocando la foto, sino intenta mas tarde"),
              );
            }
            BackendResponse response = snapshot.data![0];
            BackendResponse response2 = snapshot.data![1];

            List<Map<String, dynamic>> groupData =
                response.body as List<Map<String, dynamic>>;

            List<Map<String, dynamic>> invitations =
                response2.body as List<Map<String, dynamic>>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Text(
                        'Tus Grupos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: 'Calibri',
                        ),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => Navigator.pushNamed(
                          context, 'invitation_screen',
                          arguments: [widget.profileProvider]),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 52, 112, 161),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 15.0, left: 15.0, top: 10.0, bottom: 10.0),
                          child: Row(
                            children: [
                              const Text(
                                'Invitaciones',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                height: 20,
                                width: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    invitations.length.toString(),
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 52, 112, 161),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SmartRefresher(
                      controller: _refreshController,
                      onRefresh: _redraw,
                      header: const WaterDropHeader(
                        complete: Icon(
                          Icons.check,
                          color: Colors.blue,
                        ),
                        waterDropColor: Colors.blue,
                      ),
                      child: groupData.isEmpty
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 50),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search,
                                      size: 100,
                                      color:
                                          const Color.fromARGB(255, 15, 15, 15)
                                              .withOpacity(0.4),
                                    ),
                                    Text(
                                        'No tienes grupos, crea uno y comienza a invitar a tus amigos',
                                        style: TextStyle(
                                            color: const Color.fromARGB(
                                                    255, 3, 3, 3)
                                                .withOpacity(0.4))),
                                    SizedBox(height: 40),
                                  ]),
                            )
                          : ListView.builder(
                              itemCount: groupData.length,
                              itemBuilder: (_, index) {
                                return Column(
                                  children: [
                                    CustomListTile(
                                      groupData: groupData[index],
                                      imageUrl: 'https://picsum.photos/200',
                                      profileProvider: widget.profileProvider,
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    )
                                  ],
                                );
                              }),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const ContainerDeError(
                error: "Hubo un Error cargando los grupos",
                resolucion:
                    "Trata de recargar la pagina, sino intenta mas tarde");
          }
        },
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  final Map<String, dynamic> groupData;
  final String imageUrl;
  final ProfileProvider profileProvider;

  const CustomListTile({
    super.key,
    required this.groupData,
    required this.imageUrl,
    required this.profileProvider,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, 'display_group',
            arguments: [profileProvider, groupData]); // TODO send the group_id
      },
      child: ListTile(
        leading: ClipOval(
          child: Image.network(
            imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(groupData["name"]),
        subtitle: Text(groupData["description"]),
      ),
    );
  }
}
