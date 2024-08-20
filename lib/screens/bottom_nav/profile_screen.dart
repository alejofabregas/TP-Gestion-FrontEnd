import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:splitwise/helpers/form_helper.dart';
import 'package:splitwise/providers/providers.dart';
import 'package:splitwise/screens/bottom_nav/home.dart';
import 'package:splitwise/services/backend_response.dart';
import 'package:splitwise/services/firebase_service.dart';
import 'package:splitwise/widgets/widgets.dart';

import '../../services/backend_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final RefreshController _refreshController = RefreshController();

  Future<void> _redraw() async {
    setState(() {});
    _refreshController.refreshCompleted();
  }

  Future<void> initNotifications() async {
    print("initNotifications");
    final FirebaseApi firebaseApi = FirebaseApi();
    await firebaseApi.sendNotification(
        title: "Titulooo",
        body: "Esto es una pruebita",
        token:
            "ceg77IHzTDytnXk4Tp4oAv:APA91bHYZucbW1t-b_XVz4EmpxrE5rmWAYunmIKDics5e5its8bgPSpDQZMdkCFrGzfJSVs40Os6JYU_R8rKUefgPFE7NOMEkS0-xcQnHeE8N9tXSKA78ImyrZnIdHO0OjiBLcDuZPnT");
  }

  @override
  Widget build(BuildContext context) {
    print("holaaaa");
    // initNotifications();

    final arguments =
        ModalRoute.of(context)!.settings.arguments as List<Object?>;
    final ProfileProvider profileProvider = arguments[0] as ProfileProvider;
    return Scaffold(
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _redraw,
        header: WaterDropHeader(
          complete: const Icon(
            Icons.check,
            color: Colors.blue,
          ),
          waterDropColor: Colors.blue,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Stack(
            children: [
              CustomAppBar(profileProvider: profileProvider),
              Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25),
                        const Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child: Text(
                            'Tu Perfil',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              fontFamily: 'Calibri',
                            ),
                          ),
                        ),
                        UsernameDisplay(profileProvider: profileProvider),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UsernameDisplay extends StatefulWidget {
  const UsernameDisplay({
    super.key,
    required this.profileProvider,
  });

  final ProfileProvider profileProvider;

  @override
  State<UsernameDisplay> createState() => _UsernameDisplayState();
}

class _UsernameDisplayState extends State<UsernameDisplay> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Material(
            elevation: 8,
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ExpansionPanelList(
                elevation: 0,
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                children: [
                  ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Nombre de Usuario: ${widget.profileProvider.profile!.username}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                    isExpanded: _isExpanded,
                    body: ExpandedUsername(
                        profileProvider: widget.profileProvider),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Material(
            elevation: 8,
            color: Colors.transparent,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Text(
                    'Email: ${widget.profileProvider.profile!.email}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandedUsername extends StatelessWidget {
  const ExpandedUsername({
    required this.profileProvider,
    super.key,
  });
  final ProfileProvider profileProvider;

  @override
  Widget build(BuildContext context) {
    final BackendService backendService =
        Provider.of<BackendService>(context, listen: false);
    final userNameProvider = Provider.of<UsernameProvider>(context);
    final FormHelper formHelper = FormHelper();
    return Row(
      children: [
        Form(
          key: userNameProvider.formUserKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: LoginFormField(
            width: 200,
            validator: formHelper.isValidName,
            isPassword: false,
            text: "Nombre de usuario",
            formValues: userNameProvider.formValues,
            formProperty: "username",
          ),
        ),
        SizedBox(
          width: 40,
        ),
        ElevatedButton(
          onPressed: () async {
            FocusScope.of(context).unfocus();
            if (userNameProvider.isLoading == true) return;
            if (userNameProvider.isValidForm()) {
              userNameProvider.setLoading(true);
              final response = await backendService.editUser(
                userNameProvider.formValues['username']!,
                profileProvider.profile!.uid,
              );
              userNameProvider.setLoading(false);
              if (response.statusCode == 200) {
                profileProvider.profile!.username =
                    userNameProvider.formValues['username']!;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nombre de usuario actualizado'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error al actualizar el nombre de usuario'),
                  ),
                );
              }
            }
          },
          child: userNameProvider.isLoading == true
              ? const SpinKitCircle(
                  color: Color.fromARGB(255, 87, 87, 87),
                  size: 20,
                )
              : const Text('Editar'),
        )
      ],
    );
  }
}
