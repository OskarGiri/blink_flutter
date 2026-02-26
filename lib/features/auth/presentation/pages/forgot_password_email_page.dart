import 'package:blink_flutter/features/auth/presentation/pages/forgot_password_otp_page.dart';
import 'package:blink_flutter/features/auth/presentation/providers/forgot_password_email_notifier.dart';
import 'package:blink_flutter/features/auth/presentation/state/auth_recovery_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordEmailPage extends ConsumerStatefulWidget {
  const ForgotPasswordEmailPage({super.key});

  @override
  ConsumerState<ForgotPasswordEmailPage> createState() =>
      _ForgotPasswordEmailPageState();
}

class _ForgotPasswordEmailPageState
    extends ConsumerState<ForgotPasswordEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(forgotPasswordEmailNotifierProvider.notifier)
        .sendOtp(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final recoveryState = ref.watch(forgotPasswordEmailNotifierProvider);

    ref.listen<AuthRecoveryState>(forgotPasswordEmailNotifierProvider, (
      previous,
      next,
    ) {
      if (next.status == AuthRecoveryStatus.error && next.message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message!)));
      }

      if (next.status == AuthRecoveryStatus.success) {
        if (next.message != null && next.message!.isNotEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(next.message!)));
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ForgotPasswordOtpPage(email: _emailController.text.trim()),
          ),
        );
      }
    });

    final isLoading = recoveryState.status == AuthRecoveryStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your email to receive a 6-digit OTP.',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final email = (value ?? '').trim();
                  if (email.isEmpty) return 'Email is required';
                  if (!email.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send OTP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
