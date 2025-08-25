import 'package:flutter/material.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onTabTapped;

  const AppLayout({
    Key? key,
    required this.child,
    required this.currentIndex,
    required this.onTabTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Durumlar'),
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: 'Aramalar'),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Topluluk'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Sohbet',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
      ),
    );
  }
}
