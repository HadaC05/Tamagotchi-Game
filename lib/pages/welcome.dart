import 'package:flutter/material.dart';
import 'package:tamago/pages/login.dart';
import 'package:tamago/pages/registration.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage("assets/images/welcome_bg.jpg"),
        //     fit: BoxFit.cover,
        //   ),
        // ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 219, 242, 114),
              const Color.fromARGB(255, 153, 227, 6)
            ], // Change colors as needed
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome to Tamago!",
                  style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 25,
                  ),
                ),
                Text(
                  "Your new virtual pet is waiting for you!",
                ),
              ],
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.indigo, // Text color
                      side: BorderSide(
                          color: Colors.indigo,
                          width: 2), // Border color and thickness
                      padding: EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15), // Button padding
                      textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold), // Text styling
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // Rounded edges
                      ),
                    ),
                    child: Text("Log In"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistrationPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo, // Button color
                      foregroundColor: Colors.white, // Text color
                      padding: EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15), // Button padding
                      textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold), // Text style
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // Rounded edges
                      ),
                      elevation: 5, // Adds a shadow effect
                    ),
                    child: Text("Sign Up"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
