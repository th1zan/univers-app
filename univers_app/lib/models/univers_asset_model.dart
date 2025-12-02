import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class UniversAssetModel {
  @NowaGenerated({'loader': 'auto-constructor'})
  const UniversAssetModel({
    this.id,
    this.universId,
    this.title,
    this.imageUrl,
    this.animationUrl,
    this.order,
  });

  @NowaGenerated({'loader': 'auto-from-json'})
  factory UniversAssetModel.fromJson(Map<String, dynamic> json) {
    return UniversAssetModel(
      id: json['id'],
      universId: json['univers_folder'],
      title: json['display_name'],
      imageUrl: json['image_name'],
      animationUrl: null,  // Not in table yet
      order: json['sort_order'],
    );
  }

  final String? id;

  final String? universId;

  final String? title;

  final String? imageUrl;

  final String? animationUrl;

  final int? order;

  @NowaGenerated({'loader': 'auto-to-json'})
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'univers_folder': universId,
      'display_name': title,
      'image_name': imageUrl,
      'sort_order': order,
      // 'animation_url': animationUrl,  // Not in table
    };
  }
}
