/// Reusable UI widgets for Flutter applications
///
/// This library exports all widget categories:
/// - Button widgets
/// - Card widgets
/// - Chips widgets
/// - Dialog widgets
/// - Error widgets
/// - Image widgets
/// - Info box widgets
/// - Input widgets
/// - Loading widgets
/// - Output widgets
/// - Title widgets
///
/// Note: Mobile-specific widgets (AppBar, BottomNavBar, Scaffold) are NOT
/// exported here to avoid conflicts with app-specific implementations.
/// Import them directly from:
/// `package:palakat_shared/core/widgets/mobile/mobile.dart`
library;

// =============================================================================
// CATEGORY EXPORTS (organized by functional category)
// =============================================================================

// Button widgets
export 'button/button_widget.dart';

// Card widgets
export 'card/card.dart';

// Chips widgets
export 'chips/chips.dart';

// Dialog widgets
export 'dialog/dialogs.dart';

// Error widgets
export 'error/error.dart';

// Image widgets
export 'image/image.dart';

// Info box widgets
export 'info_box/info_box.dart';

// Input widgets
export 'input/input.dart';

// Loading widgets
export 'loading/loading.dart';

// Output widgets
export 'output/output.dart';

// Title widgets (screen title, segment title)
export 'title/title.dart';

// =============================================================================
// STANDALONE WIDGETS (not in category subdirectories)
// =============================================================================

// Activity and status widgets
export 'activity_type_chip.dart';
export 'compact_status_chip.dart';
export 'payment_method_chip.dart';
export 'position_chip.dart';
export 'status_badge.dart';
export 'status_chip.dart';
export 'supervisor_chip.dart';
export 'type_chip.dart';

// Approval widgets
export 'approval_id_cell.dart';
export 'approver_card.dart';
export 'supervisor_card.dart';

// Date and picker widgets
export 'date_of_birth_picker.dart';
export 'date_range_filter.dart';
export 'financial_account_picker.dart';
export 'gender_dropdown.dart';
export 'language_selector.dart';
export 'marital_status_dropdown.dart';
export 'position_selector.dart';

// Layout and container widgets
export 'divider_widget.dart';
export 'expandable_surface_card.dart';
export 'info_section.dart';
export 'quick_stat_card.dart';
export 'surface_card.dart';

// Navigation and layout widgets
export 'side_drawer.dart';
export 'sidebar.dart';

// Table and list widgets
export 'app_table.dart';
export 'pagination_bar.dart';
export 'positions_cell.dart';
export 'smooth_list_view.dart';

// Feedback widgets
export 'app_snackbars.dart';

// Form widgets
export 'validated_text_field.dart';

// Search widgets
export 'search_field.dart';
export 'searchable_dialog_picker.dart';
