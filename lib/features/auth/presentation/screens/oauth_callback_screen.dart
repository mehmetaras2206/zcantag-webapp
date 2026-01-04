// =============================================================================
// OAUTH_CALLBACK_SCREEN.DART
// =============================================================================
// Screen die den OAuth-Callback verarbeitet und Token austauscht
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/core/theme/app_colors.dart';
import '../../../../shared/core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';

class OAuthCallbackScreen extends ConsumerStatefulWidget {
  const OAuthCallbackScreen({
    super.key,
    this.code,
    this.provider,
    this.error,
  });

  final String? code;
  final String? provider;
  final String? error;

  @override
  ConsumerState<OAuthCallbackScreen> createState() =>
      _OAuthCallbackScreenState();
}

class _OAuthCallbackScreenState extends ConsumerState<OAuthCallbackScreen> {
  bool _isProcessing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _processCallback();
  }

  Future<void> _processCallback() async {
    // Check for error from OAuth provider
    if (widget.error != null) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'OAuth-Fehler: ${widget.error}';
      });
      return;
    }

    // Check for required parameters
    if (widget.code == null || widget.provider == null) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Fehlende OAuth-Parameter';
      });
      return;
    }

    // Exchange code for tokens
    final error = await ref
        .read(authStateProvider.notifier)
        .handleOAuthCallback(widget.code!, widget.provider!);

    if (mounted) {
      if (error == null) {
        // Success - redirect to home
        context.go('/');
      } else {
        setState(() {
          _isProcessing = false;
          _errorMessage = error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                const Icon(
                  Icons.credit_card,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),

                if (_isProcessing) ...[
                  // Loading state
                  const CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Anmeldung wird verarbeitet...',
                    style: AppTextStyles.bodyRegular.copyWith(
                      color: AppColors.textWhite.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else if (_errorMessage != null) ...[
                  // Error state
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: AppTextStyles.bodyRegular.copyWith(
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Zurueck zur Anmeldung'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
