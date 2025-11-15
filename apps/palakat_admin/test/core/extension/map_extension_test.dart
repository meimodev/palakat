import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_admin/core/extension/extension.dart';

void main() {
  group('MapExtension - stripUnchangedFields', () {
    test('should strip unchanged primitive values', () {
      final original = {
        'name': 'John',
        'age': 30,
        'active': true,
      };

      final updated = {
        'name': 'John',
        'age': 31, // Changed
        'active': true,
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {'age': 31});
    });

    test('should include new fields', () {
      final original = {
        'name': 'John',
      };

      final updated = {
        'name': 'John',
        'age': 30, // New field
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {'age': 30});
    });

    test('should handle nested map changes', () {
      final original = {
        'name': 'John',
        'address': {
          'street': '123 Main St',
          'city': 'New York',
          'zip': '10001',
        },
      };

      final updated = {
        'name': 'John',
        'address': {
          'street': '123 Main St',
          'city': 'Boston', // Changed
          'zip': '10001',
        },
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {
        'address': {
          'street': '123 Main St',
          'city': 'Boston',
          'zip': '10001',
        },
      });
    });

    test('should handle unchanged nested maps', () {
      final original = {
        'name': 'John',
        'address': {
          'street': '123 Main St',
          'city': 'New York',
        },
      };

      final updated = {
        'name': 'Jane', // Changed
        'address': {
          'street': '123 Main St',
          'city': 'New York',
        },
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {'name': 'Jane'});
    });

    test('should handle list changes', () {
      final original = {
        'name': 'John',
        'tags': ['developer', 'flutter'],
      };

      final updated = {
        'name': 'John',
        'tags': ['developer', 'flutter', 'dart'], // Changed
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {
        'tags': ['developer', 'flutter', 'dart'],
      });
    });

    test('should handle unchanged lists', () {
      final original = {
        'name': 'John',
        'tags': ['developer', 'flutter'],
      };

      final updated = {
        'name': 'Jane', // Changed
        'tags': ['developer', 'flutter'],
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {'name': 'Jane'});
    });

    test('should handle list of maps', () {
      final original = {
        'name': 'John',
        'phones': [
          {'type': 'home', 'number': '123-4567'},
          {'type': 'work', 'number': '890-1234'},
        ],
      };

      final updated = {
        'name': 'John',
        'phones': [
          {'type': 'home', 'number': '123-4567'},
          {'type': 'work', 'number': '999-9999'}, // Changed
        ],
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {
        'phones': [
          {'type': 'home', 'number': '123-4567'},
          {'type': 'work', 'number': '999-9999'},
        ],
      });
    });

    test('should handle deeply nested structures', () {
      final original = {
        'user': {
          'profile': {
            'name': 'John',
            'settings': {
              'theme': 'dark',
              'notifications': true,
            },
          },
        },
        'status': 'active',
      };

      final updated = {
        'user': {
          'profile': {
            'name': 'John',
            'settings': {
              'theme': 'light', // Changed
              'notifications': true,
            },
          },
        },
        'status': 'active',
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {
        'user': {
          'profile': {
            'name': 'John',
            'settings': {
              'theme': 'light',
              'notifications': true,
            },
          },
        },
      });
    });

    test('should handle null values', () {
      final original = {
        'name': 'John',
        'email': 'john@example.com',
      };

      final updated = {
        'name': 'John',
        'email': null, // Changed to null
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {'email': null});
    });

    test('should handle complex mixed structure', () {
      final original = {
        'id': 1,
        'name': 'Project A',
        'team': {
          'lead': 'John',
          'members': ['Alice', 'Bob'],
        },
        'tags': ['urgent', 'frontend'],
      };

      final updated = {
        'id': 1,
        'name': 'Project B', // Changed
        'team': {
          'lead': 'John',
          'members': ['Alice', 'Bob', 'Charlie'], // Changed
        },
        'tags': ['urgent', 'frontend'],
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {
        'name': 'Project B',
        'team': {
          'lead': 'John',
          'members': ['Alice', 'Bob', 'Charlie'],
        },
      });
    });

    test('should return empty map when nothing changed', () {
      final original = {
        'name': 'John',
        'age': 30,
        'address': {
          'city': 'New York',
        },
      };

      final updated = {
        'name': 'John',
        'age': 30,
        'address': {
          'city': 'New York',
        },
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {});
    });

    test('should remove updatedAt at root level', () {
      final original = {
        'name': 'John',
        'age': 30,
        'updatedAt': '2025-01-01T00:00:00Z',
      };

      final updated = {
        'name': 'Jane', // Changed
        'age': 30,
        'updatedAt': '2025-01-02T00:00:00Z', // Should be removed
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {'name': 'Jane'});
      expect(result.containsKey('updatedAt'), false);
    });

    test('should remove updatedAt in nested maps', () {
      final original = {
        'name': 'John',
        'profile': {
          'bio': 'Developer',
          'updatedAt': '2025-01-01T00:00:00Z',
        },
      };

      final updated = {
        'name': 'John',
        'profile': {
          'bio': 'Senior Developer', // Changed
          'updatedAt': '2025-01-02T00:00:00Z', // Should be removed
        },
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {
        'profile': {
          'bio': 'Senior Developer',
        },
      });
      expect((result['profile'] as Map).containsKey('updatedAt'), false);
    });

    test('should remove updatedAt in deeply nested structures', () {
      final original = {
        'user': {
          'profile': {
            'name': 'John',
            'updatedAt': '2025-01-01T00:00:00Z',
            'settings': {
              'theme': 'dark',
              'updatedAt': '2025-01-01T00:00:00Z',
            },
          },
          'updatedAt': '2025-01-01T00:00:00Z',
        },
      };

      final updated = {
        'user': {
          'profile': {
            'name': 'Jane', // Changed
            'updatedAt': '2025-01-02T00:00:00Z',
            'settings': {
              'theme': 'dark',
              'updatedAt': '2025-01-02T00:00:00Z',
            },
          },
          'updatedAt': '2025-01-02T00:00:00Z',
        },
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {
        'user': {
          'profile': {
            'name': 'Jane',
            'settings': {
              'theme': 'dark',
            },
          },
        },
      });
      
      final user = result['user'] as Map;
      final profile = user['profile'] as Map;
      final settings = profile['settings'] as Map;
      
      expect(user.containsKey('updatedAt'), false);
      expect(profile.containsKey('updatedAt'), false);
      expect(settings.containsKey('updatedAt'), false);
    });

    test('should remove updatedAt in list of maps', () {
      final original = {
        'items': [
          {'id': 1, 'name': 'Item 1', 'updatedAt': '2025-01-01T00:00:00Z'},
          {'id': 2, 'name': 'Item 2', 'updatedAt': '2025-01-01T00:00:00Z'},
        ],
      };

      final updated = {
        'items': [
          {'id': 1, 'name': 'Updated Item 1', 'updatedAt': '2025-01-02T00:00:00Z'}, // Changed
          {'id': 2, 'name': 'Item 2', 'updatedAt': '2025-01-02T00:00:00Z'},
        ],
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {
        'items': [
          {'id': 1, 'name': 'Updated Item 1'},
          {'id': 2, 'name': 'Item 2'},
        ],
      });

      final items = result['items'] as List;
      for (final item in items) {
        expect((item as Map).containsKey('updatedAt'), false);
      }
    });

    test('should remove updatedAt when adding new field', () {
      final original = {
        'name': 'John',
      };

      final updated = {
        'name': 'John',
        'age': 30, // New field
        'updatedAt': '2025-01-02T00:00:00Z', // Should be removed
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {'age': 30});
      expect(result.containsKey('updatedAt'), false);
    });

    test('should remove createdAt at root level', () {
      final original = {
        'name': 'John',
        'age': 30,
        'createdAt': '2025-01-01T00:00:00Z',
      };

      final updated = {
        'name': 'Jane', // Changed
        'age': 30,
        'createdAt': '2025-01-01T00:00:00Z', // Should be removed
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {'name': 'Jane'});
      expect(result.containsKey('createdAt'), false);
    });

    test('should remove both updatedAt and createdAt in nested structures', () {
      final original = {
        'user': {
          'name': 'John',
          'createdAt': '2025-01-01T00:00:00Z',
          'updatedAt': '2025-01-01T00:00:00Z',
        },
      };

      final updated = {
        'user': {
          'name': 'Jane', // Changed
          'createdAt': '2025-01-01T00:00:00Z',
          'updatedAt': '2025-01-02T00:00:00Z',
        },
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {
        'user': {
          'name': 'Jane',
        },
      });

      final user = result['user'] as Map;
      expect(user.containsKey('createdAt'), false);
      expect(user.containsKey('updatedAt'), false);
    });

    test('should remove createdAt in list of maps', () {
      final original = {
        'items': [
          {'id': 1, 'name': 'Item 1', 'createdAt': '2025-01-01T00:00:00Z'},
        ],
      };

      final updated = {
        'items': [
          {'id': 1, 'name': 'Updated Item 1', 'createdAt': '2025-01-01T00:00:00Z'}, // Changed
        ],
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {
        'items': [
          {'id': 1, 'name': 'Updated Item 1'},
        ],
      });

      final items = result['items'] as List;
      for (final item in items) {
        expect((item as Map).containsKey('createdAt'), false);
      }
    });

    test('should not include fields that only exist in original (removed fields)', () {
      final original = {
        'name': 'John',
        'age': 30,
        'email': 'john@example.com', // This field was removed
        'phone': '123-4567', // This field was removed
      };

      final updated = {
        'name': 'Jane', // Changed
        'age': 30,
        // email and phone removed
      };

      final result = updated.stripUnchangedFields(original);

      // Should only include changed field, not removed fields
      expect(result, {'name': 'Jane'});
      expect(result.containsKey('email'), false);
      expect(result.containsKey('phone'), false);
    });

    test('should not include nested fields that only exist in original', () {
      final original = {
        'user': {
          'name': 'John',
          'email': 'john@example.com',
          'phone': '123-4567',
        },
      };

      final updated = {
        'user': {
          'name': 'Jane', // Changed
          'email': 'john@example.com',
          // phone removed
        },
      };

      final result = updated.stripUnchangedFields(original);

      // Should only include the changed nested object
      // The nested comparison will show user object changed
      expect(result, {
        'user': {
          'name': 'Jane',
          'email': 'john@example.com',
        },
      });
      
      final user = result['user'] as Map;
      expect(user.containsKey('phone'), false);
    });

    test('should handle mix of added, removed, and changed fields', () {
      final original = {
        'id': 1,
        'name': 'John',
        'oldField': 'will be removed',
        'status': 'active',
      };

      final updated = {
        'id': 1,
        'name': 'Jane', // Changed
        'newField': 'added', // New
        'status': 'active',
        // oldField removed
      };

      final result = updated.stripUnchangedFields(original);

      expect(result, {
        'name': 'Jane',
        'newField': 'added',
      });
      expect(result.containsKey('oldField'), false);
      expect(result.containsKey('id'), false); // Unchanged
      expect(result.containsKey('status'), false); // Unchanged
    });
  });

  group('MapExtension - stripTimestampFields', () {
    test('should remove updatedAt and createdAt at root level', () {
      final data = {
        'id': 1,
        'name': 'John',
        'createdAt': '2025-01-01T00:00:00Z',
        'updatedAt': '2025-01-02T00:00:00Z',
        'status': 'active',
      };

      final result = data.stripTimestampFields();

      expect(result, {
        'id': 1,
        'name': 'John',
        'status': 'active',
      });
      expect(result.containsKey('createdAt'), false);
      expect(result.containsKey('updatedAt'), false);
    });

    test('should remove timestamps in nested maps', () {
      final data = {
        'user': {
          'name': 'John',
          'email': 'john@example.com',
          'createdAt': '2025-01-01T00:00:00Z',
          'updatedAt': '2025-01-02T00:00:00Z',
        },
        'status': 'active',
      };

      final result = data.stripTimestampFields();

      expect(result, {
        'user': {
          'name': 'John',
          'email': 'john@example.com',
        },
        'status': 'active',
      });

      final user = result['user'] as Map;
      expect(user.containsKey('createdAt'), false);
      expect(user.containsKey('updatedAt'), false);
    });

    test('should remove timestamps in deeply nested structures', () {
      final data = {
        'company': {
          'name': 'Acme Corp',
          'createdAt': '2025-01-01T00:00:00Z',
          'department': {
            'name': 'Engineering',
            'updatedAt': '2025-01-02T00:00:00Z',
            'team': {
              'name': 'Backend',
              'createdAt': '2025-01-03T00:00:00Z',
            },
          },
        },
      };

      final result = data.stripTimestampFields();

      expect(result, {
        'company': {
          'name': 'Acme Corp',
          'department': {
            'name': 'Engineering',
            'team': {
              'name': 'Backend',
            },
          },
        },
      });

      final company = result['company'] as Map;
      final department = company['department'] as Map;
      final team = department['team'] as Map;

      expect(company.containsKey('createdAt'), false);
      expect(department.containsKey('updatedAt'), false);
      expect(team.containsKey('createdAt'), false);
    });

    test('should remove timestamps in list of maps', () {
      final data = {
        'users': [
          {
            'id': 1,
            'name': 'John',
            'createdAt': '2025-01-01T00:00:00Z',
            'updatedAt': '2025-01-02T00:00:00Z',
          },
          {
            'id': 2,
            'name': 'Jane',
            'createdAt': '2025-01-03T00:00:00Z',
            'updatedAt': '2025-01-04T00:00:00Z',
          },
        ],
      };

      final result = data.stripTimestampFields();

      expect(result, {
        'users': [
          {'id': 1, 'name': 'John'},
          {'id': 2, 'name': 'Jane'},
        ],
      });

      final users = result['users'] as List;
      for (final user in users) {
        final userMap = user as Map;
        expect(userMap.containsKey('createdAt'), false);
        expect(userMap.containsKey('updatedAt'), false);
      }
    });

    test('should remove timestamps in nested lists and maps', () {
      final data = {
        'projects': [
          {
            'name': 'Project A',
            'createdAt': '2025-01-01T00:00:00Z',
            'tasks': [
              {
                'title': 'Task 1',
                'updatedAt': '2025-01-02T00:00:00Z',
              },
              {
                'title': 'Task 2',
                'createdAt': '2025-01-03T00:00:00Z',
              },
            ],
          },
        ],
      };

      final result = data.stripTimestampFields();

      expect(result, {
        'projects': [
          {
            'name': 'Project A',
            'tasks': [
              {'title': 'Task 1'},
              {'title': 'Task 2'},
            ],
          },
        ],
      });

      final projects = result['projects'] as List;
      final project = projects[0] as Map;
      final tasks = project['tasks'] as List;

      expect(project.containsKey('createdAt'), false);
      for (final task in tasks) {
        final taskMap = task as Map;
        expect(taskMap.containsKey('createdAt'), false);
        expect(taskMap.containsKey('updatedAt'), false);
      }
    });

    test('should handle map with no timestamps', () {
      final data = {
        'id': 1,
        'name': 'John',
        'email': 'john@example.com',
      };

      final result = data.stripTimestampFields();

      expect(result, data);
    });

    test('should handle empty map', () {
      final data = <String, dynamic>{};
      final result = data.stripTimestampFields();
      expect(result, {});
    });

    test('should handle map with only timestamps', () {
      final data = {
        'createdAt': '2025-01-01T00:00:00Z',
        'updatedAt': '2025-01-02T00:00:00Z',
      };

      final result = data.stripTimestampFields();
      expect(result, {});
    });

    test('should preserve all other data types', () {
      final data = {
        'string': 'value',
        'number': 42,
        'double': 3.14,
        'bool': true,
        'null': null,
        'list': [1, 2, 3],
        'createdAt': '2025-01-01T00:00:00Z',
      };

      final result = data.stripTimestampFields();

      expect(result, {
        'string': 'value',
        'number': 42,
        'double': 3.14,
        'bool': true,
        'null': null,
        'list': [1, 2, 3],
      });
      expect(result.containsKey('createdAt'), false);
    });
  });
}
