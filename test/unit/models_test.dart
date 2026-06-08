import 'package:flutter_test/flutter_test.dart';
import 'package:firsttake/models/user_model.dart';
import 'package:firsttake/models/audition_model.dart';
import 'package:firsttake/models/application_model.dart';
import 'package:firsttake/utils/extensions/string_extensions.dart';
import 'package:firsttake/utils/extensions/date_extensions.dart';
import 'package:firsttake/config/constants.dart';

void main() {
  group('UserModel', () {
    test('copyWith creates a new instance with updated fields', () {
      final now = DateTime.now();
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        phone: '+1234567890',
        userType: UserType.TALENT,
        createdAt: now,
        updatedAt: now,
      );

      final updated = user.copyWith(email: 'new@example.com');
      expect(updated.email, 'new@example.com');
      expect(updated.uid, 'uid1');
      expect(updated.userType, UserType.TALENT);
    });

    test('default values are set correctly', () {
      final now = DateTime.now();
      final user = UserModel(
        uid: 'uid1',
        email: 'test@example.com',
        phone: '',
        userType: UserType.RECRUITER,
        createdAt: now,
        updatedAt: now,
      );

      expect(user.emailVerified, false);
      expect(user.phoneVerified, false);
      expect(user.accountStatus, AccountStatus.ACTIVE);
      expect(user.lastLogin, isNull);
    });
  });

  group('Audition', () {
    test('creates with required fields and defaults', () {
      final audition = Audition(
        id: 'aud1',
        recruiterId: 'rec1',
        title: 'Movie Role',
        description: 'Lead actor for drama',
        category: 'ACTOR',
      );

      expect(audition.status, AuditionStatus.ACTIVE);
      expect(audition.applicantCount, 0);
      expect(audition.numberOfPositions, 1);
    });

    test('copyWith preserves unchanged fields', () {
      final audition = Audition(
        id: 'aud1',
        recruiterId: 'rec1',
        title: 'Original Title',
        description: 'Original desc',
        category: 'MODEL',
        location: 'Mumbai',
      );

      final updated = audition.copyWith(title: 'New Title');
      expect(updated.title, 'New Title');
      expect(updated.description, 'Original desc');
      expect(updated.location, 'Mumbai');
    });
  });

  group('Application', () {
    test('creates with default status APPLIED', () {
      final app = Application(
        id: 'app1',
        auditionId: 'aud1',
        talentId: 'tal1',
      );

      expect(app.status, 'APPLIED');
    });

    test('copyWith updates status', () {
      final app = Application(
        id: 'app1',
        auditionId: 'aud1',
        talentId: 'tal1',
      );

      final updated = app.copyWith(status: 'SHORTLISTED');
      expect(updated.status, 'SHORTLISTED');
      expect(updated.talentId, 'tal1');
    });
  });

  group('StringExtensions', () {
    test('capitalize works correctly', () {
      expect('hello'.capitalize, 'Hello');
      expect('HELLO'.capitalize, 'Hello');
      expect(''.capitalize, '');
    });

    test('titleCase works correctly', () {
      expect('hello world'.titleCase, 'Hello World');
    });

    test('initials works correctly', () {
      expect('John Doe'.initials, 'JD');
      expect('John'.initials, 'J');
    });

    test('truncate works correctly', () {
      expect('Hello World'.truncate(5), 'Hello...');
      expect('Hi'.truncate(5), 'Hi');
    });

    test('displayCategory works correctly', () {
      expect('VOICE_ARTIST'.displayCategory, 'Voice Artist');
    });

    test('displayExperience works correctly', () {
      expect('FRESHER'.displayExperience, 'Fresher');
      expect('1_3_YRS'.displayExperience, '1-3 Years');
      expect('5_PLUS_YRS'.displayExperience, '5+ Years');
    });
  });

  group('DateTimeExtensions', () {
    test('daysUntil shows correct label', () {
      final future = DateTime.now().add(const Duration(days: 5));
      final result = future.daysUntil;
      expect(result, anyOf('4 days left', '5 days left'));
      expect(DateTime.now().subtract(const Duration(days: 1)).daysUntil, 'Expired');
    });

    test('timeAgo shows correct label', () {
      final justNow = DateTime.now().subtract(const Duration(seconds: 30));
      expect(justNow.timeAgo, 'Just now');

      final hoursAgo = DateTime.now().subtract(const Duration(hours: 3));
      expect(hoursAgo.timeAgo, '3h ago');
    });

    test('isPast and isFuture work correctly', () {
      expect(DateTime.now().subtract(const Duration(days: 1)).isPast, true);
      expect(DateTime.now().add(const Duration(days: 1)).isFuture, true);
    });
  });

  group('AppConstants', () {
    test('has all talent categories', () {
      expect(AppConstants.talentCategories.length, 5);
      expect(AppConstants.talentCategories, contains('ACTOR'));
      expect(AppConstants.talentCategories, contains('VOICE_ARTIST'));
    });

    test('has all experience levels', () {
      expect(AppConstants.experienceLevels.length, 4);
    });

    test('category labels map correctly', () {
      expect(AppConstants.categoryLabels['ACTOR'], 'Actor');
      expect(AppConstants.categoryLabels['VOICE_ARTIST'], 'Voice Artist');
    });
  });
}
