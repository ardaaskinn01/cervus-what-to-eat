class UserProfileModel {
  final String name;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final String? notificationTime;
  final String? defaultMealFilter;
  final String dietType; // Normal, Vejetaryen, Vegan, Glutensiz, Düşük Karbonhidrat
  final List<String> allergies; // Fındık, Süt ürünü, Gluten, Deniz ürünü
  final int dailyCalorieGoal;

  UserProfileModel({
    required this.name,
    required this.isDarkMode,
    required this.notificationsEnabled,
    this.notificationTime,
    this.defaultMealFilter,
    required this.dietType,
    required this.allergies,
    required this.dailyCalorieGoal,
  });

  UserProfileModel copyWith({
    String? name,
    bool? isDarkMode,
    bool? notificationsEnabled,
    String? notificationTime,
    String? defaultMealFilter,
    String? dietType,
    List<String>? allergies,
    int? dailyCalorieGoal,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      defaultMealFilter: defaultMealFilter ?? this.defaultMealFilter,
      dietType: dietType ?? this.dietType,
      allergies: allergies ?? this.allergies,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] ?? '',
      isDarkMode: json['isDarkMode'] ?? false,
      notificationsEnabled: json['notificationsEnabled'] ?? false,
      notificationTime: json['notificationTime'],
      defaultMealFilter: json['defaultMealFilter'],
      dietType: json['dietType'] ?? 'Normal',
      allergies: List<String>.from(json['allergies'] ?? []),
      dailyCalorieGoal: json['dailyCalorieGoal'] ?? 2000,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'isDarkMode': isDarkMode,
    'notificationsEnabled': notificationsEnabled,
    'notificationTime': notificationTime,
    'defaultMealFilter': defaultMealFilter,
    'dietType': dietType,
    'allergies': allergies,
    'dailyCalorieGoal': dailyCalorieGoal,
  };
}
