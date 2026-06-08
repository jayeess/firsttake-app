import 'package:flutter/material.dart';
import '../../widgets/common/loading_indicator.dart';

class LoadingScreen extends StatelessWidget {
  final String? message;
  const LoadingScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingIndicator(message: message ?? 'Loading...'),
    );
  }
}
