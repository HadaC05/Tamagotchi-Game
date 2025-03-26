import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import 'audio_manager.dart';
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
  String petNickname = "";
  String backgroundImage = 'assets/images/default.png';

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadPetNickname();
    checkDailyReset();
    AudioManager().playBackgroundMusic();

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
    super.dispose();
  }

  void setBackground(String imagePath) {
    setState(() {
      backgroundImage = imagePath;
      Hive.box('userBox').put('backgroundImage', imagePath);
      // claimReward("set_mood", 5, 10, 0);
    });
  }

  void loadPetNickname() {
    var userBox = Hive.box('userBox');
    dynamic selectedPet = userBox.get('selectedPet');

    if (selectedPet != null &&
        selectedPet is Map &&
        selectedPet.containsKey('nickname')) {
      setState(() {
        petNickname = selectedPet['nickname'];
      });
    } else {
      petNickname = "Your Pet";
    }
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

      checkPetStatus();
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
    } else {
      return;
    }

    // Save to Hive
    usersBox.put('user_data', userData);
    var userBox = Hive.box('userBox');
    userBox.put('evolution_stage', userData['evolution_stage']);

    // Ensure UI updates
    setState(() {});

    // evolution pop up
    showEvolutionPopup();
  }

  void showEvolutionPopup() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Your Pet has evolved!"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(8.0),
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
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                    "Congratulations! Your pet has reached a new evolution stage."),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        });
  }

  void addJournalEntry(String content) {
    String date = DateTime.now().toString().split(' ')[0];
    userData['journalEntries'].add({"date": date, "content": content});
    usersBox.put('user_data', userData);
    // claimReward("journal", 10, 5, 5);
    setState(() {});
  }

  void showJournalDialog() {
    TextEditingController journalController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'New Journal Entry',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        content: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(4, 4),
              ),
            ],
          ),
          child: TextField(
            controller: journalController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: "Write your thoughts...",
              border: InputBorder.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (journalController.text.isNotEmpty) {
                addJournalEntry(journalController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void checkPetStatus() {
    if (userData['hunger'] <= 0 && userData['happiness'] <= 0) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Oh no! Your pet has passed away.'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/pet_dead.png', height: 150),
              SizedBox(height: 20),
              Text('Your pet’s hunger and happiness reached zero.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  var userBox = Hive.box('userBox');
                  userBox.put('evolution_stage', 'dead');
                });
              },
              child: Text('Okay'),
            ),
          ],
        ),
      );
    }
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

      checkPetStatus();
    });
  }

  void showDaySelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Time of Day'),
        content: SizedBox(
          height: 200,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DayOption(
                        imagePath: 'assets/images/morning.png',
                        label: 'Morning',
                        onSelect: setBackground),
                    DayOption(
                        imagePath: 'assets/images/afternoon.png',
                        label: 'Afternoon',
                        onSelect: setBackground),
                    DayOption(
                        imagePath: 'assets/images/evening.png',
                        label: 'Evening',
                        onSelect: setBackground),
                  ],
                ),
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
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

    // dead pet
    if (userBox.get('evolution_stage') == 'dead') {
      return 'assets/images/pet_dead.png';
    }

    // sleep condition
    if (backgroundImage == 'assets/images/evening.png') {
      return 'assets/images/${petName}_sleep.png';
    }

    // hunger condition
    if (userData['hunger'] <= 50) {
      return 'assets/images/${petName}_hungry.png';
    }

    return 'assets/images/${petName}_stage$evolutionStage.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Opacity(
            opacity: 1,
            child: SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Welcome Text
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.indigo.shade50,
                              Colors.blue.shade100
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(4, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Hello, $petNickname!",
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.monetization_on,
                                      color: const Color.fromARGB(
                                          255, 213, 199, 0),
                                      size: 24,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "Coins: ${userData['coins'] ?? 0}",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(
                                            255, 213, 199, 0),
                                        shadows: [
                                          Shadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            offset: Offset(2, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Level: ${userData['level']}",
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 64, 64, 64),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10),

                      // Set Mood Button
                      ElevatedButton(
                        onPressed: () {
                          showDaySelectionDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Set Your Day',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 20),

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

                      // Level and Coins

                      SizedBox(height: 10),

                      // Hunger Progress Bar
                      Text(
                        'Busog Level',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 200,
                          child: LinearProgressIndicator(
                            value: userData['hunger'] / 100,
                            color: Colors.red,
                            backgroundColor:
                                const Color.fromARGB(255, 255, 229, 150),
                            minHeight: 20,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),

                      // Happiness Progress Bar
                      Text(
                        'Lingaw Level',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 200,
                          child: LinearProgressIndicator(
                            value: userData['happiness'] / 100,
                            color: Colors.blue,
                            backgroundColor:
                                const Color.fromARGB(255, 255, 229, 150),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
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
            QuestItem("Log In", "login", 1, 10, 10),
            QuestItem("Set Your Day", "set_mood", 1, 10, 0),
            QuestItem("Write Journal", "journal", 2, 5, 5),
          ],
        ),
      ),
    );
  }

  Widget QuestItem(
      String title, String questKey, int exp, int coins, int happiness) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isQuestCompleted = userData['quests'].containsKey(questKey);
        bool isQuestClaimable = false;

        if (questKey == "login") {
          DateTime lastLogin = DateTime.parse(userData['lastLogin']);
          isQuestClaimable = DateTime.now().difference(lastLogin).inDays == 0;
        } else if (questKey == "set_mood") {
          isQuestClaimable = backgroundImage != 'assets/images/default.png';
        } else if (questKey == "journal") {
          isQuestClaimable = userData['journalEntries'].isNotEmpty &&
              userData['journalEntries'].any((entry) =>
                  entry['date'] == DateTime.now().toString().split(' ')[0]);
        }

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
            trailing: isQuestCompleted
                ? const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 28,
                  )
                : ElevatedButton(
                    onPressed: isQuestClaimable
                        ? () {
                            claimReward(questKey, exp, coins, happiness);
                            setState(() {});
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isQuestClaimable ? Colors.teal : Colors.grey,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Claim",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class DayOption extends StatelessWidget {
  final String imagePath;
  final String label;
  final Function(String) onSelect;

  const DayOption(
      {required this.imagePath, required this.label, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onSelect(imagePath);
        Navigator.pop(context);
      },
      child: Container(
        width: 90,
        height: 150,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 4,
              offset: Offset(2, 1),
            )
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
