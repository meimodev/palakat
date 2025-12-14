import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final notifier = ref.read(authControllerProvider.notifier);
    final raw = _identifierCtrl.text.trim();
    final identifier = raw.contains('@') ? raw : _normalizePhoneDigits(raw);
    await notifier.signIn(identifier: identifier, password: _passwordCtrl.text);
  }

  String _normalizePhoneDigits(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  // Prevent recursive formatting in onChanged
  bool _isFormatting = false;

  String _formatLocalPhone(String digits) {
    // Group per 4 digits; when length == 13, last group is 5 digits (4-4-5). Use '-' as separator.
    if (digits.isEmpty) return digits;
    final len = digits.length;
    // Cap at 13 for display
    final capped = len > 13 ? digits.substring(0, 13) : digits;
    final n = capped.length;

    if (n <= 4) return capped; // up to 4: raw
    if (n <= 8) {
      // 4 + remainder
      return '${capped.substring(0, 4)}-${capped.substring(4)}';
    }
    if (n < 13) {
      // 9..12: 4-4-remaining (1..4)
      return '${capped.substring(0, 4)}-${capped.substring(4, 8)}-${capped.substring(8)}';
    }
    // n == 13: 4-4-5
    return '${capped.substring(0, 4)}-${capped.substring(4, 8)}-${capped.substring(8, 13)}';
  }

  @override
  Widget build(BuildContext context) {
    final asyncAuth = ref.watch(authControllerProvider);
    final isLoading = asyncAuth.isLoading;

    // Listen to auth state changes to handle navigation and errors centrally
    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (auth) {
          if (auth != null && mounted) {
            context.go('/dashboard');
          }
        },
        error: (e, st) {
          // No SnackBar here; error will be shown inline below the form
        },
      );
    });

    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Icon(
                              Icons.lock_outline,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.auth_welcomeBack,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.auth_signInSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Identifier
                      TextFormField(
                        controller: _identifierCtrl,
                        decoration: InputDecoration(
                          labelText:
                              '${context.l10n.lbl_email} / ${context.l10n.lbl_phone}',
                          hintText: context.l10n.hint_signInCredentials,
                          border: const OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                        onChanged: (value) {
                          if (_isFormatting) return;
                          // If it contains letters (likely email or mixed), don't format
                          if (value.contains('@') ||
                              RegExp(r'[A-Za-z]').hasMatch(value)) {
                            return;
                          }
                          // Strip all non-digits and limit to 13 (no country code)
                          final digits = _normalizePhoneDigits(value);
                          final limited = digits.length > 13
                              ? digits.substring(0, 13)
                              : digits;
                          final formatted = _formatLocalPhone(limited);
                          if (formatted != value) {
                            _isFormatting = true;
                            final baseOffset = formatted.length;
                            _identifierCtrl.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                offset: baseOffset,
                              ),
                            );
                            _isFormatting = false;
                          }
                        },
                        validator: (v) =>
                            AuthValidators.identifier().asFormFieldValidator(v),
                      ),
                      const SizedBox(height: 12),

                      // Password
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: context.l10n.lbl_password,
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => _submit(),
                        validator: (v) => Validators.required(
                          context.l10n.validation_passwordRequired,
                        ).asFormFieldValidator(v),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: isLoading ? null : _submit,
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(context.l10n.btn_signIn),
                        ),
                      ),

                      const SizedBox(height: 12),
                      if (asyncAuth.hasError) ...[
                        CompactErrorWidget(
                          error: asyncAuth.error as AppError,
                          isSignInContext: true,
                        ),
                      ],
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
