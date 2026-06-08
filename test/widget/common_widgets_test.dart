import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firsttake/widgets/common/custom_button.dart';
import 'package:firsttake/widgets/common/custom_text_field.dart';
import 'package:firsttake/widgets/common/loading_indicator.dart';

void main() {
  group('CustomButton', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(label: 'Test Button', onPressed: () {}),
          ),
        ),
      );
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(label: 'Loading', isLoading: true),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(label: 'Tap Me', onPressed: () => pressed = true),
          ),
        ),
      );
      await tester.tap(find.text('Tap Me'));
      expect(pressed, true);
    });

    testWidgets('renders with icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(label: 'With Icon', icon: Icons.add, onPressed: () {}),
          ),
        ),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
    });

    testWidgets('outline variant renders OutlinedButton', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(label: 'Outline', variant: ButtonVariant.outline, onPressed: () {}),
          ),
        ),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });

  group('CustomTextField', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomTextField(label: 'Email'),
          ),
        ),
      );
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('accepts text input', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(controller: controller, label: 'Name'),
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField), 'John Doe');
      expect(controller.text, 'John Doe');
    });

    testWidgets('shows validation error', (tester) async {
      final key = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: key,
              child: CustomTextField(
                label: 'Required',
                validator: (v) => v == null || v.isEmpty ? 'Required field' : null,
              ),
            ),
          ),
        ),
      );
      key.currentState!.validate();
      await tester.pump();
      expect(find.text('Required field'), findsOneWidget);
    });
  });

  group('LoadingIndicator', () {
    testWidgets('shows spinner', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingIndicator()),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingIndicator(message: 'Please wait...')),
        ),
      );
      expect(find.text('Please wait...'), findsOneWidget);
    });
  });

  group('EmptyState', () {
    testWidgets('renders title and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(icon: Icons.inbox, title: 'No items'),
          ),
        ),
      );
      expect(find.text('No items'), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Empty',
              subtitle: 'Nothing here yet',
            ),
          ),
        ),
      );
      expect(find.text('Nothing here yet'), findsOneWidget);
    });
  });
}
