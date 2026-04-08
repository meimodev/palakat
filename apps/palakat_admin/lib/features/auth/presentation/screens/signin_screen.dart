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
    final buffer = StringBuffer();
    for (final codeUnit in input.codeUnits) {
      if (codeUnit >= 48 && codeUnit <= 57) {
        buffer.writeCharCode(codeUnit);
      }
    }
    return buffer.toString();
  }

  bool _containsAsciiLetter(String input) {
    for (final codeUnit in input.codeUnits) {
      if ((codeUnit >= 65 && codeUnit <= 90) ||
          (codeUnit >= 97 && codeUnit <= 122)) {
        return true;
      }
    }
    return false;
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
    final authError = asyncAuth.error;
    final appError = authError is AppError
        ? authError
        : authError == null
        ? null
        : AppError.serverError(
            authError.toString(),
            details: authError.toString(),
          );

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
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compactSignIn = constraints.maxWidth < 720;
            final horizontalPadding = SanctuaryLayout.horizontalPadding(
              constraints.maxWidth,
            );

            final formPanel = SurfaceCard(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compactSignIn ? 4 : 8,
                  vertical: 4,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(
                            SanctuaryLayout.radiusLarge,
                          ),
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        context.l10n.auth_welcomeBack,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.auth_signInSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _identifierCtrl,
                        decoration: InputDecoration(
                          labelText:
                              '${context.l10n.lbl_email} / ${context.l10n.lbl_phone}',
                          hintText: context.l10n.hint_signInCredentials,
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                        onChanged: (value) {
                          if (_isFormatting) return;
                          if (value.contains('@') ||
                              _containsAsciiLetter(value)) {
                            return;
                          }
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
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: context.l10n.lbl_password,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
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
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: isLoading ? null : _submit,
                          child: LoadingActionContent(
                            isLoading: isLoading,
                            loaderSize: 22,
                            child: Text(context.l10n.btn_signIn),
                          ),
                        ),
                      ),
                      if (asyncAuth.hasError && appError != null) ...[
                        const SizedBox(height: 14),
                        CompactErrorWidget(
                          error: appError,
                          isSignInContext: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );

            final brandPanel = Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(
                  SanctuaryLayout.radiusLarge,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(
                        SanctuaryLayout.radiusLarge,
                      ),
                    ),
                    child: const Icon(
                      Icons.church_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Palakat Admin ',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kelola sistem aplikasi gereja anda, secara lengkap dan real-time',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );

            final content = compactSignIn
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      brandPanel,
                      const SizedBox(height: 24),
                      formPanel,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 7, child: brandPanel),
                      const SizedBox(width: 32),
                      Expanded(flex: 4, child: formPanel),
                    ],
                  );

            return Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 24,
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1360),
                      child: content,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
