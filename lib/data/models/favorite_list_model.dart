class FavoriteListModel {
  final String id;
  final String name;
  final String emoji;
  final int colorInt;
  final List<String> foodIds;

  FavoriteListModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorInt,
    required this.foodIds,
  });

  FavoriteListModel copyWith({
    String? id,
    String? name,
    String? emoji,
    int? colorInt,
    List<String>? foodIds,
  }) {
    return FavoriteListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorInt: colorInt ?? this.colorInt,
      foodIds: foodIds ?? this.foodIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'colorInt': colorInt,
    'foodIds': foodIds,
  };

  factory FavoriteListModel.fromJson(Map<String, dynamic> json) => FavoriteListModel(
    id: json['id'],
    name: json['name'],
    emoji: json['emoji'],
    colorInt: json['colorInt'],
    foodIds: List<String>.from(json['foodIds'] ?? []),
  );
}
