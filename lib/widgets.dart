import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'format.dart';
import 'l10n.dart';
import 'mock_store.dart';
import 'models.dart';
import 'specialties.dart';
import 'theme.dart';

// ------------------------------------------------------------------ helpers

Future<T?> push<T>(BuildContext context, Widget screen) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => screen));

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancelLabel ?? t('Cancel')),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error,
                )
              : null,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

String? validateEmail(String? v) {
  final value = v?.trim() ?? '';
  if (value.isEmpty) return t('Enter your email');
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
    return t('Enter a valid email address');
  }
  return null;
}

/// [message] is the English key; it is translated when shown.
String? Function(String?) requiredField(String message) =>
    (v) => (v == null || v.trim().isEmpty) ? t(message) : null;

// ----------------------------------------------------------------- language

/// English / සිංහල switch for forms and settings.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AppLang>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: AppLang.en, label: Text('English')),
        ButtonSegment(value: AppLang.si, label: Text('සිංහල')),
      ],
      selected: {appLang.value},
      onSelectionChanged: (s) => appLang.value = s.first,
    );
  }
}

/// Compact one-tap switch for coloured headers; shows the other language.
class LanguagePill extends StatelessWidget {
  const LanguagePill({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => appLang.value = isSi ? AppLang.en : AppLang.si,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.translate, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                isSi ? 'English' : 'සිංහල',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------- motion

/// Shrinks its child slightly while pressed, so cards feel touchable.
class TapScale extends StatefulWidget {
  const TapScale({super.key, required this.child});
  final Widget child;

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  bool _down = false;

  void _set(bool v) {
    if (mounted && _down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Fades and slides a list item in; later items take a little longer.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, this.index = 0, required this.child});
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + 80 * math.min(index, 6)),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 22 * (1 - v)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Blue-to-turquoise header with rounded bottom corners.
class GradientHeader extends StatelessWidget {
  const GradientHeader({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: kBrandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: child,
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ buttons

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Shows a spinner and blocks taps, so a request can't be sent twice.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(label, textAlign: TextAlign.center)),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Pins a screen's main actions to the bottom, within thumb reach.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 12,
      shadowColor: const Color(0x332347D9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ badges, pills

class Pill extends StatelessWidget {
  const Pill({super.key, required this.label, required this.style});
  final String label;
  final PillStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 15, color: style.fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: style.fg,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});
  final ApptStatus status;

  @override
  Widget build(BuildContext context) =>
      Pill(label: status.label, style: statusStyle(status));
}

// ------------------------------------------------------------------ avatars

/// Coloured initials avatar; stands in for photos in the prototype.
/// Always pass the English name so the initials are Latin letters.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar(this.name, {super.key, this.radius = 26, this.heroTag});
  final String name;
  final double radius;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final color = avatarColor(name);
    final avatar = Container(
      width: radius * 2,
      height: radius * 2,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.white, 0.35)!],
        ),
      ),
      child: Text(
        initials(name),
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.72,
          fontWeight: FontWeight.w800,
          decoration: TextDecoration.none,
        ),
      ),
    );
    return heroTag == null ? avatar : Hero(tag: heroTag!, child: avatar);
  }
}

/// Small coloured icon tile for a kind of doctor.
class SpecialtyIcon extends StatelessWidget {
  const SpecialtyIcon(this.specialty, {super.key, this.size = 44});
  final Specialty specialty;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: specialty.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(specialty.icon, color: specialty.color, size: size * 0.56),
    );
  }
}

// -------------------------------------------------------------------- cards

class DoctorCard extends StatelessWidget {
  const DoctorCard({super.key, required this.doctor, required this.onTap});
  final Doctor doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sp = specialtyOf(doctor.specialty);
    return TapScale(
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PersonAvatar(
                      doctor.name,
                      radius: 30,
                      heroTag: 'doctor-${doctor.id}',
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.nameL,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(sp.icon, size: 18, color: sp.color),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  sp.simpleL,
                                  style: TextStyle(
                                    color: sp.color,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (sp.simple != sp.name)
                            Text(sp.nameL, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (sp.treats.isNotEmpty) ...[
                  IconText(Icons.healing, t('Helps with: {0}', [sp.treatsL])),
                  const SizedBox(height: 6),
                ],
                IconText(Icons.location_on_outlined, doctor.clinicL),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(64, 46),
                    ),
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: Text(t('View Profile')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.dateTime,
    required this.status,
    required this.onTap,
    this.avatarName,
    this.actionLabel,
  });

  /// The other party: the doctor for patients, the patient for doctors.
  final String name;
  final String subtitle;
  final DateTime dateTime;
  final ApptStatus status;
  final VoidCallback onTap;

  /// English name for the avatar initials; defaults to [name].
  final String? avatarName;

  /// Optional explicit button, e.g. "View Request".
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = statusStyle(status).fg;
    return TapScale(
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status colour stripe (the badge carries the label).
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 6,
                  color: accent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            PersonAvatar(avatarName ?? name, radius: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    subtitle,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IconText(
                                      Icons.calendar_today,
                                      fmtDate(dateTime),
                                    ),
                                    const SizedBox(height: 4),
                                    IconText(Icons.schedule, fmtTime(dateTime)),
                                  ],
                                ),
                              ),
                              StatusBadge(status),
                            ],
                          ),
                        ),
                        if (actionLabel != null) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.tonal(
                              onPressed: onTap,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(64, 46),
                              ),
                              child: Text(actionLabel!),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IconText extends StatelessWidget {
  const IconText(this.icon, this.text, {super.key});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontSize: 13.5, height: 1.3),
          ),
        ),
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow(this.icon, this.label, this.value, {super.key});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

// --------------------------------------------------------- date, time slots

/// Horizontal day picker starting today.
class DateStrip extends StatelessWidget {
  const DateStrip({
    super.key,
    required this.selected,
    required this.onSelected,
    this.days = 14,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onSelected;
  final int days;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = dateOnly(DateTime.now());
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        itemCount: days,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final d = DateTime(today.year, today.month, today.day + i);
          final isSelected = sameDay(d, selected);
          final fg = isSelected ? Colors.white : scheme.onSurface;
          final radius = BorderRadius.circular(18);
          return Semantics(
            key: ValueKey('day-$i'),
            selected: isSelected,
            button: true,
            label: fmtDate(d),
            excludeSemantics: true,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: 66,
              decoration: BoxDecoration(
                gradient: isSelected ? kBrandGradient : null,
                color: isSelected ? null : Colors.white,
                borderRadius: radius,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : const Color(0xFFDCE2F2),
                ),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x402347D9),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: radius,
                  onTap: () => onSelected(d),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            i == 0 ? t('Today') : weekdayShort(d),
                            style: TextStyle(color: fg, fontSize: 12),
                          ),
                          Text(
                            '${d.day}',
                            style: TextStyle(
                              color: fg,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            monthShort(d),
                            style: TextStyle(color: fg, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum SlotChipState { available, selected, unavailable }

class SlotChip extends StatelessWidget {
  const SlotChip({
    super.key,
    required this.label,
    required this.state,
    this.onTap,
  });

  final String label;
  final SlotChipState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, border) = switch (state) {
      SlotChipState.available => (Colors.white, scheme.primary, scheme.primary),
      SlotChipState.selected => (scheme.primary, Colors.white, scheme.primary),
      SlotChipState.unavailable => (
        const Color(0xFFE6E9F2),
        const Color(0xFF6B7385),
        const Color(0xFFE6E9F2),
      ),
    };
    final unavailable = state == SlotChipState.unavailable;
    final selected = state == SlotChipState.selected;
    final radius = BorderRadius.circular(14);
    return Semantics(
      button: !unavailable,
      selected: selected,
      label: unavailable ? '$label, ${t('Unavailable')}' : label,
      excludeSemantics: true,
      child: AnimatedScale(
        scale: selected ? 1.04 : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 50,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: Border.all(color: border, width: 1.5),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: radius,
              onTap: unavailable ? null : onTap,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                // Scales down rather than overflowing with large fonts.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        Icon(Icons.check_circle, size: 16, color: fg),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          color: fg,
                          fontWeight: FontWeight.w700,
                          decoration: unavailable
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lays chips out three per row at any phone width.
class SlotGrid extends StatelessWidget {
  const SlotGrid({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final width = (constraints.maxWidth - gap * 2) / 3;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final c in children)
              SizedBox(width: width.floorToDouble(), child: c),
          ],
        );
      },
    );
  }
}

// ----------------------------------------------------------- screen states

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: FadeSlideIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (actionLabel != null) ...[
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading -> content, with a retry state on failure. Rebuilds the content
/// whenever the store changes.
class AsyncBody extends StatefulWidget {
  const AsyncBody({super.key, required this.builder});
  final WidgetBuilder builder;

  @override
  State<AsyncBody> createState() => _AsyncBodyState();
}

class _AsyncBodyState extends State<AsyncBody> {
  late Future<void> _future = store.load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return EmptyState(
            icon: Icons.cloud_off,
            title: t('Could not load this page'),
            message: t('Check your internet connection and try again.'),
            actionLabel: t('Try Again'),
            onAction: () => setState(() => _future = store.load()),
          );
        }
        return ListenableBuilder(
          listenable: store,
          builder: (context, _) => widget.builder(context),
        );
      },
    );
  }
}

// ----------------------------------------------------------------- timeline

class StatusTimeline extends StatelessWidget {
  const StatusTimeline(this.appointment, {super.key});
  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final events = appointment.events;
    return Column(
      children: [
        for (var i = 0; i < events.length; i++)
          FadeSlideIn(
            index: i,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: statusStyle(events[i].status).bg,
                        child: Icon(
                          statusStyle(events[i].status).icon,
                          size: 18,
                          color: statusStyle(events[i].status).fg,
                        ),
                      ),
                      if (i < events.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 4,
                        bottom: i < events.length - 1 ? 18 : 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            events[i].status.label,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(events[i].status.description),
                          const SizedBox(height: 2),
                          Text(
                            fmtDateTime(events[i].at),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
