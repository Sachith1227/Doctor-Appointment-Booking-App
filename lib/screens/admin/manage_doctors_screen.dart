import 'package:flutter/material.dart';

import '../../mock_store.dart';
import '../../models.dart';
import '../../widgets.dart';

const _activeStyle = (
  fg: Color(0xFF0B5D2A),
  bg: Color(0xFFD7F2DF),
  icon: Icons.check_circle,
);
const _inactiveStyle = (
  fg: Color(0xFF454F4E),
  bg: Color(0xFFE3E8E7),
  icon: Icons.pause_circle,
);

class ManageDoctorsScreen extends StatefulWidget {
  const ManageDoctorsScreen({super.key});

  @override
  State<ManageDoctorsScreen> createState() => _ManageDoctorsScreenState();
}

class _ManageDoctorsScreenState extends State<ManageDoctorsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Doctors')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => push(context, const DoctorFormScreen()),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Add Doctor'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search doctors',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: AsyncBody(
              builder: (context) {
                final results = store.doctors
                    .where(
                      (d) =>
                          d.name.toLowerCase().contains(_query) ||
                          d.specialty.toLowerCase().contains(_query),
                    )
                    .toList();
                if (results.isEmpty) {
                  return const EmptyState(
                    icon: Icons.search_off,
                    title: 'No doctors found',
                    message: 'Try a different name or specialty.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final d = results[i];
                    void edit() => push(context, DoctorFormScreen(doctor: d));
                    return Card(
                      child: InkWell(
                        onTap: edit,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
                          child: Row(
                            children: [
                              PersonAvatar(d.name, radius: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(d.specialty),
                                    const SizedBox(height: 6),
                                    Pill(
                                      label: d.active ? 'Active' : 'Inactive',
                                      style: d.active
                                          ? _activeStyle
                                          : _inactiveStyle,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Edit doctor profile',
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: edit,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorFormScreen extends StatefulWidget {
  const DoctorFormScreen({super.key, this.doctor});
  final Doctor? doctor;

  @override
  State<DoctorFormScreen> createState() => _DoctorFormScreenState();
}

class _DoctorFormScreenState extends State<DoctorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.doctor?.name);
  late final _email = TextEditingController(text: widget.doctor?.email);
  late final _specialty = TextEditingController(text: widget.doctor?.specialty);
  late final _clinic = TextEditingController(text: widget.doctor?.clinic);
  late final _bio = TextEditingController(text: widget.doctor?.bio);
  late bool _active = widget.doctor?.active ?? true;

  bool get _editing => widget.doctor != null;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _specialty.dispose();
    _clinic.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_editing) {
      store.updateDoctor(
        widget.doctor!,
        name: _name.text.trim(),
        specialty: _specialty.text.trim(),
        clinic: _clinic.text.trim(),
        bio: _bio.text.trim(),
        active: _active,
      );
    } else {
      store.addDoctor(
        name: _name.text.trim(),
        email: _email.text.trim(),
        specialty: _specialty.text.trim(),
        clinic: _clinic.text.trim(),
        bio: _bio.text.trim(),
        active: _active,
      );
    }
    Navigator.pop(context);
    showSnack(
      context,
      _editing
          ? 'Doctor profile updated.'
          : 'Doctor added. Demo password: ${MockStore.demoDoctorPassword}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit Doctor' : 'Add Doctor')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Dr. First Last',
              ),
              validator: requiredField('Enter the doctor\'s name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              enabled: !_editing,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                helperText: _editing
                    ? 'The login email can\'t be changed'
                    : 'The doctor signs in with this email',
              ),
              validator: (v) => _editing
                  ? null
                  : validateEmail(v) ?? store.validateNewDoctorEmail(v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _specialty,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Specialty'),
              validator: requiredField('Enter a specialty'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _clinic,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Clinic',
                hintText: 'Clinic name, city',
              ),
              validator: requiredField('Enter the clinic location'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bio,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Bio',
                alignLabelWithHint: true,
              ),
              validator: requiredField('Enter a short bio'),
            ),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                title: const Text('Account active'),
                subtitle: Text(
                  _active
                      ? 'Visible to patients and able to sign in'
                      : 'Hidden from patients and unable to sign in',
                ),
                value: _active,
                onChanged: (v) => setState(() => _active = v),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        children: [
          PrimaryButton(
            label: _editing ? 'Save Changes' : 'Add Doctor',
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
