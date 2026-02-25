import 'dart:async';

import 'package:blink_flutter/features/auth/presentation/pages/forgot_password_reset_page.dart';
import 'package:blink_flutter/features/auth/presentation/providers/forgot_password_otp_notifier.dart';
import 'package:blink_flutter/features/auth/presentation/state/auth_recovery_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordOtpPage extends ConsumerStatefulWidget {
  final String email;

  const ForgotPasswordOtpPage({super.key, required this.email});

  @override
  ConsumerState<ForgotPasswordOtpPage> createState() =>
      _ForgotPasswordOtpPageState();
}

class _ForgotPasswordOtpPageState extends ConsumerState<ForgotPasswordOtpPage> {
  final _otpController = TextEditingController();
  Timer? _timer;
  int _secondsLeft = 60;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('OTP must be 6 digits')));
      return;
    }

    await ref
        .read(forgotPasswordOtpNotifierProvider.notifier)
        .verifyOtp(email: widget.email, otp: otp);
  }

  Future<void> _resendOtp() async {
    await ref
        .read(forgotPasswordOtpNotifierProvider.notifier)
        .resendOtp(email: widget.email);
  }

  @override
  Widget build(BuildContext context) {
    final recoveryState = ref.watch(forgotPasswordOtpNotifierProvider);

    ref.listen<AuthRecoveryState>(forgotPasswordOtpNotifierProvider, (
      previous,
      next,
    ) {
      if (next.status == AuthRecoveryStatus.error && next.message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message!)));
      }

      if (next.status == AuthRecoveryStatus.success && next.message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message!)));
      }

      final token = (next.resetToken ?? '').trim();
      if (next.status == AuthRecoveryStatus.success && token.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ForgotPasswordResetPage(email: widget.email, resetToken: token),
          ),
        );
      }
    });

    final isLoading = recoveryState.status == AuthRecoveryStatus.loading;
    final canResend = _secondsLeft == 0 && !isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OTP sent to ${widget.email}'),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: '6-digit OTP',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _verifyOtp,
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify OTP'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: canResend
                  ? () async {
                      await _resendOtp();
                      if (!mounted) return;
                      _startCooldown();
                    }
                  : null,
              child: Text(
                canResend ? 'Resend OTP' : 'Resend OTP in ${_secondsLeft}s',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
