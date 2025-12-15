import 'package:flutter_test/flutter_test.dart';
import 'package:univers_app/models/univers_model.dart';

void main() {
  group('UniversModel', () {
    group('constructor', () {
      test('creates instance with required fields', () {
        const model = UniversModel(
          id: '123',
          name: 'Test Universe',
          slug: 'test-universe',
        );

        expect(model.id, '123');
        expect(model.name, 'Test Universe');
        expect(model.slug, 'test-universe');
        expect(model.coverImageUrl, '');
        expect(model.translations, isEmpty);
      });

      test('creates instance with all fields', () {
        const model = UniversModel(
          id: '123',
          name: 'Test Universe',
          slug: 'test-universe',
          coverImageUrl: 'https://example.com/image.png',
          translations: {'fr': 'Univers Test', 'en': 'Test Universe'},
        );

        expect(model.coverImageUrl, 'https://example.com/image.png');
        expect(model.translations, hasLength(2));
      });
    });

    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {
          'id': '456',
          'name': 'JSON Universe',
          'slug': 'json-universe',
          'thumbnail_url': 'https://example.com/thumb.png',
        };

        final model = UniversModel.fromJson(json);

        expect(model.id, '456');
        expect(model.name, 'JSON Universe');
        expect(model.slug, 'json-universe');
        expect(model.coverImageUrl, 'https://example.com/thumb.png');
      });

      test('handles null id by converting to empty string', () {
        final json = {
          'id': null,
          'name': 'Test',
          'slug': 'test',
        };

        final model = UniversModel.fromJson(json);

        expect(model.id, '');
      });

      test('handles missing fields with defaults', () {
        final json = <String, dynamic>{
          'id': '789',
        };

        final model = UniversModel.fromJson(json);

        expect(model.id, '789');
        expect(model.name, 'Sans nom');
        expect(model.slug, '');
        expect(model.coverImageUrl, '');
      });

      test('parses translations from Map<String, dynamic>', () {
        final json = {
          'id': '123',
          'name': 'Test',
          'slug': 'test',
          'translations': {'fr': 'Français', 'en': 'English'},
        };

        final model = UniversModel.fromJson(json);

        expect(model.translations['fr'], 'Français');
        expect(model.translations['en'], 'English');
      });

      test('handles null translations', () {
        final json = {
          'id': '123',
          'name': 'Test',
          'slug': 'test',
          'translations': null,
        };

        final model = UniversModel.fromJson(json);

        expect(model.translations, isEmpty);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        const model = UniversModel(
          id: '123',
          name: 'Test Universe',
          slug: 'test-universe',
          coverImageUrl: 'https://example.com/image.png',
          translations: {'fr': 'Test FR'},
        );

        final json = model.toJson();

        expect(json['id'], '123');
        expect(json['name'], 'Test Universe');
        expect(json['slug'], 'test-universe');
        expect(json['thumbnail_url'], 'https://example.com/image.png');
        expect(json['translations'], {'fr': 'Test FR'});
      });
    });

    group('getLocalizedName', () {
      test('returns translation when available', () {
        const model = UniversModel(
          id: '123',
          name: 'Default Name',
          slug: 'test',
          translations: {'fr': 'Nom Français', 'en': 'English Name'},
        );

        expect(model.getLocalizedName('fr'), 'Nom Français');
        expect(model.getLocalizedName('en'), 'English Name');
      });

      test('returns default name when translation not available', () {
        const model = UniversModel(
          id: '123',
          name: 'Default Name',
          slug: 'test',
          translations: {'fr': 'Nom Français'},
        );

        expect(model.getLocalizedName('de'), 'Default Name');
        expect(model.getLocalizedName('es'), 'Default Name');
      });
    });

    group('copyWith', () {
      test('copies all fields when no arguments provided', () {
        const original = UniversModel(
          id: '123',
          name: 'Original',
          slug: 'original',
          coverImageUrl: 'https://example.com/original.png',
          translations: {'fr': 'Original FR'},
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
        expect(identical(copy, original), isFalse);
      });

      test('updates specified fields only', () {
        const original = UniversModel(
          id: '123',
          name: 'Original',
          slug: 'original',
        );

        final copy = original.copyWith(
          name: 'Updated',
          coverImageUrl: 'https://example.com/new.png',
        );

        expect(copy.id, '123');
        expect(copy.name, 'Updated');
        expect(copy.slug, 'original');
        expect(copy.coverImageUrl, 'https://example.com/new.png');
      });
    });

    group('equality', () {
      test('equal instances have same hashCode', () {
        const model1 = UniversModel(
          id: '123',
          name: 'Test',
          slug: 'test',
        );

        const model2 = UniversModel(
          id: '123',
          name: 'Test',
          slug: 'test',
        );

        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('different instances are not equal', () {
        const model1 = UniversModel(
          id: '123',
          name: 'Test',
          slug: 'test',
        );

        const model2 = UniversModel(
          id: '456',
          name: 'Test',
          slug: 'test',
        );

        expect(model1, isNot(equals(model2)));
      });

      test('identical instances are equal', () {
        const model = UniversModel(
          id: '123',
          name: 'Test',
          slug: 'test',
        );

        expect(model, equals(model));
      });
    });

    group('toString', () {
      test('returns readable representation', () {
        const model = UniversModel(
          id: '123',
          name: 'Test Universe',
          slug: 'test-universe',
        );

        expect(
          model.toString(),
          'UniversModel(id: 123, name: Test Universe, slug: test-universe)',
        );
      });
    });
  });
}
