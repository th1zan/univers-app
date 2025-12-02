class Universe {
  final String id;
  final String name;
  final String coverImageUrl;
  final int order;

  Universe({
    required this.id,
    required this.name,
    required this.coverImageUrl,
    required this.order,
  });

  factory Universe.fromJson(Map<String, dynamic> json) {
    return Universe(
      id: json['id'],
      name: json['name'],
      coverImageUrl: json['cover_image_url'],
      order: json['order'],
    );
  }
}

class Slide {
  final String id;
  final String universeId;
  final String title;
  final String imageUrl;
  final String animationUrl;
  final int order;

  Slide({
    required this.id,
    required this.universeId,
    required this.title,
    required this.imageUrl,
    required this.animationUrl,
    required this.order,
  });

  factory Slide.fromJson(Map<String, dynamic> json) {
    return Slide(
      id: json['id'],
      universeId: json['universe_id'],
      title: json['title'],
      imageUrl: json['image_url'],
      animationUrl: json['animation_url'],
      order: json['order'],
    );
  }
}