import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../crews/crews_screen.dart';
import '../create/create_crew_screen.dart';
import '../join/join_crew_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentIndex = 0;

  Widget _getPage(int index) {
  switch (index) {
    case 0: return const HomeScreen();
    case 1: return const CrewsScreen();
    case 2: return const CreateCrewScreen();
    case 3: return const JoinCrewScreen();
    case 4: return const ProfileScreen();  // rebuilt fresh every time
    default: return const HomeScreen();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(currentIndex),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: "Crews",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: "Create",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login_outlined),
            activeIcon: Icon(Icons.login),
            label: "Join",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
