// Should be accessible from the navigation bar

import 'package:flutter/material.dart';
import 'package:tamago/components/appbar.dart';
import 'package:hive/hive.dart';
import 'package:tamago/pages/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String currentUser = "";
  Map<String, dynamic> userData = {};
  var usersBox = Hive.box('users');

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() {
    String? storedUser = usersBox.get('currentUser');
    if (storedUser != null && usersBox.containsKey(storedUser)) {
      setState(() {
        currentUser = storedUser;
        userData = usersBox.get(currentUser);
      });
    } else {
      setState(() {
        currentUser = "";
        userData = {};
      });
    }
  }

  void logout() {
    if (currentUser.isNotEmpty) {
      usersBox.put(currentUser, userData);
    }

    usersBox.delete('currentUser');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'My Profile'),
      body: Center(
        child: Column(
          children: [
            Text("Welcome, $currentUser!"),
            Image.asset(
              'assets/images/placeholder.jpg',
              height: 150,
            ),
            SizedBox(
              height: 10.0,
            ),
            ElevatedButton(
              onPressed: logout,
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
