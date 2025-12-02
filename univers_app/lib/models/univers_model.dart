import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class UniversModel {
  @NowaGenerated({'loader': 'auto-constructor'})
  const UniversModel({
    this.id,
    this.name,
    this.coverImageUrl,
    this.folder,
  });

  @NowaGenerated({'loader': 'auto-from-json'})
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

  @NowaGenerated({'loader': 'auto-to-json'})
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbnail_url': coverImageUrl,
      'folder': folder,
    };
  }
}
