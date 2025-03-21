import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tamago/main.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PetSelectionScreen extends StatelessWidget {
  final List<Map<String, String>> pets = [
    {'name': 'Dog', 'image': 'assets/images/dog_stage1.png'},
    {'name': 'Cat', 'image': 'assets/images/cat_stage1.png'},
    {'name': 'Bird', 'image': 'assets/images/bird_stage1.png'},
  ];

  void selectPet(BuildContext context, String petName, String petImage) {
    var userBox = Hive.box('userBox');
    userBox.put('selectedPet', {'name': petName, 'image': petImage});
    userBox.put('hasChosenPet', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TamagoGame()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Choose Your Pet"),
      //   backgroundColor: Colors.indigo,
      //   elevation: 5,
      // ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 219, 242, 114),
              Color.fromARGB(255, 153, 227, 6),
            ], // Matching gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Select Your Pet",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: pets.map((pet) {
                  return GestureDetector(
                    onTap: () =>
                        selectPet(context, pet['name']!, pet['image']!),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.indigo, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                spreadRadius: 2,
                                offset: Offset(2, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              pet['image']!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          pet['name']!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
