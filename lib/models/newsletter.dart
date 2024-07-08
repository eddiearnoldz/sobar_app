import 'package:cloud_firestore/cloud_firestore.dart';

class Newsletter {
  final String articleOneBody;
  final String articleOneImageUrl;
  final String articleOneImageAlt;
  final String articleOneTitle;
  final String articleOneUrl;
  final String articleTwoBody;
  final String articleTwoImageUrl;
  final String articleTwoImageAlt;
  final String articleTwoTitle;
  final String articleTwoUrl;
  final String author;
  final DateTime date;
  final String mainImageUrl;
  final String newsletterIntro;
  final String newsletterTitle;

  Newsletter({
    required this.articleOneBody,
    required this.articleOneImageUrl,
    required this.articleOneImageAlt,
    required this.articleOneTitle,
    required this.articleOneUrl,
    required this.articleTwoBody,
    required this.articleTwoImageUrl,
    required this.articleTwoImageAlt,
    required this.articleTwoTitle,
    required this.articleTwoUrl,
    required this.author,
    required this.date,
    required this.mainImageUrl,
    required this.newsletterIntro,
    required this.newsletterTitle,
  });

  factory Newsletter.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('Missing data for newsletter document ID: ${doc.id}');
    }
    return Newsletter(
      articleOneBody: data['articleOneBody'] ?? '',
      articleOneImageUrl: data['articleOneImageUrl'] ?? '',
      articleOneImageAlt: data['articleOneImageAlt'] ?? '',
      articleOneTitle: data['articleOneTitle'] ?? '',
      articleOneUrl: data['articleOneUrl'] ?? '',
      articleTwoBody: data['articleTwoBody'] ?? '',
      articleTwoImageUrl: data['articleTwoImageUrl'] ?? '',
      articleTwoImageAlt: data['articleTwoImageAlt'] ?? '',
      articleTwoTitle: data['articleTwoTitle'] ?? '',
      articleTwoUrl: data['articleTwoUrl'] ?? '',
      author: data['author'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      mainImageUrl: data['mainImageUrl'] ?? '',
      newsletterIntro: data['newsletterIntro'] ?? '',
      newsletterTitle: data['newsletterTitle'] ?? '',
    );
  }
}
