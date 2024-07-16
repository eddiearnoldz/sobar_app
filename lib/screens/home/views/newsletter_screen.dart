import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sobar_app/components/article_widget.dart';
import 'package:sobar_app/models/newsletter.dart';

class NewsletterScreen extends StatelessWidget {
  const NewsletterScreen({super.key});

  Future<Newsletter> fetchNewsletter() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('newsletter').limit(1).get();
    if (querySnapshot.docs.isEmpty) {
      throw StateError('No documents found in the collection');
    }
    final doc = querySnapshot.docs.first;
    return Newsletter.fromFirestore(doc);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Newsletter>(
      future: fetchNewsletter(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        } else {
          final newsletter = snapshot.data!;
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primary,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        newsletter.newsletterTitle.toUpperCase(),
                        style: TextStyle(color: Theme.of(context).colorScheme.error, fontFamily: 'Anton', fontSize: 30),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: newsletter.mainImageUrl,
                          placeholder: (context, url) => Container(
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                            height: MediaQuery.of(context).size.width,
                            width: MediaQuery.of(context).size.width,
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          height: MediaQuery.of(context).size.width,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 300),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(newsletter.newsletterIntro, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 16)),
                      const SizedBox(height: 15),
                      ArticleWidget(
                        title: newsletter.articleOneTitle,
                        body: newsletter.articleOneBody,
                        imageUrl: newsletter.articleOneImageUrl,
                        url: newsletter.articleOneUrl,
                        imageAlt: newsletter.articleOneImageAlt,
                        color: Colors.red,
                      ),
                      ArticleWidget(
                        title: newsletter.articleTwoTitle,
                        body: newsletter.articleTwoBody,
                        imageUrl: newsletter.articleTwoImageUrl,
                        url: newsletter.articleTwoUrl,
                        imageAlt: newsletter.articleTwoImageAlt,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
