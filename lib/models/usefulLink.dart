class UsefulLink {
  final String title;
  final String paragraph;
  final String urlLink;

  UsefulLink({
    required this.title,
    required this.paragraph,
    required this.urlLink,
  });

  factory UsefulLink.fromJson(Map<String, dynamic> json) {
    return UsefulLink(
      title: json['title'] ?? "",
      paragraph: json['body'] ?? "",
      urlLink: json['link_url'] ?? "",
    );
  }
}
