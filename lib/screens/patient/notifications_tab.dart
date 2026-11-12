import 'package:flutter/material.dart';

import '../../format.dart';
import '../../l10n.dart';
import '../../mock_store.dart';
import '../../theme.dart';
import '../../widgets.dart';
import '../shared/appointment_details_screen.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('Notifications')),
        actions: [
          TextButton(
            onPressed: () {
              final user = store.currentUser;
              if (user != null) store.markAllRead(user.id);
            },
            child: Text(t('Mark all read')),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AsyncBody(
        builder: (context) {
          final user = store.currentUser;
          if (user == null) return const SizedBox.shrink();
          final items = store.notificationsFor(user.id);
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.notifications_none,
              title: t('No notifications yet'),
              message: t('News about your bookings will be shown here.'),
            );
          }
          final theme = Theme.of(context);
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final n = items[i];
              final style = statusStyle(n.status);
              final text = store.notificationText(n);
              return FadeSlideIn(
                index: i,
                child: TapScale(
                  child: Card(
                    color: n.read ? Colors.white : const Color(0xFFEAF0FF),
                    child: InkWell(
                      onTap: () {
                        store.markRead(n);
                        push(
                          context,
                          AppointmentDetailsScreen(
                            appointmentId: n.appointmentId,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 21,
                              backgroundColor: style.bg,
                              child: Icon(
                                style.icon,
                                color: style.fg,
                                size: 21,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    text.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: n.read
                                          ? FontWeight.w600
                                          : FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(text.body),
                                  const SizedBox(height: 6),
                                  Text(
                                    n.read
                                        ? fmtAgo(n.at)
                                        : '${fmtAgo(n.at)} · ${t('New')}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            if (!n.read)
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 4),
                                child: CircleAvatar(
                                  radius: 5,
                                  backgroundColor: theme.colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
