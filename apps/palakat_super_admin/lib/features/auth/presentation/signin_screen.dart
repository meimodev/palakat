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
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '');
    final newDigits = newValue.text.replaceAll(RegExp(r'\D'), '');

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
    final digitsBeforeCursor = oldValue.text
        .substring(0, oldCursorPosition)
        .replaceAll(RegExp(r'\D'), '')
        .length;

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
                    children: [
                      Row(
                        children: [
                          Text(
                            'Palakat',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: const Text('SUPER ADMIN'),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Super Admin Phone',
                        ),
                        enabled: !isLoading,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _PhoneInputFormatter(),
                        ],
                        validator: (v) => Validators.required(
                          'Phone is required',
                        ).asFormFieldValidator(v),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Super Admin Password',
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
                        obscureText: _obscure,
                        enabled: !isLoading,
                        onFieldSubmitted: (_) => submit(),
                        validator: (v) => Validators.required(
                          'Password is required',
                        ).asFormFieldValidator(v),
                      ),
                      if (errorText != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          errorText,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: isLoading ? null : submit,
                        child: isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Sign in'),
                      ),
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
