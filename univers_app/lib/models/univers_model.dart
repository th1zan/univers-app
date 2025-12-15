import 'package:flutter/foundation.dart';

/// Modèle représentant un univers thématique.
/// Correspond à la table `universes` dans Supabase.
@immutable
class UniversModel {
  const UniversModel({
    required this.id,
    required this.name,
    required this.slug,
    this.coverImageUrl = '',
    this.translations = const {},
  });

  /// Crée une instance depuis un JSON Supabase.
  factory UniversModel.fromJson(Map<String, dynamic> json) {
    return UniversModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Sans nom',
      coverImageUrl: json['thumbnail_url'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      translations: _parseTranslations(json['translations']),
    );
  }

  final String id;
  final String name;
  final String coverImageUrl;
  final String slug;
  final Map<String, String> translations;

  /// Parse les traductions depuis un JSON dynamique.
  static Map<String, String> _parseTranslations(dynamic json) {
    if (json == null) return {};
    if (json is Map<String, String>) return json;
    if (json is Map) {
      return json
          .map((key, value) => MapEntry(key.toString(), value.toString()));
    }
    return {};
  }

  /// Retourne le nom traduit selon la locale.
  String getLocalizedName(String locale) {
    return translations[locale] ?? name;
  }

  /// Crée une copie avec des valeurs modifiées.
  UniversModel copyWith({
    String? id,
    String? name,
    String? coverImageUrl,
    String? slug,
    Map<String, String>? translations,
  }) {
    return UniversModel(
      id: id ?? this.id,
      name: name ?? this.name,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      slug: slug ?? this.slug,
      translations: translations ?? this.translations,
    );
  }

  /// Convertit en JSON pour Supabase.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbnail_url': coverImageUrl,
      'slug': slug,
      'translations': translations,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UniversModel &&
        other.id == id &&
        other.name == name &&
        other.coverImageUrl == coverImageUrl &&
        other.slug == slug &&
        mapEquals(other.translations, translations);
  }

  @override
  int get hashCode => Object.hash(id, name, coverImageUrl, slug, translations);

  @override
  String toString() => 'UniversModel(id: $id, name: $name, slug: $slug)';
}
