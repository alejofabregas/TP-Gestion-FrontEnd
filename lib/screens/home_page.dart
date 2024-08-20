import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:splitwise/helpers/display.dart';
import 'package:splitwise/helpers/form_helper.dart';
import 'package:splitwise/screens/bottom_nav/bottom_navigation.dart';
import 'package:splitwise/screens/login_screen/home_screen.dart';
import 'package:splitwise/services/backend_service.dart';

import '../providers/providers.dart';
import '../routes/app_routes.dart';
import '../themes/app_theme.dart';
import '../widgets/widgets.dart';

class HomePageNav extends StatefulWidget {
  const HomePageNav({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePageNav> createState() => _HomePageNavState();
}

class _HomePageNavState extends State<HomePageNav> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as List<Object?>;
    final ProfileProvider profileProvider = arguments[0] as ProfileProvider;
    final GroupProvider groupProvider =
        Provider.of<GroupProvider>(context, listen: true);
    final indexProvider = Provider.of<IndexProvider>(context);
    final FormHelper formHelper = FormHelper();
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          onPressed: () {
            showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) {
                  return CreateNewGroup(
                      profileProvider: profileProvider,
                      groupProvider: groupProvider,
                      formHelper: formHelper);
                });
          },
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 0.3,
          notchMargin: 6.0,
          height: size.height * 0.15,
          clipBehavior: Clip.antiAlias,
          color: const Color(0xff1c1f26),
          shape: const AutomaticNotchedShape(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
          child: BottomNavigationItems(
            currentIndex: indexProvider.index,
            onIndexChanged: (int newIndex) {
              setState(() {
                index = newIndex;
                indexProvider.setIndex(newIndex);
              });
            },
          ),
        ),
        body: BottomRoutes(index: indexProvider.index),
      ),
    );
  }
}
