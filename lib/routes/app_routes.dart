import 'package:flutter/widgets.dart';
import 'package:splitwise/screens/screens.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const initialRoute = 'home_screen';

  static Map<String, Widget Function(BuildContext)> routes = {
    'home_screen': (BuildContext context) => const HomeScreen(),
    'home_page': (BuildContext context) => const HomePageNav(),
    "display_group": (BuildContext context) => const DisplayGroup(),
    "add_integrant": (BuildContext context) => const AddIntegrantScreen(),
    "profile_screen": (BuildContext context) => const ProfileScreen(),
    "invitation_screen": (BuildContext context) => const InvitationScreen(),
    "expense_screen": (BuildContext context) =>
        const PostExpenseScreenWrapper(),
    "payment_screen": (BuildContext context) => const PaymentScreen(),
    "group_history": (BuildContext context) => GroupHistoryScreen(),
    "default": (BuildContext context) => const Default_screem()
  };
}

class MenuOption {
  final String route;
  final IconData icon;
  final String name;
  final Widget screen;

  MenuOption(
      {required this.route,
      required this.icon,
      required this.name,
      required this.screen});
}

class BottomRoutes extends StatelessWidget {
  final int index;
  const BottomRoutes({Key? key, required this.index}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<Widget> routes = [
      const Home(),
      // const Default_screem(),
      const ProfileScreen(),
    ];
    return routes[index];
  }
}

class Default_screem extends StatelessWidget {
  const Default_screem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    return Scaffold(
        appBar: AppBar(title: const Text("Invitaciones")),
        body: Container(
            width: 300,
            height: 200,
            decoration: const BoxDecoration(color: Colors.red),
            child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                physics: const BouncingScrollPhysics(),
                itemCount: 15,
                itemBuilder: (context, index) => Text("hola este es $index"))));
  }
}
