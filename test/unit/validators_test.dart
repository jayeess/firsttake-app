import 'package:flutter_test/flutter_test.dart';
import 'package:firsttake/utils/validators/email_validator.dart';
import 'package:firsttake/utils/validators/password_validator.dart';

void main() {
  group('EmailValidator', () {
    test('returns error for null input', () {
      expect(EmailValidator.validate(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(EmailValidator.validate(''), isNotNull);
    });

    test('returns error for whitespace only', () {
      expect(EmailValidator.validate('   '), isNotNull);
    });

    test('returns error for invalid email format', () {
      expect(EmailValidator.validate('notanemail'), isNotNull);
      expect(EmailValidator.validate('missing@'), isNotNull);
      expect(EmailValidator.validate('@domain.com'), isNotNull);
      expect(EmailValidator.validate('no spaces@domain.com'), isNotNull);
    });

    test('returns null for valid email', () {
      expect(EmailValidator.validate('user@example.com'), isNull);
      expect(EmailValidator.validate('user.name@domain.co'), isNull);
      expect(EmailValidator.validate('test+tag@gmail.com'), isNull);
    });
  });

  group('PasswordValidator', () {
    test('returns error for null input', () {
      expect(PasswordValidator.validate(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(PasswordValidator.validate(''), isNotNull);
    });

    test('returns error for short password', () {
      expect(PasswordValidator.validate('Ab1'), isNotNull);
      expect(PasswordValidator.validate('Short1'), isNotNull);
    });

    test('returns error when missing uppercase', () {
      expect(PasswordValidator.validate('alllowercase1'), isNotNull);
    });

    test('returns error when missing number', () {
      expect(PasswordValidator.validate('AllLettersNoNum'), isNotNull);
    });

    test('returns null for valid password', () {
      expect(PasswordValidator.validate('Password1'), isNull);
      expect(PasswordValidator.validate('MyStr0ngPass'), isNull);
      expect(PasswordValidator.validate('C0mplexP@ss!'), isNull);
    });

    test('validateConfirm returns error when passwords do not match', () {
      expect(PasswordValidator.validateConfirm('different', 'Password1'), isNotNull);
    });

    test('validateConfirm returns null when passwords match', () {
      expect(PasswordValidator.validateConfirm('Password1', 'Password1'), isNull);
    });

    test('validateConfirm returns error for empty confirmation', () {
      expect(PasswordValidator.validateConfirm('', 'Password1'), isNotNull);
      expect(PasswordValidator.validateConfirm(null, 'Password1'), isNotNull);
    });
  });
}
