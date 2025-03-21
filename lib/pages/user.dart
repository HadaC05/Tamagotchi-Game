class User {
  String username;
  int coins;
  int hunger;
  int happiness;
  bool firstLogin;
  String selectedPet;

  User({
    required this.username,
    this.coins = 0,
    this.hunger = 100,
    this.happiness = 100,
    this.firstLogin = true,
    this.selectedPet = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'coins': coins,
      'hunger': hunger,
      'happiness': happiness,
      'firstLogin': firstLogin,
      'selectedPet': selectedPet,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      coins: json['coins'],
      hunger: json['hunger'],
      happiness: json['happiness'],
      firstLogin: json['firstLogin'],
      selectedPet: json['selectedPet'],
    );
  }
}
