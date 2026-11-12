import 'package:flutter/material.dart';

import 'l10n.dart';

/// Plain-language information about a kind of doctor, so patients can pick
/// by health problem instead of by medical title.
class Specialty {
  const Specialty({
    required this.name,
    required this.nameSi,
    required this.simple,
    required this.simpleSi,
    required this.category,
    required this.categorySi,
    required this.treats,
    required this.treatsSi,
    required this.keywords,
    required this.icon,
    required this.color,
  });

  /// Medical title, as stored on the doctor, e.g. "Cardiologist".
  final String name;
  final String nameSi;

  /// Everyday name, e.g. "Heart doctor".
  final String simple;
  final String simpleSi;

  /// One or two words for the home screen tile, e.g. "Heart".
  final String category;
  final String categorySi;

  /// What this doctor helps with.
  final String treats;
  final String treatsSi;

  /// Extra search words (symptoms), in both languages.
  final String keywords;

  final IconData icon;
  final Color color;

  String get nameL => pick(name, nameSi);
  String get simpleL => pick(simple, simpleSi);
  String get categoryL => pick(category, categorySi);
  String get treatsL => pick(treats, treatsSi);

  /// "Heart doctor (Cardiologist)" – simple name first, title second.
  String get fullL => simple == name ? simpleL : '$simpleL ($nameL)';

  bool matches(String query) =>
      '$name $nameSi $simple $simpleSi $category $categorySi $treats '
              '$treatsSi $keywords'
          .toLowerCase()
          .contains(query);
}

const specialties = <Specialty>[
  Specialty(
    name: 'General Physician',
    nameSi: 'සාමාන්‍ය රෝග වෛද්‍ය',
    simple: 'General doctor',
    simpleSi: 'සාමාන්‍ය වෛද්‍ය',
    category: 'Fever & general',
    categorySi: 'උණ සහ සාමාන්‍ය',
    treats: 'Fever, cough, cold, diabetes, body pain, health check-ups',
    treatsSi:
        'උණ, කැස්ස, සෙම්ප්‍රතිශ්‍යාව, දියවැඩියාව, ඇඟපත වේදනාව, '
        'සෞඛ්‍ය පරීක්ෂා',
    keywords: 'flu headache stomach sugar family opd හිසරදය බඩේ සීනි',
    icon: Icons.thermostat,
    color: Color(0xFF2563EB),
  ),
  Specialty(
    name: 'Cardiologist',
    nameSi: 'හෘද රෝග විශේෂඥ',
    simple: 'Heart doctor',
    simpleSi: 'හෘද රෝග වෛද්‍ය',
    category: 'Heart',
    categorySi: 'හදවත',
    treats: 'Chest pain, high blood pressure, heart problems',
    treatsSi: 'පපුවේ වේදනාව, අධි රුධිර පීඩනය, හෘද රෝග',
    keywords: 'bp cholesterol breathing පපුව ප්‍රෙෂර් කොලෙස්ටරෝල්',
    icon: Icons.favorite,
    color: Color(0xFFE11D48),
  ),
  Specialty(
    name: 'Paediatrician',
    nameSi: 'ළමා රෝග විශේෂඥ',
    simple: 'Children\'s doctor',
    simpleSi: 'ළමා රෝග වෛද්‍ය',
    category: 'Children',
    categorySi: 'ළමයි',
    treats: 'Babies and children: fever, cough, growth, vaccines',
    treatsSi: 'ළදරුවන් සහ ළමුන්: උණ, කැස්ස, වර්ධනය, එන්නත්',
    keywords: 'baby child kids infant බබා දරුවා ළමා',
    icon: Icons.child_care,
    color: Color(0xFF7C3AED),
  ),
  Specialty(
    name: 'Dermatologist',
    nameSi: 'සම රෝග විශේෂඥ',
    simple: 'Skin doctor',
    simpleSi: 'සම රෝග වෛද්‍ය',
    category: 'Skin',
    categorySi: 'සම',
    treats: 'Rashes, itching, pimples, hair and nail problems',
    treatsSi: 'සමේ බිබිලි, කැසීම, කුරුලෑ, හිසකෙස් සහ නියපොතු ගැටලු',
    keywords: 'acne allergy eczema hair fall කුෂ්ඨ ආසාත්මිකතා',
    icon: Icons.face_retouching_natural,
    color: Color(0xFFEA580C),
  ),
  Specialty(
    name: 'Gynaecologist',
    nameSi: 'නාරි හා ප්‍රසව රෝග විශේෂඥ',
    simple: 'Women\'s health doctor',
    simpleSi: 'කාන්තා රෝග වෛද්‍ය',
    category: 'Women',
    categorySi: 'කාන්තා',
    treats: 'Pregnancy care, period problems, women\'s health',
    treatsSi: 'ගර්භණී සත්කාර, ඔසප් ගැටලු, කාන්තා සෞඛ්‍යය',
    keywords: 'pregnant mother family planning ගැබිණි මව',
    icon: Icons.pregnant_woman,
    color: Color(0xFFDB2777),
  ),
  Specialty(
    name: 'Orthopaedic Surgeon',
    nameSi: 'අස්ථි රෝග විශේෂඥ',
    simple: 'Bone and joint doctor',
    simpleSi: 'අස්ථි රෝග වෛද්‍ය',
    category: 'Bones & joints',
    categorySi: 'අස්ථි සහ සන්ධි',
    treats: 'Broken bones, knee and back pain, sports injuries',
    treatsSi: 'අස්ථි බිඳීම්, දණහිස් සහ කොන්දේ වේදනාව, ක්‍රීඩා තුවාල',
    keywords: 'fracture leg hand shoulder කකුල අත උරහිස',
    icon: Icons.accessibility_new,
    color: Color(0xFF059669),
  ),
];

/// Looks up a doctor's specialty; unknown titles (typed in by an admin) get
/// a neutral entry that shows the title as it is.
Specialty specialtyOf(String name) {
  for (final s in specialties) {
    if (s.name.toLowerCase() == name.trim().toLowerCase()) return s;
  }
  return Specialty(
    name: name,
    nameSi: name,
    simple: name,
    simpleSi: name,
    category: name,
    categorySi: name,
    treats: '',
    treatsSi: '',
    keywords: '',
    icon: Icons.medical_services,
    color: const Color(0xFF475569),
  );
}
