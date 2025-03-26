import 'package:flutter/material.dart';
import 'package:tamago/components/appbar.dart';
import 'package:hive/hive.dart';
import 'package:tamago/pages/login.dart';
import 'audio_manager.dart';

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
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 4.0,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.greenAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const CircleAvatar(
            //   radius: 80,
            //   backgroundImage: AssetImage('assets/images/placeholder.jpg'),
            // ),

            const SizedBox(height: 30),

            // Audio Mute Button
            ElevatedButton.icon(
              onPressed: () {
                AudioManager().toggleMute();
              },
              icon: Icon(
                AudioManager().isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
              ),
              label: Text(
                AudioManager().isMuted ? 'Unmute Music' : 'Mute Music',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),

            const SizedBox(height: 30),

            // Logout Button
            ElevatedButton(
              onPressed: logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
