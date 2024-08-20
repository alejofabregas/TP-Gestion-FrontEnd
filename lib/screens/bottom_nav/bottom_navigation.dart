import 'package:flutter/material.dart';

class BottomNavigationItems extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const BottomNavigationItems({
    Key? key,
    required this.currentIndex,
    required this.onIndexChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: const Color(0xff1c1f26),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        selectedItemColor: Color.fromARGB(255, 210, 130, 11),
        unselectedItemColor: Color.fromARGB(255, 137, 138, 160),
        currentIndex: currentIndex,
        elevation: 80,
        onTap: onIndexChanged,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.account_balance_wallet),
          //   label: 'Deudas',
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.notifications),
          //   label: 'Notificaciones',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
