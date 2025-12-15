import 'package:flutter_test/flutter_test.dart';
import 'package:univers_app/models/univers_asset_model.dart';

void main() {
  group('UniversAssetModel', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        const model = UniversAssetModel(
          id: '123',
          universId: 'univ-456',
          title: 'Test Asset',
          imageUrl: 'image.png',
          order: 1,
        );

        expect(model.id, '123');
        expect(model.universId, 'univ-456');
        expect(model.title, 'Test Asset');
        expect(model.imageUrl, 'image.png');
        expect(model.order, 1);
        expect(model.animationUrl, isNull);
        expect(model.translations, isEmpty);
      });

      test('creates instance with all fields', () {
        const model = UniversAssetModel(
          id: '123',
          universId: 'univ-456',
          title: 'Test Asset',
          imageUrl: 'image.png',
          animationUrl: 'animation.mp4',
          order: 1,
          translations: {'fr': 'Asset Test', 'en': 'Test Asset'},
        );

        expect(model.animationUrl, 'animation.mp4');
        expect(model.translations, hasLength(2));
      });
    });

    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {
          'id': '456',
          'univers_id': 'univ-789',
          'display_name': 'JSON Asset',
          'image_name': 'json-image.png',
          'animation_url': 'anim.mp4',
          'sort_order': 5,
        };

        final model = UniversAssetModel.fromJson(json);

        expect(model.id, '456');
        expect(model.universId, 'univ-789');
        expect(model.title, 'JSON Asset');
        expect(model.imageUrl, 'json-image.png');
        expect(model.animationUrl, 'anim.mp4');
        expect(model.order, 5);
      });

      test('handles null id by converting to empty string', () {
        final json = {
          'id': null,
          'univers_id': 'univ-123',
          'display_name': 'Test',
          'image_name': 'test.png',
          'sort_order': 0,
        };

        final model = UniversAssetModel.fromJson(json);

        expect(model.id, '');
      });

      test('handles missing fields with defaults', () {
        final json = <String, dynamic>{
          'id': '789',
          'univers_id': 'univ-123',
        };

        final model = UniversAssetModel.fromJson(json);

        expect(model.id, '789');
        expect(model.title, 'Sans titre');
        expect(model.imageUrl, '');
        expect(model.animationUrl, isNull);
        expect(model.order, 0);
      });

      test('parses translations from Map<String, dynamic>', () {
        final json = {
          'id': '123',
          'univers_id': 'univ-456',
          'display_name': 'Test',
          'image_name': 'test.png',
          'sort_order': 0,
          'translations': {'fr': 'Français', 'en': 'English'},
        };

        final model = UniversAssetModel.fromJson(json);

        expect(model.translations['fr'], 'Français');
        expect(model.translations['en'], 'English');
      });

      test('handles null translations', () {
        final json = {
          'id': '123',
          'univers_id': 'univ-456',
          'display_name': 'Test',
          'image_name': 'test.png',
          'sort_order': 0,
          'translations': null,
        };

        final model = UniversAssetModel.fromJson(json);

        expect(model.translations, isEmpty);
      });

      test('converts non-string translation values to strings', () {
        final json = {
          'id': '123',
          'univers_id': 'univ-456',
          'display_name': 'Test',
          'image_name': 'test.png',
          'sort_order': 0,
          'translations': {'fr': 123, 'en': true},
        };

        final model = UniversAssetModel.fromJson(json);

        expect(model.translations['fr'], '123');
        expect(model.translations['en'], 'true');
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        const model = UniversAssetModel(
          id: '123',
          universId: 'univ-456',
          title: 'Test Asset',
          imageUrl: 'image.png',
          animationUrl: 'anim.mp4',
          order: 3,
          translations: {'fr': 'Test FR'},
        );

        final json = model.toJson();

        expect(json['id'], '123');
        expect(json['univers_id'], 'univ-456');
        expect(json['display_name'], 'Test Asset');
        expect(json['image_name'], 'image.png');
        expect(json['animation_url'], 'anim.mp4');
        expect(json['sort_order'], 3);
        expect(json['translations'], {'fr': 'Test FR'});
      });

      test('serializes null animationUrl', () {
        const model = UniversAssetModel(
          id: '123',
          universId: 'univ-456',
          title: 'Test Asset',
          imageUrl: 'image.png',
          order: 0,
        );

        final json = model.toJson();

        expect(json['animation_url'], isNull);
      });
    });

    group('getLocalizedTitle', () {
      test('returns translation when available', () {
        const model = UniversAssetModel(
          id: '123',
          universId: 'univ-456',
          title: 'Default Title',
          imageUrl: 'image.png',
          order: 0,
          translations: {'fr': 'Titre Français', 'en': 'English Title'},
        );

        expect(model.getLocalizedTitle('fr'), 'Titre Français');
        expect(model.getLocalizedTitle('en'), 'English Title');
      });

      test('returns default title when translation not available', () {
        const model = UniversAssetModel(
          id: '123',
          universId: 'univ-456',
          title: 'Default Title',
          imageUrl: 'image.png',
          order: 0,
          translations: {'fr': 'Titre Français'},
        );

        expect(model.getLocalizedTitle('de'), 'Default Title');
        expect(model.getLocalizedTitle('es'), 'Default Title');
      });

      test('returns default title when translations empty', () {
        const model = UniversAssetModel(
          id: '123',
          universId: 'univ-456',
          title: 'Default Title',
          imageUrl: 'image.png',
          order: 0,
        );

        expect(model.getLocalizedTitle('fr'), 'Default Title');
      });
    });

    group('copyWith', () {
      test('copies all fields when no arguments provided', () {
        const original = UniversAssetModel(
          id: '123',
          universId: 'univ-456',
          title: 'Original',
          imageUrl: 'original.png',
          animationUrl: 'original.mp4',
          order: 1,
          translations: {'fr': 'Original FR'},
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
        expect(identical(copy, original), isFalse);
      });

      test('updates specified fields only', () {
        const original = UniversAssetModel(
          id: '123',
          universId: 'univ-456',
          title: 'Original',
          imageUrl: 'original.png',
          order: 1,
        );

        final copy = original.copyWith(
          title: 'Updated',
          order: 5,
        );

        expect(copy.id, '123');
        expect(copy.universId, 'univ-456');
        expect(copy.title, 'Updated');
        expect(copy.imageUrl, 'original.png');
        expect(copy.order, 5);
      });

      test('can update translations', () {
        const original = UniversAssetModel(
          id: '123',
          universId: 'univ-456',
          title: 'Original',
          imageUrl: 'original.png',
          order: 0,
        );

        final copy = original.copyWith(
          translations: {'fr': 'Nouveau', 'en': 'New'},
        );

        expect(copy.translations, hasLength(2));
        expect(copy.translations['fr'], 'Nouveau');
      });
    });

    group('equality', () {
      test('equal instances have same hashCode', () {
        const model1 = UniversAssetModel(
          id: '123',
          universId: 'univ-456',
          title: 'Test',
          imageUrl: 'test.png',
          order: 0,
        );

        const model2 = UniversAssetModel(
          id: '123',
          universId: 'univ-456',
          title: 'Test',
          imageUrl: 'test.png',
          order: 0,
        );

        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('different instances are not equal', () {
        const model1 = UniversAssetModel(
          id: '123',
          universId: 'univ-456',
          title: 'Test',
          imageUrl: 'test.png',
          order: 0,
        );

        const model2 = UniversAssetModel(
          id: '789',
          universId: 'univ-456',
          title: 'Test',
          imageUrl: 'test.png',
          order: 0,
        );

        expect(model1, isNot(equals(model2)));
      });

      test('identical instances are equal', () {
        const model = UniversAssetModel(
          id: '123',
          universId: 'univ-456',
          title: 'Test',
          imageUrl: 'test.png',
          order: 0,
        );

        expect(model, equals(model));
      });

      test('instances with different translations are not equal', () {
        const model1 = UniversAssetModel(
          id: '123',
          universId: 'univ-456',
          title: 'Test',
          imageUrl: 'test.png',
          order: 0,
          translations: {'fr': 'A'},
        );

        const model2 = UniversAssetModel(
          id: '123',
          universId: 'univ-456',
          title: 'Test',
          imageUrl: 'test.png',
          order: 0,
          translations: {'fr': 'B'},
        );

        expect(model1, isNot(equals(model2)));
      });
    });

    group('toString', () {
      test('returns readable representation', () {
        const model = UniversAssetModel(
          id: '123',
          universId: 'univ-456',
          title: 'Test Asset',
          imageUrl: 'test.png',
          order: 5,
        );

        expect(
          model.toString(),
          'UniversAssetModel(id: 123, title: Test Asset, order: 5)',
        );
      });
    });
  });
}
