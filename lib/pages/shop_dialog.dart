import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ShopDialog extends StatelessWidget {
  final Function refreshHome; // Callback function

  ShopDialog({required this.refreshHome});
  final List<Map<String, dynamic>> foodItems = [
    {'name': 'Basic Food', 'hunger': 15, 'price': 5},
    {'name': 'Uncommon Food', 'hunger': 30, 'price': 8},
    {'name': 'Premium Food', 'hunger': 50, 'price': 12},
  ];

  void buyFood(BuildContext context, int hunger, int price) {
    var usersBox = Hive.box('users');
    var userData = usersBox.get('user_data');

    int coins = userData['coins'] ?? 0;

    if (coins >= price) {
      userData['coins'] -= price;
      userData['hunger'] = (userData['hunger'] + hunger).clamp(0, 100);
      usersBox.put('user_data', userData);

      refreshHome();
      Navigator.pop(context);
    } else {
      Future.microtask(() {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Insufficient Coins"),
              content: Text("You don't have enough coins to buy this item."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Shop",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Colors.teal,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: foodItems.map((food) {
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.fastfood, color: Colors.orange),
                title: Text(
                  food['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Hunger: ${food['hunger']} | Price: ${food['price']} coins",
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Buy ${food['name']}?"),
                        content: Text(
                            "Are you sure you want to purchase this for ${food['price']} coins?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              buyFood(context, food['hunger'], food['price']);
                              Navigator.pop(
                                  context); // Close dialog after purchase
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                            ),
                            child: const Text(
                              "Confirm",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                  child: const Text(
                    "Buy",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
