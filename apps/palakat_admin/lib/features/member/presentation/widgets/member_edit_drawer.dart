import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/validation.dart';
import 'package:palakat_admin/widgets.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_admin/features/church/application/church_controller.dart';
import 'package:palakat_admin/features/member/presentation/state/member_controller.dart';
import 'package:palakat_admin/models.dart' as cm show Column;

class MemberEditDrawer extends ConsumerStatefulWidget {
  final Function(Account) onSave;
  final VoidCallback? onDelete;
  final VoidCallback onClose;
  final int? accountId;

  const MemberEditDrawer({
    super.key,
    required this.onSave,
    this.onDelete,
    required this.onClose,
    this.accountId,
  });

  @override
  ConsumerState<MemberEditDrawer> createState() => _MemberEditDrawerState();
}

class _MemberEditDrawerState extends ConsumerState<MemberEditDrawer> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _emailFieldKey = GlobalKey();
  final _phoneFieldKey = GlobalKey();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Account? _fetchedAccount; // latest member copy (fetched)
  bool _loading = false;
  bool _deleting = false;
  bool _saving = false;
  bool _isBaptized = false;
  bool _isSidi = false;
  bool _isClaimed = false;
  MaritalStatus _maritalStatus = MaritalStatus.single;
  Gender _gender = Gender.male;
  DateTime? _dateOfBirth;
  final List<MemberPosition> _positions = [];
  cm.Column? _selectedColumn;
  String? _errorMessage;
  bool _isFormatting = false; // Prevent recursive formatting in onChanged
  String? _dateOfBirthError;
  String? _columnError;
  String? _emailError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    // Only fetch when editing an existing member
    if (widget.accountId != null) {
      _fetchAccountDetails();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _scrollToField(GlobalKey fieldKey) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = fieldKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.2, // Position field at 20% from top of viewport
        );
      }
    });
  }

  String _normalizePhoneDigits(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

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

  Future<void> _fetchAccountDetails() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final latest = await ref
          .read(memberControllerProvider.notifier)
          .fetchMember(widget.accountId!);

      setState(() {
        _loading = false;
        _errorMessage = null;
        _fetchedAccount = latest;
        _nameController.text = latest.name;
        _emailController.text = latest.email ?? '';
        // Format phone number for display
        final phoneDigits = _normalizePhoneDigits(latest.phone);
        _phoneController.text = _formatLocalPhone(phoneDigits);
        _isBaptized = latest.membership?.baptize ?? false;
        _isSidi = latest.membership?.sidi ?? false;
        _isClaimed = latest.claimed;
        _maritalStatus = latest.maritalStatus;
        _gender = latest.gender;
        _dateOfBirth = latest.dob;
        _positions.clear();
        _positions.addAll(latest.membership?.membershipPositions ?? []);
        _selectedColumn = latest.membership?.column;
      });
    } catch (e) {
      // Surface error inline but keep drawer open
      setState(() {
        _errorMessage = 'Failed to load member details';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveChanges() async {
    // Clear previous validation errors
    setState(() {
      _dateOfBirthError = null;
      _columnError = null;
      _emailError = null;
      _phoneError = null;
    });
    
    if (!_formKey.currentState!.validate()) return;
    
    // Validate date of birth
    bool hasError = false;
    if (_dateOfBirth == null) {
      setState(() {
        _dateOfBirthError = 'Date of birth is required';
      });
      hasError = true;
    }
    
    // Validate column
    if (_selectedColumn == null) {
      setState(() {
        _columnError = 'Column is required';
      });
      hasError = true;
    }
    
    if (hasError) return;
    
    Account account;

    //read locally saved account
    final localAccount = ref.read(authControllerProvider).value!.account;

    // Normalize phone number (strip formatting) before saving
    final normalizedPhone = _normalizePhoneDigits(_phoneController.text.trim());

    account = Account(
      id: _fetchedAccount?.id,
      claimed: _fetchedAccount?.claimed ?? false,
      name: _nameController.text.trim().toCamelCase,
      phone: normalizedPhone,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim().toLowerCase(),
      maritalStatus: _maritalStatus,
      gender: _gender,
      dob: _dateOfBirth!,
      createdAt: _fetchedAccount?.createdAt ?? DateTime.now(),
      membership: Membership(
        id: _fetchedAccount?.membership?.id,
        baptize: _isBaptized,
        sidi: _isSidi,
        createdAt: _fetchedAccount?.membership?.createdAt ?? DateTime.now(),
        membershipPositions: _positions,
        column: _selectedColumn,
        church:
            _fetchedAccount?.membership?.church ??
            localAccount.membership!.church,
      ),
    );

    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      await widget.onSave(account);
      if (!mounted) return;
      widget.onClose();
    } catch (e) {
      if (!mounted) return;
      
      // Check if error is a 400 status error with unique constraint violation
      if (e is AppError && e.statusCode == 400) {
        final message = e.message.toLowerCase();
        final details = (e.details ?? '').toLowerCase();
        final combinedMessage = '$message $details';
        
        // Check for unique email constraint
        if (combinedMessage.contains('unique') && combinedMessage.contains('email')) {
          setState(() {
            _emailError = 'This email is already in use';
            _saving = false;
          });
          _scrollToField(_emailFieldKey);
          return;
        }
        
        // Check for unique phone constraint
        if (combinedMessage.contains('unique') && combinedMessage.contains('phone')) {
          setState(() {
            _phoneError = 'This phone number is already in use';
            _saving = false;
          });
          _scrollToField(_phoneFieldKey);
          return;
        }
      }
      
      // For other errors, show generic error message
      setState(() {
        _errorMessage = 'Failed to save member';
        _saving = false;
      });
    }
  }

  void _deleteMember() {
    if (widget.onDelete != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Member'),
          content: const Text(
            'Are you sure you want to delete this member? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // close confirm dialog
                setState(() {
                  _deleting = true;
                  _errorMessage = null;
                });
                try {
                  widget.onDelete!();
                  if (!mounted) return;
                  widget.onClose();
                } catch (e) {
                  // Surface error inline; parent shows snackbar too
                  if (!mounted) return;
                  setState(() {
                    _errorMessage = 'Failed to delete member';
                  });
                } finally {
                  if (mounted) setState(() => _deleting = false);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Single watch for church data (positions & columns)
    final churchState = ref.watch(churchControllerProvider);
    final availablePositions = churchState.positions.value ?? [];
    final availableColumns = churchState.columns.value ?? [];

    return SideDrawer(
      title: widget.accountId == null ? 'Add Member' : 'Edit Member',
      subtitle: widget.accountId == null
          ? 'Create a new member'
          : 'Update member information',
      onClose: widget.onClose,
      isLoading: (widget.accountId != null && _loading) || _deleting || _saving,
      loadingMessage: _deleting
          ? 'Deleting member...'
          : _saving
          ? 'Saving member...'
          : 'Loading member details...',
      errorMessage: _errorMessage,
      onRetry: widget.accountId != null && !_deleting
          ? _fetchAccountDetails
          : null,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Information Section
            InfoSection(
              title: 'Account Information',
              titleSpacing: 16,
              children: [
                // Show ID field only when editing existing member
                if (_fetchedAccount != null) ...[
                  LabeledField(
                    label: 'Member ID',
                    child: Text(
                      "# ${_fetchedAccount!.id}",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_isClaimed) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(color: Colors.orange.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This account has been claimed. Account info can only be changed by the owner.',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                LabeledField(
                  label: 'Name',
                  child: TextFormField(
                    controller: _nameController,
                    enabled: !_isClaimed,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: 'Enter member name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: _isClaimed
                          ? theme.colorScheme.surfaceContainerHighest
                          : theme.colorScheme.surface,
                    ),
                    validator: (value) => Validators.required(
                      'Name is required',
                    ).asFormFieldValidator(value),
                  ),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  key: _emailFieldKey,
                  label: 'Email',
                  child: TextFormField(
                    controller: _emailController,
                    enabled: !_isClaimed,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter email address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme.error),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
                      ),
                      filled: true,
                      fillColor: _isClaimed
                          ? theme.colorScheme.surfaceContainerHighest
                          : theme.colorScheme.surface,
                      errorText: _emailError,
                      errorStyle: const TextStyle(fontSize: 12),
                    ),
                    onChanged: (value) {
                      // Clear error when user starts typing
                      if (_emailError != null) {
                        setState(() => _emailError = null);
                      }
                    },
                    validator: (value) => Validators.email(
                      'Please enter a valid email address',
                    ).asFormFieldValidator(value),
                  ),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  key: _phoneFieldKey,
                  label: 'Phone',
                  child: TextFormField(
                    controller: _phoneController,
                    enabled: !_isClaimed,
                    keyboardType: TextInputType.phone,
                    maxLength: 15,
                    decoration: InputDecoration(
                      hintText: '08xx-xxxx-xxxx',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme.error),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
                      ),
                      filled: true,
                      fillColor: _isClaimed
                          ? theme.colorScheme.surfaceContainerHighest
                          : theme.colorScheme.surface,
                      errorText: _phoneError,
                      errorStyle: const TextStyle(fontSize: 12),
                    ),
                    onChanged: (value) {
                      // Clear error when user starts typing
                      if (_phoneError != null) {
                        setState(() => _phoneError = null);
                      }
                      
                      if (_isFormatting) return;
                      // Strip all non-digits and limit to 13 (no country code)
                      final digits = _normalizePhoneDigits(value);
                      final limited = digits.length > 13 ? digits.substring(0, 13) : digits;
                      final formatted = _formatLocalPhone(limited);
                      if (formatted != value) {
                        _isFormatting = true;
                        final baseOffset = formatted.length;
                        _phoneController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: baseOffset),
                        );
                        _isFormatting = false;
                      }
                    },
                    validator: (v) => Validators.combine<String>([
                      Validators.required('Phone number is required'),
                      Validators.optionalPhoneMinDigits(12, 'Phone number must contain at least 12 digits'),
                    ]).asFormFieldValidator(v),
                  ),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Marital Status',
                  child: MaritalStatusDropdown(
                    value: _maritalStatus,
                    enabled: !_isClaimed,
                    onChanged: (MaritalStatus? newValue) {
                      setState(() {
                        _maritalStatus = newValue ?? MaritalStatus.single;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Gender',
                  child: GenderDropdown(
                    value: _gender,
                    enabled: !_isClaimed,
                    onChanged: (Gender? newValue) {
                      setState(() {
                        _gender = newValue ?? Gender.male;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Date of Birth',
                  child: DateOfBirthPicker(
                    value: _dateOfBirth,
                    enabled: !_isClaimed,
                    errorText: _dateOfBirthError,
                    onChanged: (DateTime? newDate) {
                      setState(() {
                        _dateOfBirth = newDate;
                        _dateOfBirthError = null; // Clear error when user selects a date
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Membership Information Section
            InfoSection(
              title: 'Membership Information',
              titleSpacing: 16,
              children: [
                PositionSelector(
                  selectedPositions: _positions,
                  onPositionsChanged: (positions) {
                    setState(() {
                      _positions
                        ..clear()
                        ..addAll(positions);
                    });
                  },
                  availablePositions: availablePositions,
                  label: 'Positions',
                ),
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Column',
                  child: DropdownButtonFormField<cm.Column?>(
                    value: _selectedColumn,
                    decoration: InputDecoration(
                      hintText: 'Select a column',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme.error),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      errorText: _columnError,
                      errorStyle: const TextStyle(fontSize: 12),
                    ),
                    items: availableColumns.map((column) {
                      return DropdownMenuItem<cm.Column?>(
                        value: column,
                        child: Text(column.name),
                      );
                    }).toList(),
                    onChanged: (cm.Column? newValue) {
                      setState(() {
                        _selectedColumn = newValue;
                        _columnError = null; // Clear error when user selects a column
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Baptized'),
                        value: _isBaptized,
                        onChanged: (value) =>
                            setState(() => _isBaptized = value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('SIDI'),
                        value: _isSidi,
                        onChanged: (value) =>
                            setState(() => _isSidi = value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      footer: Row(
        children: [
          if (widget.onDelete != null && widget.accountId != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _deleteMember,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                ),
                child: const Text('Delete'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: Text(widget.accountId == null ? 'Create' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }
}
