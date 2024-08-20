import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:splitwise/models/models.dart';
import 'package:splitwise/providers/profile_provider.dart';
import 'package:splitwise/routes/app_routes.dart';
import 'package:splitwise/services/backend_service.dart';
import 'package:splitwise/services/firebase_service.dart';
import 'package:splitwise/widgets/widgets.dart';

class Home extends StatelessWidget {
  const Home({Key? key});

  Future<void> initNotifications() async {
    final FirebaseApi firebaseApi = FirebaseApi();
    final token = await firebaseApi.initNotifications();
    if (token != null) {
      print("Token: $token");
    }
  }

  @override
  Widget build(BuildContext context) {
    initNotifications();
    final arguments =
        ModalRoute.of(context)!.settings.arguments as List<Object?>;
    final ProfileProvider profileProvider = arguments[0] as ProfileProvider;
    return Scaffold(
      body: Stack(
        children: [
          CustomAppBar(profileProvider: profileProvider),
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
              Expanded(child: ListGroups(profileProvider: profileProvider)),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key, required this.profileProvider})
      : super(key: key);
  final ProfileProvider profileProvider;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = MediaQuery.of(context).size.height * 0.3;

    return AppBar(
      automaticallyImplyLeading: false, // Disable the back button
      title: Row(
        children: [
          IconButton(
              onPressed: () {
                try {
                  BackendService backendService =
                      Provider.of<BackendService>(context, listen: false);
                  backendService
                      .deleteFirebaseToken(profileProvider.profile!.uid);

                  FirebaseAuth.instance.signOut();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'Hubo un error cerrando la sesion, intenta de nuevo'),
                  ));
                  return;
                }
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.initialRoute, (route) => false);
              },
              icon: const Icon(Icons.logout, color: Colors.white)),
          const Text(
            'Maestro Splitter',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Calibri',
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Add your action here
            },
          ),
        ],
      ),
      centerTitle: true,
      flexibleSpace: SizedBox(
        height: imageHeight,
        width: screenWidth,
        child: Stack(
          children: [
            const GradientShapesBackground(),
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/home.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
