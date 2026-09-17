import 'package:flutter_test/flutter_test.dart';
import 'package:silenti/core/models/user.dart';

void main() {
  group('User.fromMap', () {
    test('reads mode_group (the actual DB column name)', () {
      final user = User.fromMap({
        'id': 1,
        'name': 'Ada',
        'email': 'ada@example.com',
        'mode': 1,
        'mode_group': 2,
        'password': 'secret',
      });

      expect(user.group, 2);
    });

    test('falls back to a legacy "group" key when mode_group is absent', () {
      final user = User.fromMap({
        'id': 1,
        'name': 'Ada',
        'email': 'ada@example.com',
        'mode': 1,
        'group': 3,
        'password': 'secret',
      });

      expect(user.group, 3);
    });

    test('defaults mode/group to 1 and strings to empty when missing', () {
      final user = User.fromMap({'id': 1});

      expect(user.mode, 1);
      expect(user.group, 1);
      expect(user.name, '');
      expect(user.email, '');
      expect(user.password, '');
    });

    test('id is always stringified', () {
      final user = User.fromMap({'id': 1});

      expect(user.id, '1');
    });
  });

  group('User.toMap', () {
    test('round-trips every field', () {
      final user = User(
        id: '1',
        name: 'Ada',
        email: 'ada@example.com',
        mode: 1,
        group: 2,
        password: 'secret',
      );

      final map = user.toMap();

      expect(map['id'], '1');
      expect(map['name'], 'Ada');
      expect(map['email'], 'ada@example.com');
      expect(map['mode'], 1);
      expect(map['group'], 2);
      expect(map['password'], 'secret');
    });
  });
}
