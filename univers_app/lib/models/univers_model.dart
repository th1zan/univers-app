class UniversModel {
  const UniversModel({
    this.id,
    this.name,
    this.coverImageUrl,
    this.folder,
  });

  factory UniversModel.fromJson(Map<String, dynamic> json) {
    return UniversModel(
      id: json['id']?.toString(),
      name: json['name'],
      coverImageUrl: json['thumbnail_url'],
      folder: json['folder'],
    );
  }

  final String? id;

  final String? name;

  final String? coverImageUrl;

  final String? folder;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbnail_url': coverImageUrl,
      'folder': folder,
    };
  }
}
