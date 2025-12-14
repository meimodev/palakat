import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/models/language_option.dart';
import 'package:palakat_shared/core/services/locale_controller.dart';

/// A widget that allows users to select their preferred language.
///
/// Displays the current language with a flag emoji and opens a dialog
/// with available language options when tapped.
///
/// Requirements: 6.3, 6.4
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeControllerProvider);
    final currentOption = getLanguageOption(currentLocale);
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _showLanguageDialog(context, ref, currentOption),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(currentOption.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(currentOption.name, style: theme.textTheme.bodyLarge),
            ),
            Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurface),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    LanguageOption currentOption,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _LanguageSelectionDialog(
        currentOption: currentOption,
        onSelect: (option) {
          ref.read(localeControllerProvider.notifier).setLocale(option.locale);
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }
}

/// Dialog widget for selecting a language from available options.
class _LanguageSelectionDialog extends StatelessWidget {
  final LanguageOption currentOption;
  final ValueChanged<LanguageOption> onSelect;

  const _LanguageSelectionDialog({
    required this.currentOption,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.lbl_language),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: supportedLanguageOptions.map((option) {
          final isSelected = option.matches(currentOption.locale);
          return ListTile(
            leading: Text(option.flag, style: const TextStyle(fontSize: 24)),
            title: Text(option.name),
            trailing: isSelected
                ? Icon(Icons.check, color: theme.colorScheme.primary)
                : null,
            selected: isSelected,
            onTap: () => onSelect(option),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.btn_cancel),
        ),
      ],
    );
  }
}
