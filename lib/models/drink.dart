import 'package:cloud_firestore/cloud_firestore.dart';

class Drink {
  final String name;
  final String abv;
  final double averageRating;
  final String imageUrl;
  final String type;
  final double ratingsCount;
  final List<Rating> ratings;

  Drink({
    required this.name,
    required this.abv,
    required this.averageRating,
    required this.imageUrl,
    required this.type,
    required this.ratingsCount,
    required this.ratings,
  });

  factory Drink.fromJson(Map<String, dynamic> json) {
    return Drink(
      name: json['name'],
      abv: json['abv'],
      averageRating: (json['averageRating'] as num).toDouble(),
      imageUrl: json['imageUrl'],
      type: json['type'],
      ratingsCount: (json['ratingsCount'] as num).toDouble(),
      ratings: (json['ratings'] as List<dynamic>).map((rating) => Rating.fromJson(rating as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'abv': abv,
      'averageRating': averageRating,
      'imageUrl': imageUrl,
      'type': type,
      'ratingsCount': ratingsCount,
      'ratings': ratings.map((rating) => rating.toJson()).toList(),
    };
  }
}

class Rating {
  final double rating;
  final DocumentReference userRef;

  Rating({
    required this.rating,
    required this.userRef,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rating: (json['rating'] as num).toDouble(),
      userRef: json['userRef'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'userRef': userRef,
    };
  }
}
