import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tamago/pages/journal.dart';
import 'package:tamago/pages/profile.dart';
import 'package:tamago/pages/home.dart';
import 'package:tamago/pages/welcome.dart';
// import 'package:audioplayers/audioplayers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('users');
  await Hive.openBox('userBox');
  runApp(MyApp());
  checkUsers();
}

void checkUsers() {
  var usersBox = Hive.box('users');
  print('Stored users after restart: ${usersBox.keys.toList()}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
    );
  }
}

class TamagoGame extends StatefulWidget {
  const TamagoGame({super.key});

  @override
  _TamagoGameState createState() => _TamagoGameState();
}

class _TamagoGameState extends State<TamagoGame> {
  int _selectedIndex = 1;

  final List<Widget> _screen = [
    JournalListPage(),
    HomePage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.pages), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
