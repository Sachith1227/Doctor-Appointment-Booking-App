import 'package:flutter/material.dart';

import '../../app_router.dart';
import '../../l10n.dart';
import '../../mock_store.dart';
import '../../widgets.dart';
import 'forgot_password_screen.dart';
import 'launch_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await store.login(_email.text, _password.text);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _error = error;
      });
      return;
    }
    goHome(context);
  }

  void _fill(String email, String password) {
    setState(() {
      _email.text = email;
      _password.text = password;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: LanguageToggle()),
                  const SizedBox(height: 24),
                  const AppLogo(size: 76),
                  const SizedBox(height: 8),
                  Text(
                    t('Log in to find a doctor and book a visit'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: _error == null
                        ? const SizedBox(width: double.infinity)
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _ErrorBanner(_error!),
                          ),
                  ),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: t('Email'),
                      prefixIcon: const Icon(Icons.mail_outline),
                    ),
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: t('Password'),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _obscure
                            ? t('Show password')
                            : t('Hide password'),
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: requiredField('Enter your password'),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _busy
                          ? null
                          : () => push(context, const ForgotPasswordScreen()),
                      child: Text(t('Forgot Password?')),
                    ),
                  ),
                  const SizedBox(height: 4),
                  PrimaryButton(
                    label: t('Log In'),
                    loading: _busy,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => push(context, const RegisterScreen()),
                    child: Text(t('Create Patient Account')),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    t('Demo accounts – tap to fill'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.person_outline, size: 18),
                        label: Text(t('Patient')),
                        onPressed: () =>
                            _fill('nimal@example.com', 'patient123'),
                      ),
                      ActionChip(
                        avatar: const Icon(
                          Icons.medical_services_outlined,
                          size: 18,
                        ),
                        label: Text(t('Doctor')),
                        onPressed: () => _fill(
                          'anjali.perera@mydoctor.lk',
                          MockStore.demoDoctorPassword,
                        ),
                      ),
                      ActionChip(
                        avatar: const Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 18,
                        ),
                        label: Text(t('Admin')),
                        onPressed: () => _fill('admin@mydoctor.lk', 'admin123'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
