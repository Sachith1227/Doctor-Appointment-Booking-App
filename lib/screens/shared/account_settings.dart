import 'package:flutter/material.dart';

import '../../app_router.dart';
import '../../l10n.dart';
import '../../mock_store.dart';
import '../../theme.dart';
import '../../widgets.dart';

/// Account and settings content, shared by every role's Profile.
/// [header] lets a role put its own details on top (the doctor's profile).
class AccountSettingsView extends StatelessWidget {
  const AccountSettingsView({super.key, this.header});
  final Widget? header;

  Future<void> _signOut(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: t('Sign out?'),
      message: t('You will need to log in again to use MyDoctor.'),
      confirmLabel: t('Sign Out'),
    );
    if (ok && context.mounted) signOutToLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final user = store.currentUser;
        if (user == null) return const SizedBox.shrink();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: kBrandGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: PersonAvatar(user.name, radius: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ?header,
            SectionTitle(t('Language')),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.translate, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(child: Text(t('App language'))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const LanguageToggle(),
                  ],
                ),
              ),
            ),
            SectionTitle(t('Notifications')),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(t('Booking updates')),
                    subtitle: Text(
                      t('When a request is accepted, rejected or cancelled'),
                    ),
                    value: store.notifyBookingUpdates,
                    onChanged: (v) => store.setPrefs(bookingUpdates: v),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(t('Appointment reminders')),
                    subtitle: Text(t('The day before an appointment')),
                    value: store.notifyReminders,
                    onChanged: (v) => store.setPrefs(reminders: v),
                  ),
                ],
              ),
            ),
            SectionTitle(t('Prototype options')),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(t('Fail the next page load')),
                    subtitle: Text(t('Shows the "Try Again" screen once')),
                    value: store.simulateLoadError,
                    onChanged: (v) => store.setPrefs(loadError: v),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(t('Take my time slot on next request')),
                    subtitle: Text(
                      t('Shows the "no longer available" message once'),
                    ),
                    value: store.simulateSlotTaken,
                    onChanged: (v) => store.setPrefs(slotTaken: v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout),
              label: Text(t('Sign Out')),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Stand-alone version, for roles without a Profile tab (admin).
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t('Account & Settings'))),
      body: const AccountSettingsView(),
    );
  }
}
