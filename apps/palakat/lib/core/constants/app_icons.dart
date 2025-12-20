import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Centralized icon registry for the Palakat app.
/// All icons should be accessed through this class for consistency.
///
/// Icons are organized by category:
/// - Navigation: back, forward, chevrons, home, grid
/// - Actions: approve, reject, close, delete, search, download
/// - Status: pending, inProgress, success, error, warning, info
/// - Content: document, calendar, event, announcement, music, reader
/// - User/Account: person, church, phone, supervisor
/// - Financial: money, revenue, expense, payment, bankAccount, wallet
/// - Location: mapPin, location, gps, map, coordinates
/// - Time: time, schedule, createdAt
abstract class AppIcons {
  AppIcons._();

  // ============ Navigation Icons ============

  /// Back navigation arrow
  static const IconData back = FontAwesomeIcons.chevronLeft;

  /// Forward navigation arrow
  static const IconData forward = FontAwesomeIcons.chevronRight;

  /// Forward arrow (iOS style)
  static const IconData arrowForward = FontAwesomeIcons.angleRight;

  /// Dropdown indicator
  static const IconData chevronDown = FontAwesomeIcons.chevronDown;

  /// Expand indicator
  static const IconData chevronUp = FontAwesomeIcons.chevronUp;

  /// Home navigation
  static const IconData home = FontAwesomeIcons.house;

  /// Grid/dashboard view
  static const IconData grid = FontAwesomeIcons.grip;

  // ============ Action Icons ============

  /// Approve/confirm action
  static const IconData approve = FontAwesomeIcons.circleCheck;

  /// Reject/cancel action
  static const IconData reject = FontAwesomeIcons.xmark;

  /// Close dialog/modal
  static const IconData close = FontAwesomeIcons.xmark;

  /// Delete item
  static const IconData delete = FontAwesomeIcons.trash;

  /// Search action
  static const IconData search = FontAwesomeIcons.magnifyingGlass;

  /// Download action
  static const IconData download = FontAwesomeIcons.download;

  /// Open external link
  static const IconData openExternal = FontAwesomeIcons.arrowUpRightFromSquare;

  /// Clear/remove action
  static const IconData clear = FontAwesomeIcons.xmark;

  /// Edit action
  static const IconData edit = FontAwesomeIcons.penToSquare;

  // ============ Status Icons ============

  /// Pending/waiting status
  static const IconData pending = FontAwesomeIcons.clock;

  /// In progress/processing
  static const IconData inProgress = FontAwesomeIcons.hourglassHalf;

  /// Success/completed status
  static const IconData success = FontAwesomeIcons.circleCheck;

  /// Success/completed status (solid variant)
  static const IconData successSolid = FontAwesomeIcons.solidCircleCheck;

  /// Error/failed status
  static const IconData error = FontAwesomeIcons.circleExclamation;

  /// Warning status
  static const IconData warning = FontAwesomeIcons.triangleExclamation;

  /// Info status
  static const IconData info = FontAwesomeIcons.circleInfo;

  /// Cancel/rejected status (solid X circle)
  static const IconData cancel = FontAwesomeIcons.solidCircleXmark;

  // ============ Content Icons ============

  /// Document/file
  static const IconData document = FontAwesomeIcons.fileLines;

  /// Calendar/date
  static const IconData calendar = FontAwesomeIcons.calendar;

  /// Event/activity
  static const IconData event = FontAwesomeIcons.calendarDay;

  /// Announcement/campaign
  static const IconData announcement = FontAwesomeIcons.bullhorn;

  /// Notes/memo
  static const IconData notes = FontAwesomeIcons.noteSticky;

  /// Description/text
  static const IconData description = FontAwesomeIcons.alignLeft;

  /// Music/songs
  static const IconData music = FontAwesomeIcons.music;

  /// Reader/book
  static const IconData reader = FontAwesomeIcons.bookOpen;

  /// Approval workflow
  static const IconData approval = FontAwesomeIcons.clipboardCheck;

  /// Library music/music collection
  static const IconData libraryMusic = FontAwesomeIcons.recordVinyl;

  /// Library books/book collection
  static const IconData libraryBooks = FontAwesomeIcons.bookBookmark;

  /// Search off/no search results
  static const IconData searchOff = FontAwesomeIcons.magnifyingGlassMinus;

  /// Music off/no music
  static const IconData musicOff = FontAwesomeIcons.volumeXmark;

  /// Music note/single note
  static const IconData musicNote = FontAwesomeIcons.music;

  // ============ User/Account Icons ============

  /// Person/user
  static const IconData person = FontAwesomeIcons.user;

  /// Church/organization
  static const IconData church = FontAwesomeIcons.church;

  /// Phone
  static const IconData phone = FontAwesomeIcons.phone;

  /// Supervisor/manager
  static const IconData supervisor = FontAwesomeIcons.userTie;

  // ============ Financial Icons ============

  /// Money/amount
  static const IconData money = FontAwesomeIcons.dollarSign;

  /// Revenue/income (trending up)
  static const IconData revenue = FontAwesomeIcons.arrowTrendUp;

  /// Expense/cost (trending down)
  static const IconData expense = FontAwesomeIcons.arrowTrendDown;

  /// Payment method
  static const IconData payment = FontAwesomeIcons.creditCard;

  /// Bank account
  static const IconData bankAccount = FontAwesomeIcons.buildingColumns;

  /// Wallet
  static const IconData wallet = FontAwesomeIcons.wallet;

  /// Cash payment
  static const IconData cash = FontAwesomeIcons.moneyBill;

  // ============ Location Icons ============

  /// Map pin/marker
  static const IconData mapPin = FontAwesomeIcons.locationDot;

  /// Location/address
  static const IconData location = FontAwesomeIcons.locationDot;

  /// GPS/current location
  static const IconData gps = FontAwesomeIcons.locationCrosshairs;

  /// Map view
  static const IconData map = FontAwesomeIcons.map;

  /// Coordinates
  static const IconData coordinates = FontAwesomeIcons.crosshairs;

  // ============ Time Icons ============

  /// Time/clock
  static const IconData time = FontAwesomeIcons.clock;

  /// Timer/countdown
  static const IconData timer = FontAwesomeIcons.stopwatch;

  /// Schedule/timetable
  static const IconData schedule = FontAwesomeIcons.calendarDays;

  /// Created at/timestamp
  static const IconData createdAt = FontAwesomeIcons.clockRotateLeft;

  // ============ Security Icons ============

  /// Security/shield
  static const IconData security = FontAwesomeIcons.shieldHalved;

  // ============ Misc Icons ============

  /// Check/checkmark
  static const IconData check = FontAwesomeIcons.check;

  /// Logout/sign out
  static const IconData logout = FontAwesomeIcons.rightFromBracket;

  /// Settings/gear
  static const IconData settings = FontAwesomeIcons.gear;

  /// Sync/refresh
  static const IconData sync = FontAwesomeIcons.arrowsRotate;

  /// Event busy/no events
  static const IconData eventBusy = FontAwesomeIcons.calendarXmark;

  /// Person pin/self indicator
  static const IconData personPin = FontAwesomeIcons.userCheck;

  /// Notification/bell
  static const IconData notification = FontAwesomeIcons.bell;

  /// Notification active/bell ringing
  static const IconData notificationActive = FontAwesomeIcons.solidBell;

  /// How to register/verified user
  static const IconData verified = FontAwesomeIcons.userCheck;

  /// Handshake/partnership
  static const IconData handshake = FontAwesomeIcons.handshake;

  /// Assessment/analytics
  static const IconData assessment = FontAwesomeIcons.chartLine;

  /// Publish/share
  static const IconData publish = FontAwesomeIcons.share;

  /// Bar chart/statistics
  static const IconData barChart = FontAwesomeIcons.chartBar;

  /// Badge/credential
  static const IconData badge = FontAwesomeIcons.idBadge;

  /// Work/briefcase
  static const IconData work = FontAwesomeIcons.briefcase;

  /// Inventory/boxes
  static const IconData inventory = FontAwesomeIcons.boxesStacked;

  /// Refresh/retry
  static const IconData refresh = FontAwesomeIcons.arrowsRotate;

  /// More options/vertical ellipsis
  static const IconData moreVert = FontAwesomeIcons.ellipsisVertical;

  /// Auto awesome/sparkles
  static const IconData autoAwesome = FontAwesomeIcons.wandMagicSparkles;

  /// Filter list
  static const IconData filterList = FontAwesomeIcons.filter;

  /// Filter list off
  static const IconData filterListOff = FontAwesomeIcons.filterCircleXmark;

  /// Supervisor account
  static const IconData supervisorAccount = FontAwesomeIcons.userGroup;

  /// Keyboard arrow down
  static const IconData keyboardArrowDown = FontAwesomeIcons.chevronDown;

  /// Work off/no work
  static const IconData workOff = FontAwesomeIcons.briefcase;

  /// Apps/grid view
  static const IconData apps = FontAwesomeIcons.grip;

  /// Arrow forward iOS style
  static const IconData arrowForwardIos = FontAwesomeIcons.chevronRight;

  /// Group/people
  static const IconData group = FontAwesomeIcons.userGroup;

  /// Add/plus
  static const IconData add = FontAwesomeIcons.plus;

  /// Remove/minus
  static const IconData remove = FontAwesomeIcons.minus;

  /// Article/document with text
  static const IconData article = FontAwesomeIcons.newspaper;

  /// Preaching material/sermon
  static const IconData preachingMaterial = FontAwesomeIcons.bookBible;

  /// Game instruction/puzzle
  static const IconData gameInstruction = FontAwesomeIcons.puzzlePiece;

  /// Upload file
  static const IconData uploadFile = FontAwesomeIcons.fileArrowUp;

  /// Add circle outline
  static const IconData addCircle = FontAwesomeIcons.circlePlus;

  /// PDF file
  static const IconData pictureAsPdf = FontAwesomeIcons.filePdf;

  /// Image file
  static const IconData image = FontAwesomeIcons.fileImage;

  /// Generic file
  static const IconData insertDriveFile = FontAwesomeIcons.file;

  /// Event available/calendar check
  static const IconData eventAvailable = FontAwesomeIcons.calendarCheck;

  /// Access time/clock
  static const IconData accessTime = FontAwesomeIcons.clock;

  /// Calendar today
  static const IconData calendarToday = FontAwesomeIcons.calendarDay;

  /// My location/GPS target
  static const IconData myLocation = FontAwesomeIcons.locationCrosshairs;

  /// Location on/pin
  static const IconData locationOn = FontAwesomeIcons.locationDot;

  /// Map outlined
  static const IconData mapOutlined = FontAwesomeIcons.map;

  /// Location on outlined
  static const IconData locationOnOutlined = FontAwesomeIcons.locationDot;

  /// Schedule outlined
  static const IconData scheduleOutlined = FontAwesomeIcons.calendarDays;

  /// Notifications active
  static const IconData notificationsActive = FontAwesomeIcons.solidBell;

  /// Check circle
  static const IconData checkCircle = FontAwesomeIcons.solidCircleCheck;

  /// Badge outlined
  static const IconData badgeOutlined = FontAwesomeIcons.idBadge;

  /// Account balance wallet outlined
  static const IconData accountBalanceWalletOutlined = FontAwesomeIcons.wallet;

  /// Arrow forward
  static const IconData arrowForwardIcon = FontAwesomeIcons.arrowRight;

  /// Person outline
  static const IconData personOutline = FontAwesomeIcons.user;

  /// Publish outlined
  static const IconData publishOutlined = FontAwesomeIcons.share;
}
