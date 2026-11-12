import 'package:flutter/material.dart';

import '../../app_router.dart';
import '../../l10n.dart';
import '../../mock_store.dart';
import '../../widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _emailError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _emailError = null);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    final error = await store.registerPatient(
      _name.text,
      _email.text,
      _password.text,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _emailError = error;
      });
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    goHome(context);
    messenger.showSnackBar(
      SnackBar(content: Text(t('Account created. Welcome to MyDoctor!'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final toggle = IconButton(
      tooltip: _obscure ? t('Show password') : t('Hide password'),
      icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
      onPressed: () => setState(() => _obscure = !_obscure),
    );
    return Scaffold(
      appBar: AppBar(title: Text(t('Create Patient Account'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t('Create an account to find doctors and book visits.'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: t('Full name'),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: requiredField('Enter your full name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: t('Email'),
                    prefixIcon: const Icon(Icons.mail_outline),
                    errorText: _emailError,
                  ),
                  validator: validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: t('Password'),
                    helperText: t('At least 6 characters'),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: toggle,
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? t('Use at least 6 characters')
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirm,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: t('Confirm password'),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  validator: (v) =>
                      v != _password.text ? t('Passwords do not match') : null,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: t('Create Account'),
                  loading: _busy,
                  onPressed: _submit,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _busy ? null : () => Navigator.pop(context),
                  child: Text(t('Already have an account? Log In')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
