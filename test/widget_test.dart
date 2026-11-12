import 'dart:io';

import 'package:doca/l10n.dart';
import 'package:doca/l10n_si.dart';
import 'package:doca/main.dart';
import 'package:doca/mock_store.dart';
import 'package:doca/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(store.reset);

  /// Phone-sized surface, so overflows at 390 x 844 fail the test.
  Future<void> launch(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MyDoctorApp());
    await tester.pumpAndSettle();
  }

  Future<void> tapOn(WidgetTester tester, Finder finder) async {
    final target = finder.last;
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    // Let mock latency timers fire even when nothing is animating.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, String text) =>
      tapOn(tester, find.text(text));

  Future<void> login(WidgetTester tester, String role) async {
    await tapText(tester, role);
    await tapText(tester, 'Log In');
  }

  /// Opens a doctor and picks tomorrow 9:00, which is always in the future.
  Future<void> pickSlot(WidgetTester tester) async {
    await tester.drag(
      find.text(t('What is your health problem?')),
      const Offset(0, -350),
    );
    await tester.pumpAndSettle();
    await tapText(tester, 'Dr. Ruwan Fernando');
    await tapText(tester, 'View Availability');
    await tapOn(tester, find.byKey(const ValueKey('day-1')));
    await tapText(tester, '9:00 AM');
    await tapOn(tester, find.textContaining('Continue with'));
  }

  testWidgets('wrong login shows feedback', (tester) async {
    await launch(tester);
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'nimal@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
    await tapText(tester, 'Log In');
    expect(find.textContaining('Wrong email or password'), findsOneWidget);
  });

  testWidgets('patient books a slot, sees it Pending, then cancels', (
    tester,
  ) async {
    await launch(tester);
    await login(tester, 'Patient');
    expect(find.text('Find a doctor'), findsOneWidget);

    await pickSlot(tester);
    await tapText(tester, 'Request Appointment');

    expect(find.text('Appointment request sent'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    final appt = store.appointments.last;
    expect(appt.status, ApptStatus.pending);
    expect(store.slotById(appt.slotId)!.state, SlotState.reserved);

    await tapText(tester, 'View Appointment');
    await tapText(tester, 'Cancel Appointment');
    await tapText(tester, 'Cancel Appointment'); // dialog confirm
    expect(appt.status, ApptStatus.cancelled);
    expect(store.slotById(appt.slotId)!.state, SlotState.available);
  });

  testWidgets('taken slot sends the patient back to choose again', (
    tester,
  ) async {
    await launch(tester);
    await login(tester, 'Patient');
    store.setPrefs(slotTaken: true);
    final before = store.appointments.length;

    await pickSlot(tester);
    await tapText(tester, 'Request Appointment');

    expect(
      find.textContaining('This time is no longer available'),
      findsOneWidget,
    );
    expect(store.appointments.length, before);
    await tapText(tester, 'Choose Another Slot');
    expect(find.text('Select Appointment'), findsOneWidget);
  });

  testWidgets('choosing a health problem filters to the right doctor', (
    tester,
  ) async {
    await launch(tester);
    await login(tester, 'Patient');

    await tapText(tester, 'Heart');
    expect(find.textContaining('You need a Heart doctor'), findsOneWidget);
    expect(find.text('Dr. Anjali Perera'), findsOneWidget);
    expect(find.text('Dr. Ruwan Fernando'), findsNothing);

    // Searching by a symptom word also finds the right kind of doctor.
    await tapText(tester, 'Heart'); // deselect
    await tester.enterText(find.byType(TextField), 'pimples');
    await tester.pumpAndSettle();
    expect(find.text('Dr. Ruwan Fernando'), findsOneWidget);
    expect(find.text('Dr. Anjali Perera'), findsNothing);
  });

  testWidgets('switching to Sinhala translates open screens', (tester) async {
    await launch(tester);
    await tapText(tester, 'සිංහල');
    expect(find.text('ඇතුළු වන්න'), findsOneWidget); // Log In
    await tapText(tester, 'රෝගියා'); // Patient demo chip
    await tapText(tester, 'ඇතුළු වන්න');

    expect(find.text('වෛද්‍යවරයෙකු සොයන්න'), findsOneWidget);
    expect(find.text('වෛද්‍ය අංජලී පෙරේරා'), findsOneWidget);
    expect(find.text('හෘද රෝග වෛද්‍ය'), findsOneWidget);

    // Back to English from the home header, without leaving the screen.
    await tapText(tester, 'English');
    expect(find.text('Find a doctor'), findsOneWidget);
    expect(find.text('Dr. Anjali Perera'), findsOneWidget);
  });

  testWidgets('doctor accepts a request', (tester) async {
    await launch(tester);
    await login(tester, 'Doctor');
    expect(find.text('Today\'s schedule'), findsOneWidget);

    await tapText(tester, 'Review Requests');
    await tapText(tester, 'View Request');
    await tapText(tester, 'Accept');
    await tapText(tester, 'Accept'); // dialog confirm
    expect(find.text('Confirmed'), findsWidgets);
    expect(
      store.appointments.where((a) => a.status == ApptStatus.pending).length,
      2,
    );
  });

  for (final lang in AppLang.values) {
    testWidgets('doctor tabs fit a small phone (${lang.name})', (tester) async {
      await launch(tester, size: const Size(320, 568));
      await login(tester, 'Doctor');
      appLang.value = lang;
      await tester.pumpAndSettle();
      for (final tab in ['Schedule', 'Appointments', 'Profile']) {
        await tapOn(tester, find.text(t(tab)));
      }
    });

    testWidgets('patient tabs fit a small phone (${lang.name})', (
      tester,
    ) async {
      await launch(tester, size: const Size(320, 568));
      await login(tester, 'Patient');
      appLang.value = lang;
      await tester.pumpAndSettle();
      for (final tab in ['Appointments', 'Notifications', 'Profile', 'Home']) {
        await tapOn(tester, find.text(t(tab)));
      }
      await tester.drag(
        find.text(t('What is your health problem?')),
        const Offset(0, -350),
      );
      await tester.pumpAndSettle();
      await tapOn(tester, find.text(t('View Profile')).first);
      await tapOn(tester, find.text(t('View Availability')));
    });
  }

  testWidgets('admin screens fit a small phone', (tester) async {
    await launch(tester, size: const Size(320, 568));
    await login(tester, 'Admin');
    for (final screen in [
      'Manage Doctors',
      'Manage Users',
      'Appointment Reports',
    ]) {
      await tapText(tester, screen);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });

  test('every patient and doctor text has a Sinhala translation', () {
    // Finds t('…') and requiredField('…') keys, joining adjacent literals.
    final call = RegExp(
      r"\b(?:t|requiredField)\(\s*((?:'(?:[^'\\]|\\.)*'\s*)+)",
    );
    final literal = RegExp(r"'((?:[^'\\]|\\.)*)'");
    final missing = <String>{};
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.contains('admin'));
    for (final file in files) {
      for (final m in call.allMatches(file.readAsStringSync())) {
        final key = literal
            .allMatches(m.group(1)!)
            .map((l) => l.group(1)!.replaceAll(r"\'", "'"))
            .join();
        if (!sinhala.containsKey(key)) missing.add(key);
      }
    }
    expect(missing, isEmpty);
  });
}
