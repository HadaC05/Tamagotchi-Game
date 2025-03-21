import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ShopDialog extends StatelessWidget {
  final Function refreshHome; // Callback function

  ShopDialog({required this.refreshHome});
  final List<Map<String, dynamic>> foodItems = [
    {'name': 'Food 1', 'hunger': 15, 'price': 5},
    {'name': 'Food 2', 'hunger': 30, 'price': 8},
    {'name': 'Food 3', 'hunger': 50, 'price': 12},
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Not enough coins!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Shop"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: foodItems.map((food) {
          return ListTile(
            title: Text(food['name']),
            subtitle: Text(
                "Hunger: ${food['hunger']} | Price: ${food['price']} coins"),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Buy ${food['name']}?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        buyFood(context, food['hunger'], food['price']);
                      },
                      child: Text("Confirm"),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
