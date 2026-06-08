class AppConstants {
  AppConstants._();

  static const String appName = 'FirstTake';
  static const String tagline = 'Where Talent Meets Opportunity';

  static const int maxBioLength = 500;
  static const int maxCoverMessageLength = 500;
  static const int maxPhotoCount = 5;
  static const int maxVideoSizeMB = 100;
  static const int maxPhotoSizeMB = 5;
  static const int minPasswordLength = 8;

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration buttonFeedbackDuration = Duration(milliseconds: 200);

  static const List<String> talentCategories = [
    'ACTOR',
    'MODEL',
    'DANCER',
    'VOICE_ARTIST',
    'ANCHOR',
  ];

  static const List<String> experienceLevels = [
    'FRESHER',
    '1_3_YRS',
    '3_5_YRS',
    '5_PLUS_YRS',
  ];

  static const Map<String, String> categoryLabels = {
    'ACTOR': 'Actor',
    'MODEL': 'Model',
    'DANCER': 'Dancer',
    'VOICE_ARTIST': 'Voice Artist',
    'ANCHOR': 'Anchor',
  };

  static const Map<String, String> experienceLabels = {
    'FRESHER': 'Fresher',
    '1_3_YRS': '1-3 Years',
    '3_5_YRS': '3-5 Years',
    '5_PLUS_YRS': '5+ Years',
  };

  static const Map<String, String> applicationStatusLabels = {
    'APPLIED': 'Applied',
    'VIEWED': 'Viewed',
    'SHORTLISTED': 'Shortlisted',
    'REJECTED': 'Rejected',
  };

  static const Map<String, String> genderLabels = {
    'MALE': 'Male',
    'FEMALE': 'Female',
    'OTHER': 'Other',
  };
}
