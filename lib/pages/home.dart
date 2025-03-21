import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
// import 'package:tamago/components/appbar.dart';
import 'dart:async';

import 'package:tamago/pages/shop_dialog.dart';

class TamaHome extends StatelessWidget {
  const TamaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _timer;
  var usersBox = Hive.box('users');
  late Map userData;

  @override
  void initState() {
    super.initState();
    loadUserData();
    checkDailyReset();

    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          decreaseStatOverTime();
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void loadUserData() {
    userData = usersBox.get('user_data', defaultValue: {
      "hunger": 100,
      "happiness": 100,
      "level": 1,
      "evolution_stage": 1,
      "quests": {},
      "lastLogin": DateTime.now().toString(),
      "lastUpdate": DateTime.now().toString(),
      "journalEntries": [],
    });
  }

  void checkDailyReset() {
    DateTime lastLogin = DateTime.parse(
      userData['lastLogin'],
    );
    DateTime today = DateTime.now();

    if (lastLogin.day != today.day ||
        lastLogin.month != today.month ||
        lastLogin.year != today.year) {
      userData['quests'] = {}; //resets the quest
      userData['lastLogin'] = today.toString();
      usersBox.put('user_data', userData);
      setState(() {});
    }
  }

  void claimReward(String quest, int exp, int coins, int happiness) {
    if (!userData['quests'].containsKey(quest)) {
      userData['level'] += exp;
      userData['coins'] = (userData['coins'] ?? 0) + coins;
      userData['happiness'] = (userData['happiness'] + happiness).clamp(0, 100);
      userData['quests'][quest] = true;
      checkEvolution();
      usersBox.put('user_data', userData);
      setState(() {});
    }
  }

  // need adjustments
  void checkEvolution() {
    int level = userData['level'];
    int currentStage = userData['evolution_stage'];

    if (level >= 10 && currentStage == 1) {
      userData['evolution_stage'] = 2;
    } else if (level >= 20 && currentStage == 2) {
      userData['evolution_stage'] = 3;
    }

    // Save to Hive
    usersBox.put('user_data', userData);
    var userBox = Hive.box('userBox');
    userBox.put('evolution_stage', userData['evolution_stage']);

    // Ensure UI updates
    setState(() {});
  }

  void addJournalEntry(String content) {
    String date = DateTime.now().toString().split(' ')[0];
    userData['journalEntries'].add({"date": date, "content": content});
    usersBox.put('user_data', userData);
    claimReward("journal", 10, 5, 5);
    setState(() {});
  }

  void showJournalDialog() {
    TextEditingController journalController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Journal Entry'),
        content: TextField(
          controller: journalController,
          decoration: InputDecoration(
            hintText: "Write your thoughts...",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (journalController.text.isNotEmpty) {
                addJournalEntry(journalController.text);
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void decreaseStatOverTime() {
    DateTime lastUpdate = DateTime.parse(userData['lastUpdate']);
    DateTime now = DateTime.now();
    Duration elapsed = now.difference(lastUpdate);

    int hungerLoss = (elapsed.inMinutes ~/ 1);
    int happinessLoss = (elapsed.inMinutes ~/ 1);

    setState(() {
      userData['hunger'] = (userData['hunger'] - hungerLoss).clamp(0, 100);
      userData['happiness'] =
          (userData['happiness'] - happinessLoss).clamp(0, 100);
      userData['lastUpdate'] = now.toString();

      usersBox.put('user_data', userData);
    });
  }

  String getPetImage() {
    var userBox = Hive.box('userBox');

    dynamic selectedPetData = userBox.get('selectedPet', defaultValue: null);

    if (selectedPetData == null || selectedPetData is! Map) {
      return 'assets/images/default_stage1.png';
    }

    Map<String, dynamic>? selectedPet =
        Map<String, dynamic>.from(selectedPetData);

    String petName = selectedPet['name'].toLowerCase();
    int evolutionStage = userBox.get('evolution_stage', defaultValue: 1);
    return 'assets/images/${petName}_stage$evolutionStage.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CustomAppBar(
      //   title: 'YOUR VIRTUAL PET',
      //   backgroundColor: Colors.indigo, // AppBar background color
      //   elevation: 5, // Adding shadow to the AppBar for depth
      // ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 219, 242, 114),
              Color.fromARGB(255, 153, 227, 6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome Text
                Text(
                  "Your Virtual Pet!",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                SizedBox(height: 20),

                // Set Mood Button
                // ElevatedButton(
                //   onPressed: () {},
                //   style: ElevatedButton.styleFrom(
                //     // primary: Colors.indigo,
                //     padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(30),
                //     ),
                //   ),
                //   child: Text(
                //     'Set Your Mood',
                //     style: TextStyle(fontSize: 16, color: Colors.white),
                //   ),
                // ),
                // SizedBox(height: 20),

                // Pet Image with Gesture
                GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      userData['coins'] = (userData['coins'] ?? 0) + 5;
                      userData['happiness'] =
                          (userData['happiness'] + 3).clamp(0, 100);
                      usersBox.put('user_data', userData);
                    });
                  },
                  child: Container(
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
                        getPetImage(),
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Level and Coins
                Text(
                  "Level: ${userData['level']}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  "Coins: ${userData['coins'] ?? 0}",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // Hunger Progress Bar
                Text(
                  'Hunger Level',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      value: userData['hunger'] / 100,
                      color: Colors.red,
                      backgroundColor: Colors.amber,
                      minHeight: 20,
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // Happiness Progress Bar
                Text(
                  'Happiness Level',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      value: userData['happiness'] / 100,
                      color: Colors.blue,
                      minHeight: 20,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Write on Journal Button
                ElevatedButton(
                  onPressed: showJournalDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    // shadowColor: Colors.indigo,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Write on Journal',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Quest Button
          FloatingActionButton(
            onPressed: () => showQuestsDialog(),
            backgroundColor: Colors.indigo,
            child: Icon(Icons.list, color: Colors.white),
            heroTag: "quest_button",
          ),
          SizedBox(height: 10),

          // Shop Button
          FloatingActionButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => ShopDialog(
                refreshHome: refreshHome,
              ),
            ),
            backgroundColor: Colors.indigo,
            child: Icon(Icons.shopping_cart, color: Colors.white),
            heroTag: "shop_button",
          ),
        ],
      ),
    );
  }

  void refreshHome() {
    setState(() {
      userData = usersBox.get('user_data'); // Reload data from Hive
    });
  }

  // Kung iclick ang floating button, naa ang quest section
  void showQuestsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Daily Quest'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QuestItem("Log In", "login", 10, 10, 10),
            QuestItem("Set Mood", "set_mood", 5, 10, 0),
            QuestItem("Write Journal", "journal", 10, 5, 5),
          ],
        ),
      ),
    );
  }

  Widget QuestItem(
      String title, String questKey, int exp, int coins, int happiness) {
    return ListTile(
      title: Text(title),
      trailing: userData['quests'].containsKey(questKey)
          ? Icon(
              Icons.check,
              color: Colors.green,
            )
          : ElevatedButton(
              onPressed: () => claimReward(questKey, exp, coins, happiness),
              child: Text("Claim"),
            ),
    );
  }
}
