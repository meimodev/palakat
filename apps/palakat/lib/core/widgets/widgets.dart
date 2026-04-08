/// Palakat app widgets
///
/// This file re-exports widgets from palakat_shared and provides
/// app-specific widget implementations where needed.
library;

// =============================================================================
// RE-EXPORTS FROM SHARED PACKAGE
// =============================================================================

// Button widgets
export 'package:palakat_shared/core/widgets/button/button_widget.dart';

// Card widgets
export 'package:palakat_shared/core/widgets/card/card.dart';

// Chips widgets
export 'package:palakat_shared/core/widgets/chips/chips.dart';

// Dialog widgets (with app-specific overrides)
export 'package:palakat_shared/core/widgets/dialog/dialogs.dart'
    hide showDialogChurchPickerWidget, showDialogColumnPickerWidget;

// Divider widget
export 'package:palakat_shared/core/widgets/divider_widget.dart';

// Error widgets
export 'package:palakat_shared/core/widgets/error/error.dart';

// Image widgets
export 'package:palakat_shared/core/widgets/image/image.dart';

// Info box widgets
export 'package:palakat_shared/core/widgets/info_box/info_box.dart';

// Input widgets
export 'package:palakat_shared/core/widgets/input/input.dart';

// Loading widgets
export 'package:palakat_shared/core/widgets/loading/loading.dart';

// Output widgets
export 'package:palakat_shared/core/widgets/output/output.dart';

// Title widgets
export 'package:palakat_shared/core/widgets/title/title.dart';

// Mobile widgets from shared
export 'package:palakat_shared/core/widgets/mobile/mobile.dart'
    hide AppBarWidget, BottomNavBar, BottomNavBarItem;
// Export NavDestination for building custom navigation
export 'package:palakat_shared/core/widgets/mobile/bottom_navbar.dart'
    show NavDestination;

// =============================================================================
// APP-SPECIFIC WIDGETS
// =============================================================================

// Account Number Picker - app-specific (uses Riverpod providers)
export 'account_number_picker/account_number_picker_barrel.dart';

// Bottom Nav Bar - app-specific implementations using local assets
export 'bottom_navbar/bottom_navbar.dart';

// Dialog - app-specific dialog widgets that use local controllers
export 'dialog/dialog_church_picker_widget.dart';
export 'dialog/dialog_column_picker_widget.dart';

// Input - app-specific input widgets
export 'input/input_multiple_select_widget.dart';

// Segment Title
export 'segment_title/form_section_widget.dart';

// Icon widget - app-specific helper for Font Awesome icons
export 'app_icon_widget.dart';
