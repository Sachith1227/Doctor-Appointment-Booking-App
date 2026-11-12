import 'package:flutter/material.dart';

import '../../l10n.dart';
import '../../mock_store.dart';
import '../../widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _busy = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    await Future<void>.delayed(MockStore.latency);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t('Forgot Password'))),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _sent ? _confirmation(context) : _form(context),
        ),
      ),
    );
  }

  Widget _form(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t(
                'Enter your email. We will send you a link to make a new '
                'password.',
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: t('Email'),
                prefixIcon: const Icon(Icons.mail_outline),
              ),
              validator: validateEmail,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: t('Send Reset Link'),
              loading: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmation(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      key: const ValueKey('sent'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_read_outlined,
                size: 42,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              t('Check your email'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t(
                'If there is an account for {0}, we have sent a link to make '
                'a new password.',
                [_email.text.trim()],
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: t('Back to Log In'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              onPressed: () => setState(() => _sent = false),
              child: Text(t('Use a different email')),
            ),
          ],
        ),
      ),
    );
  }
}
