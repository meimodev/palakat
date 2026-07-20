import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column;

import '../application/super_admin_auth_controller.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _PhoneInputFormatter extends TextInputFormatter {
  String _digitsOnly(String value) {
    final buffer = StringBuffer();
    for (final codeUnit in value.codeUnits) {
      if (codeUnit >= 48 && codeUnit <= 57) {
        buffer.writeCharCode(codeUnit);
      }
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldDigits = _digitsOnly(oldValue.text);
    final newDigits = _digitsOnly(newValue.text);

    final limitedDigits = newDigits.length > 13
        ? newDigits.substring(0, 13)
        : newDigits;

    final buffer = StringBuffer();
    for (int i = 0; i < limitedDigits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write('-');
      }
      buffer.write(limitedDigits[i]);
    }

    final formattedText = buffer.toString();

    final oldCursorPosition = oldValue.selection.baseOffset;
    final digitsBeforeCursor = _digitsOnly(
      oldValue.text.substring(0, oldCursorPosition),
    ).length;

    int targetDigitPosition = digitsBeforeCursor;
    if (newDigits.length > oldDigits.length) {
      targetDigitPosition =
          digitsBeforeCursor + (newDigits.length - oldDigits.length);
    } else if (newDigits.length < oldDigits.length) {
      targetDigitPosition =
          digitsBeforeCursor - (oldDigits.length - newDigits.length);
    }

    targetDigitPosition = targetDigitPosition.clamp(0, limitedDigits.length);

    int newOffset = 0;
    int digitCount = 0;
    for (
      int i = 0;
      i < formattedText.length && digitCount < targetDigitPosition;
      i++
    ) {
      if (formattedText[i] != '-') {
        digitCount++;
      }
      newOffset = i + 1;
    }

    newOffset = newOffset.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncAuth = ref.watch(superAdminAuthControllerProvider);
    final isLoading = asyncAuth.isLoading;
    final l10n = context.l10n;

    Future<void> submit() async {
      if (!(_formKey.currentState?.validate() ?? false)) return;
      await ref
          .read(superAdminAuthControllerProvider.notifier)
          .signIn(
            phone: _phoneController.text,
            password: _passwordController.text,
          );
    }

    ref.listen(superAdminAuthControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (token) {
          if (token != null && mounted) {
            context.go('/articles');
          }
        },
      );
    });

    final errorText = asyncAuth.whenOrNull(error: (e, _) => e.toString());

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            final theme = Theme.of(context);
            final horizontalPadding = SanctuaryLayout.horizontalPadding(
              constraints.maxWidth,
            );

            final formPanel = ConstrainedBox(
              constraints: BoxConstraints(maxWidth: compact ? 560 : 460),
              child: SurfaceCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            SanctuaryLayout.radiusLarge,
                          ),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.app_superAdminTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.auth_signInSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(labelText: l10n.lbl_phone),
                        enabled: !isLoading,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _PhoneInputFormatter(),
                        ],
                        validator: (v) => Validators.required(
                          l10n.validation_requiredField,
                        ).asFormFieldValidator(v),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: l10n.lbl_password,
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
                        obscureText: _obscure,
                        enabled: !isLoading,
                        onFieldSubmitted: (_) => submit(),
                        validator: (v) => Validators.required(
                          l10n.validation_passwordRequired,
                        ).asFormFieldValidator(v),
                      ),
                      if (errorText != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          errorText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: isLoading ? null : submit,
                          child: LoadingActionContent(
                            isLoading: isLoading,
                            loaderSize: 18,
                            child: Text(l10n.btn_signIn),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

            final insightPanel = Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(
                  SanctuaryLayout.radiusLarge,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(
                            SanctuaryLayout.radius,
                          ),
                        ),
                        child: const Icon(
                          Icons.security_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Flexible(
                        child: Text(
                          l10n.appTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Sanctuary oversight for governance, publishing, and system stewardship.',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Review church onboarding, curate songs and articles, and keep the wider ecosystem aligned in one calm command surface.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Protected workspace',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Administrative actions are isolated behind super-admin access to preserve platform integrity.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

            return Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1360),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 24,
                  ),
                  child: compact
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            insightPanel,
                            const SizedBox(height: 24),
                            formPanel,
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(flex: 7, child: insightPanel),
                            const SizedBox(width: 32),
                            Expanded(flex: 4, child: formPanel),
                          ],
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
