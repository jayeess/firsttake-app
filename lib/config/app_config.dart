class AppConfig {
  AppConfig._();

  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  static const String firestoreEmulatorHost = 'localhost';
  static const int firestoreEmulatorPort = 8080;
  static const int authEmulatorPort = 9099;
  static const int storageEmulatorPort = 9199;
}
