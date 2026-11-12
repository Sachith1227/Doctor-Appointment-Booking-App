import 'package:flutter/material.dart';

import '../../l10n.dart';
import '../../mock_store.dart';
import '../../specialties.dart';
import '../../theme.dart';
import '../../widgets.dart';
import 'doctor_profile_screen.dart';

/// Find Doctors. Patients choose by health problem in plain words (or
/// search by name / symptom) instead of needing to know medical titles.
class PatientHomeTab extends StatefulWidget {
  const PatientHomeTab({super.key});

  @override
  State<PatientHomeTab> createState() => _PatientHomeTabState();
}

class _PatientHomeTabState extends State<PatientHomeTab> {
  final _search = TextEditingController();
  String? _specialty; // medical title; null = all

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clear() {
    setState(() {
      _search.clear();
      _specialty = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstName = store.currentUser?.name.split(' ').first ?? '';
    return Scaffold(
      body: Column(
        children: [
          GradientHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t('Hello, {0} 👋', [firstName]),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const LanguagePill(),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  t('Find a doctor'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: t('Search doctor or sickness (e.g. fever)'),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: t('Clear search'),
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(_search.clear),
                          ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: AsyncBody(builder: _content)),
        ],
      ),
    );
  }

  Widget _content(BuildContext context) {
    final theme = Theme.of(context);
    final active = store.doctors.where((d) => d.active).toList();
    // Only offer kinds of doctor that are actually available.
    final offered = <Specialty>[
      for (final s in specialties)
        if (active.any((d) => specialtyOf(d.specialty).name == s.name)) s,
    ];
    final query = _search.text.trim().toLowerCase();
    final results = active.where((d) {
      final sp = specialtyOf(d.specialty);
      final matchesQuery =
          query.isEmpty ||
          d.name.toLowerCase().contains(query) ||
          (d.nameSi ?? '').contains(query) ||
          sp.matches(query);
      return matchesQuery && (_specialty == null || sp.name == _specialty);
    }).toList();
    final selected = _specialty == null ? null : specialtyOf(_specialty!);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        SectionTitle(t('What is your health problem?')),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 10.0;
            final width = ((constraints.maxWidth - gap * 2) / 3)
                .floorToDouble();
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final s in offered)
                  SizedBox(
                    width: width,
                    child: _ProblemTile(
                      specialty: s,
                      selected: _specialty == s.name,
                      onTap: () => setState(
                        () => _specialty = _specialty == s.name ? null : s.name,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: selected == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _SpecialtyInfo(selected, onClear: _clear),
                ),
        ),
        Row(
          children: [
            Expanded(child: SectionTitle(t('Doctors'))),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                t('{0} found', [results.length]),
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
        if (results.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: EmptyState(
              icon: Icons.search_off,
              title: t('No doctors found'),
              message: t(
                'Try another word, or clear the search to see all doctors.',
              ),
              actionLabel: t('Clear Search'),
              onAction: _clear,
            ),
          )
        else
          for (final (i, d) in results.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FadeSlideIn(
                key: ValueKey(d.id),
                index: i,
                child: DoctorCard(
                  doctor: d,
                  onTap: () =>
                      push(context, DoctorProfileScreen(doctorId: d.id)),
                ),
              ),
            ),
      ],
    );
  }
}

/// Big, colourful "health problem" button.
class _ProblemTile extends StatelessWidget {
  const _ProblemTile({
    required this.specialty,
    required this.selected,
    required this.onTap,
  });

  final Specialty specialty;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = specialty.color;
    final radius = BorderRadius.circular(20);
    return Semantics(
      button: true,
      selected: selected,
      child: TapScale(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          height: 102,
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            borderRadius: radius,
            border: Border.all(
              color: selected ? color : const Color(0xFFE3E8F4),
              width: 1.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: radius,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white.withValues(alpha: 0.22)
                            : color.withValues(alpha: 0.13),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        specialty.icon,
                        color: selected ? Colors.white : color,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        specialty.categoryL,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? Colors.white : kInk,
                          fontSize: 13,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Explains, in plain words, which doctor treats the chosen problem.
class _SpecialtyInfo extends StatelessWidget {
  const _SpecialtyInfo(this.specialty, {required this.onClear});
  final Specialty specialty;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final color = specialty.color;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SpecialtyIcon(specialty),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('You need a {0}', [specialty.fullL]),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t('Helps with: {0}', [specialty.treatsL]),
                  style: const TextStyle(fontSize: 13.5, height: 1.35),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: t('Show all doctors'),
            icon: const Icon(Icons.close),
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}
