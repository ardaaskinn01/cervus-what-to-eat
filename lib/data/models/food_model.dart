import 'package:flutter/foundation.dart';

class FoodModel {
  final String id;
  final String name;
  final List<String> mealTypes;
  final List<String> place;
  final int timeMinutes;
  final String budget;
  final List<String> dietTags;
  final String cuisine;
  final String difficulty;
  final List<String> ingredients;
  final String description;
  final String imageEmoji;
  final List<String> moodTags;
  final List<String> weatherTags;
  final String calorieRange;
  final double popularityScore;

  FoodModel({
    required this.id,
    required this.name,
    required this.mealTypes,
    required this.place,
    required this.timeMinutes,
    required this.budget,
    required this.dietTags,
    required this.cuisine,
    required this.difficulty,
    required this.ingredients,
    required this.description,
    required this.imageEmoji,
    required this.moodTags,
    required this.weatherTags,
    required this.calorieRange,
    required this.popularityScore,
  });

  FoodModel copyWith({
    String? id,
    String? name,
    List<String>? mealTypes,
    List<String>? place,
    int? timeMinutes,
    String? budget,
    List<String>? dietTags,
    String? cuisine,
    String? difficulty,
    List<String>? ingredients,
    String? description,
    String? imageEmoji,
    List<String>? moodTags,
    List<String>? weatherTags,
    String? calorieRange,
    double? popularityScore,
  }) {
    return FoodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mealTypes: mealTypes ?? this.mealTypes,
      place: place ?? this.place,
      timeMinutes: timeMinutes ?? this.timeMinutes,
      budget: budget ?? this.budget,
      dietTags: dietTags ?? this.dietTags,
      cuisine: cuisine ?? this.cuisine,
      difficulty: difficulty ?? this.difficulty,
      ingredients: ingredients ?? this.ingredients,
      description: description ?? this.description,
      imageEmoji: imageEmoji ?? this.imageEmoji,
      moodTags: moodTags ?? this.moodTags,
      weatherTags: weatherTags ?? this.weatherTags,
      calorieRange: calorieRange ?? this.calorieRange,
      popularityScore: popularityScore ?? this.popularityScore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mealTypes': mealTypes,
      'place': place,
      'timeMinutes': timeMinutes,
      'budget': budget,
      'dietTags': dietTags,
      'cuisine': cuisine,
      'difficulty': difficulty,
      'ingredients': ingredients,
      'description': description,
      'imageEmoji': imageEmoji,
      'moodTags': moodTags,
      'weatherTags': weatherTags,
      'calorieRange': calorieRange,
      'popularityScore': popularityScore,
    };
  }

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] as String,
      name: json['name'] as String,
      mealTypes: List<String>.from(json['mealTypes']),
      place: List<String>.from(json['place']),
      timeMinutes: json['timeMinutes'] as int,
      budget: json['budget'] as String,
      dietTags: List<String>.from(json['dietTags']),
      cuisine: json['cuisine'] as String,
      difficulty: json['difficulty'] as String,
      ingredients: List<String>.from(json['ingredients']),
      description: json['description'] as String,
      imageEmoji: json['imageEmoji'] as String,
      moodTags: List<String>.from(json['moodTags']),
      weatherTags: List<String>.from(json['weatherTags']),
      calorieRange: json['calorieRange'] as String,
      popularityScore: (json['popularityScore'] as num).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is FoodModel &&
      other.id == id &&
      other.name == name &&
      listEquals(other.mealTypes, mealTypes) &&
      listEquals(other.place, place) &&
      other.timeMinutes == timeMinutes &&
      other.budget == budget &&
      listEquals(other.dietTags, dietTags) &&
      other.cuisine == cuisine &&
      other.difficulty == difficulty &&
      listEquals(other.ingredients, ingredients) &&
      other.description == description &&
      other.imageEmoji == imageEmoji &&
      listEquals(other.moodTags, moodTags) &&
      listEquals(other.weatherTags, weatherTags) &&
      other.calorieRange == calorieRange &&
      other.popularityScore == popularityScore;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      Object.hashAll(mealTypes) ^
      Object.hashAll(place) ^
      timeMinutes.hashCode ^
      budget.hashCode ^
      Object.hashAll(dietTags) ^
      cuisine.hashCode ^
      difficulty.hashCode ^
      Object.hashAll(ingredients) ^
      description.hashCode ^
      imageEmoji.hashCode ^
      Object.hashAll(moodTags) ^
      Object.hashAll(weatherTags) ^
      calorieRange.hashCode ^
      popularityScore.hashCode;
  }
}
