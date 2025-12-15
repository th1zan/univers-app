import 'package:flutter/foundation.dart';

/// Modèle représentant un slide (image/animation) d'un univers.
/// Correspond à la table `slides` dans Supabase.
@immutable
class UniversAssetModel {
  const UniversAssetModel({
    required this.id,
    required this.universId,
    required this.title,
    required this.imageUrl,
    required this.order,
    this.animationUrl,
    this.translations = const {},
  });

  /// Crée une instance depuis un JSON Supabase.
  factory UniversAssetModel.fromJson(Map<String, dynamic> json) {
    return UniversAssetModel(
      id: json['id']?.toString() ?? '',
      universId: json['univers_id']?.toString() ?? '',
      title: json['display_name'] as String? ?? 'Sans titre',
      imageUrl: json['image_name'] as String? ?? '',
      animationUrl: json['animation_url'] as String?,
      order: json['sort_order'] as int? ?? 0,
      translations: _parseTranslations(json['translations']),
    );
  }

  final String id;
  final String universId;
  final String title;
  final String imageUrl;
  final String? animationUrl;
  final int order;
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

  /// Retourne le titre traduit selon la locale.
  String getLocalizedTitle(String locale) {
    return translations[locale] ?? title;
  }

  /// Crée une copie avec des valeurs modifiées.
  UniversAssetModel copyWith({
    String? id,
    String? universId,
    String? title,
    String? imageUrl,
    String? animationUrl,
    int? order,
    Map<String, String>? translations,
  }) {
    return UniversAssetModel(
      id: id ?? this.id,
      universId: universId ?? this.universId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      animationUrl: animationUrl ?? this.animationUrl,
      order: order ?? this.order,
      translations: translations ?? this.translations,
    );
  }

  /// Convertit en JSON pour Supabase.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'univers_id': universId,
      'display_name': title,
      'image_name': imageUrl,
      'animation_url': animationUrl,
      'sort_order': order,
      'translations': translations,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UniversAssetModel &&
        other.id == id &&
        other.universId == universId &&
        other.title == title &&
        other.imageUrl == imageUrl &&
        other.animationUrl == animationUrl &&
        other.order == order &&
        mapEquals(other.translations, translations);
  }

  @override
  int get hashCode => Object.hash(
        id,
        universId,
        title,
        imageUrl,
        animationUrl,
        order,
        translations,
      );

  @override
  String toString() =>
      'UniversAssetModel(id: $id, title: $title, order: $order)';
}
