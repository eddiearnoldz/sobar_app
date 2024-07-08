import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleWidget extends StatelessWidget {
  final String title;
  final String body;
  final String imageUrl;
  final String url;
  final String imageAlt;
  final Color color;

  const ArticleWidget({
    Key? key,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.url,
    required this.imageAlt,
    required this.color,
  }) : super(key: key);

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
              color: Theme.of(context).colorScheme.onPrimary,
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
              Spacer(),
              Text(
                imageAlt,
                style: const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            'Read more',
            style: TextStyle(color: color.withOpacity(0.8), decoration: TextDecoration.underline, fontSize: 12),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
