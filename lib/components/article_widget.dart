import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleWidget extends StatelessWidget {
  final String title;
  final String body;
  final String imageUrl;
  final String url;
  final String imageAlt;
  final Color color;

  const ArticleWidget({
    super.key,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.url,
    required this.imageAlt,
    required this.color,
  });

  void _launchURL(String url) async {
    try {
      if (Platform.isAndroid) {
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        launchUrl(Uri.parse(url));
      }
    } catch (e) {
      log("error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _launchURL(url);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontFamily: 'Anton',
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                height: MediaQuery.of(context).size.width * 0.75,
                width: MediaQuery.of(context).size.width,
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              height: MediaQuery.of(context).size.width * 0.75,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(seconds: 1),
            ),
          ),
          Row(
            children: [
              const Spacer(),
              Text(
                imageAlt,
                style: const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            'Read more',
            style: TextStyle(color: color.withOpacity(0.8), decoration: TextDecoration.underline, fontSize: 14),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
