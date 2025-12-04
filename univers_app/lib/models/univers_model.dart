import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class UniversModel {
  @NowaGenerated({'loader': 'auto-constructor'})
  UniversModel({
    this.id,
    this.name,
    this.coverImageUrl,
    this.slug,
    this.translations,
  });

  @NowaGenerated({'loader': 'auto-from-json'})
  factory UniversModel.fromJson(Map<String, dynamic> json) {
    return UniversModel(
      id: json['id']?.toString(),
      name: json['name'],
      coverImageUrl: json['thumbnail_url'],
      slug: json['slug'],
      translations: json['translations'] as Map<String, String>?,
    );
  }

  final String? id;

  final String? name;

  final String? coverImageUrl;

  final String? slug;

  Map<String, String>? translations;

  @NowaGenerated({'loader': 'auto-to-json'})
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbnail_url': coverImageUrl,
      'slug': slug,
      'translations': translations,
    };
  }
}
