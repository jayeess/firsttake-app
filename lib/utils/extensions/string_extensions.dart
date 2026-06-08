extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String get titleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  String get initials {
    final words = trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  String get displayCategory {
    return replaceAll('_', ' ').titleCase;
  }

  String get displayExperience {
    switch (this) {
      case 'FRESHER':
        return 'Fresher';
      case '1_3_YRS':
        return '1-3 Years';
      case '3_5_YRS':
        return '3-5 Years';
      case '5_PLUS_YRS':
        return '5+ Years';
      default:
        return titleCase;
    }
  }
}
