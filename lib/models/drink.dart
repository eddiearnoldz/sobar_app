import 'package:cloud_firestore/cloud_firestore.dart';

class Drink {
  String id;
  final String name, abv, imageUrl, type, category;
  final bool isVegan, isGlutenFree;
  final double ratingsCount, averageRating, calories;
  List<Review> reviews;
  String? buyUrl;

  Drink({
    required this.name,
    required this.abv,
    required this.isVegan,
    required this.isGlutenFree,
    required this.averageRating,
    required this.imageUrl,
    required this.type,
    required this.category,
    required this.ratingsCount,
    required this.calories,
    this.buyUrl,
    this.id = "",
    this.reviews = const [],
  });

  Drink.fromJson(this.id, Map<String, dynamic> json)
      : name = json['name'] ?? "",
        abv = json['abv'] ?? "",
        isVegan = json['isVegan'] ?? false,
        isGlutenFree = json['isGlutenFree'] ?? false,
        averageRating = (json['averageRating'] as num).toDouble(),
        calories = (json['calories'] as num).toDouble(),
        imageUrl = json['imageUrl'],
        buyUrl = json['buyUrl'],
        type = json['type'],
        category = json['category'] ?? "",
        ratingsCount = (json['ratingsCount'] as num).toDouble(),
        reviews = [];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'abv': abv,
      'isVegan': isVegan,
      'isGlutenFree': isGlutenFree,
      'calories': calories,
      'averageRating': averageRating,
      'imageUrl': imageUrl,
      'buyUrl': buyUrl,
      'type': type,
      'category': category,
      'ratingsCount': ratingsCount,
      'ratings': reviews.map((review) => review.toJson()).toList(),
    };
  }

  Future<void> fetchReviews() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('drinks').doc(id).collection('reviews').get();
    reviews = snapshot.docs.map((doc) => Review.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }
}

class Review {
  final double rating;
  final DocumentReference userRef;
  final String writtenReview;
  final Timestamp date;

  Review({
    required this.rating,
    required this.userRef,
    required this.writtenReview,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      rating: (json['rating'] as num).toDouble(),
      userRef: json['userRef'],
      writtenReview: json['writtenReview'] ?? "",
      date: json['date'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'userRef': userRef,
      'writtenReview': writtenReview,
      'date': date,
    };
  }
}
