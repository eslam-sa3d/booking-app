import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get commonSaving;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get commonActive;

  /// No description provided for @commonInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get commonInactive;

  /// No description provided for @commonRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonRequired;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get navRequests;

  /// No description provided for @navClasses.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get navClasses;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get navCategories;

  /// No description provided for @navBanners.
  ///
  /// In en, this message translates to:
  /// **'Banners'**
  String get navBanners;

  /// No description provided for @navPackages.
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get navPackages;

  /// No description provided for @navPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get navPayments;

  /// No description provided for @navPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get navPaymentMethods;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports & Analytics'**
  String get navReports;

  /// No description provided for @navMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get navMembers;

  /// No description provided for @navInstructors.
  ///
  /// In en, this message translates to:
  /// **'Instructors'**
  String get navInstructors;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'App Content & Settings'**
  String get navSettings;

  /// No description provided for @navStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff Accounts'**
  String get navStaff;

  /// No description provided for @navCollapseMenu.
  ///
  /// In en, this message translates to:
  /// **'Collapse menu'**
  String get navCollapseMenu;

  /// No description provided for @navExpandMenu.
  ///
  /// In en, this message translates to:
  /// **'Expand menu'**
  String get navExpandMenu;

  /// No description provided for @navCloseMenu.
  ///
  /// In en, this message translates to:
  /// **'Close menu'**
  String get navCloseMenu;

  /// No description provided for @navSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get navSignOut;

  /// No description provided for @navSwitchToArabic.
  ///
  /// In en, this message translates to:
  /// **'Switch to Arabic'**
  String get navSwitchToArabic;

  /// No description provided for @navSwitchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'Switch to English'**
  String get navSwitchToEnglish;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSignIn;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardActiveClasses.
  ///
  /// In en, this message translates to:
  /// **'Active classes'**
  String get dashboardActiveClasses;

  /// No description provided for @dashboardTotalMembers.
  ///
  /// In en, this message translates to:
  /// **'Total members'**
  String get dashboardTotalMembers;

  /// No description provided for @dashboardWaitlistedBookings.
  ///
  /// In en, this message translates to:
  /// **'Waitlisted bookings'**
  String get dashboardWaitlistedBookings;

  /// No description provided for @dashboardTodaysBookings.
  ///
  /// In en, this message translates to:
  /// **'Today\'s bookings'**
  String get dashboardTodaysBookings;

  /// No description provided for @dashboardRevenueThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Revenue this month'**
  String get dashboardRevenueThisMonth;

  /// No description provided for @dashboardUpcomingSessions.
  ///
  /// In en, this message translates to:
  /// **'Upcoming sessions (7d)'**
  String get dashboardUpcomingSessions;

  /// No description provided for @dashboardFullNearFullClasses.
  ///
  /// In en, this message translates to:
  /// **'Full / near-full classes'**
  String get dashboardFullNearFullClasses;

  /// No description provided for @dashboardPackagesExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Packages expiring soon'**
  String get dashboardPackagesExpiringSoon;

  /// No description provided for @dashboardSidebarHint.
  ///
  /// In en, this message translates to:
  /// **'Use the sidebar to manage classes, the booking calendar, banners, packages, and more. Every change here is live in the mobile app immediately — no release needed.'**
  String get dashboardSidebarHint;

  /// No description provided for @requestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requestsTitle;

  /// No description provided for @requestsRefundRequestsHeading.
  ///
  /// In en, this message translates to:
  /// **'Refund requests'**
  String get requestsRefundRequestsHeading;

  /// No description provided for @requestsRefundRequestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customer-initiated refund requests awaiting a decision.'**
  String get requestsRefundRequestsSubtitle;

  /// No description provided for @requestsApproveRefundTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve refund?'**
  String get requestsApproveRefundTitle;

  /// No description provided for @requestsDenyRefundTitle.
  ///
  /// In en, this message translates to:
  /// **'Deny refund?'**
  String get requestsDenyRefundTitle;

  /// No description provided for @requestsApproveRefundContent.
  ///
  /// In en, this message translates to:
  /// **'This marks the transaction as refunded and notifies the customer. This cannot be undone from here.'**
  String get requestsApproveRefundContent;

  /// No description provided for @requestsDenyRefundContent.
  ///
  /// In en, this message translates to:
  /// **'The customer will be notified their refund request was denied.'**
  String get requestsDenyRefundContent;

  /// No description provided for @requestsApproveButton.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get requestsApproveButton;

  /// No description provided for @requestsDenyButton.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get requestsDenyButton;

  /// No description provided for @requestsNoReasonGiven.
  ///
  /// In en, this message translates to:
  /// **'No reason given'**
  String get requestsNoReasonGiven;

  /// No description provided for @requestsNoPendingRefundRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending refund requests.'**
  String get requestsNoPendingRefundRequests;

  /// No description provided for @requestsWaitlistedBookingsHeading.
  ///
  /// In en, this message translates to:
  /// **'Waitlisted bookings'**
  String get requestsWaitlistedBookingsHeading;

  /// No description provided for @requestsWaitlistSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Promotion is automatic when a confirmed booking is cancelled — this list is for visibility, not manual action.'**
  String get requestsWaitlistSubtitle;

  /// No description provided for @requestsNoOneWaitlisted.
  ///
  /// In en, this message translates to:
  /// **'No one is currently waitlisted.'**
  String get requestsNoOneWaitlisted;

  /// No description provided for @requestsRecentCancellationsHeading.
  ///
  /// In en, this message translates to:
  /// **'Recent cancellations'**
  String get requestsRecentCancellationsHeading;

  /// No description provided for @requestsNoRecentCancellations.
  ///
  /// In en, this message translates to:
  /// **'No recent cancellations.'**
  String get requestsNoRecentCancellations;

  /// No description provided for @requestsRequestedOn.
  ///
  /// In en, this message translates to:
  /// **'Requested {date}'**
  String requestsRequestedOn(String date);

  /// No description provided for @requestsSessionLabel.
  ///
  /// In en, this message translates to:
  /// **'Session: {sessionId}'**
  String requestsSessionLabel(String sessionId);

  /// No description provided for @classesTitle.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classesTitle;

  /// No description provided for @classesAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add class'**
  String get classesAddButton;

  /// No description provided for @classesEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No classes yet — add one to get started.'**
  String get classesEmptyState;

  /// No description provided for @classesRowSummary.
  ///
  /// In en, this message translates to:
  /// **'{categories} · {duration} min · {price} EGP'**
  String classesRowSummary(String categories, String duration, String price);

  /// No description provided for @classesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete class?'**
  String get classesDeleteTitle;

  /// No description provided for @classesDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'This does not delete existing sessions for \"{title}\".'**
  String classesDeleteContent(String title);

  /// No description provided for @classFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit class'**
  String get classFormEditTitle;

  /// No description provided for @classFormTitleEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Title (EN)'**
  String get classFormTitleEnLabel;

  /// No description provided for @classFormTitleArLabel.
  ///
  /// In en, this message translates to:
  /// **'Title (AR)'**
  String get classFormTitleArLabel;

  /// No description provided for @classFormDescriptionEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (EN)'**
  String get classFormDescriptionEnLabel;

  /// No description provided for @classFormDescriptionArLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (AR)'**
  String get classFormDescriptionArLabel;

  /// No description provided for @classFormCategoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get classFormCategoriesLabel;

  /// No description provided for @classFormPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price (EGP)'**
  String get classFormPriceLabel;

  /// No description provided for @classFormDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration (min)'**
  String get classFormDurationLabel;

  /// No description provided for @classFormInstructorLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructor'**
  String get classFormInstructorLabel;

  /// No description provided for @classFormBranchLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch / Pool'**
  String get classFormBranchLabel;

  /// No description provided for @classFormSelectCategoryError.
  ///
  /// In en, this message translates to:
  /// **'Select at least one category'**
  String get classFormSelectCategoryError;

  /// No description provided for @classFormSelectInstructorBranchError.
  ///
  /// In en, this message translates to:
  /// **'Select an instructor and branch'**
  String get classFormSelectInstructorBranchError;

  /// No description provided for @classFormSaveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String classFormSaveError(String error);

  /// No description provided for @instructorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Instructors'**
  String get instructorsTitle;

  /// No description provided for @instructorsAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add instructor'**
  String get instructorsAddButton;

  /// No description provided for @instructorsEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No instructors yet.'**
  String get instructorsEmptyState;

  /// No description provided for @instructorsViewScheduleTooltip.
  ///
  /// In en, this message translates to:
  /// **'View schedule'**
  String get instructorsViewScheduleTooltip;

  /// No description provided for @instructorsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete instructor?'**
  String get instructorsDeleteTitle;

  /// No description provided for @instructorsDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will no longer be assignable to classes or sessions.'**
  String instructorsDeleteContent(String name);

  /// No description provided for @instructorScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} — upcoming sessions'**
  String instructorScheduleTitle(String name);

  /// No description provided for @instructorScheduleEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No upcoming sessions.'**
  String get instructorScheduleEmptyState;

  /// No description provided for @instructorFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit instructor'**
  String get instructorFormEditTitle;

  /// No description provided for @instructorFormNameEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (EN)'**
  String get instructorFormNameEnLabel;

  /// No description provided for @instructorFormNameArLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (AR)'**
  String get instructorFormNameArLabel;

  /// No description provided for @instructorFormBioEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio (EN)'**
  String get instructorFormBioEnLabel;

  /// No description provided for @instructorFormBioArLabel.
  ///
  /// In en, this message translates to:
  /// **'Bio (AR)'**
  String get instructorFormBioArLabel;

  /// No description provided for @instructorFormSpecialtiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Specialties (comma-separated)'**
  String get instructorFormSpecialtiesLabel;

  /// No description provided for @instructorFormSaveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String instructorFormSaveError(String error);

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar & Sessions'**
  String get calendarTitle;

  /// No description provided for @calendarManageBlockedDates.
  ///
  /// In en, this message translates to:
  /// **'Manage blocked dates'**
  String get calendarManageBlockedDates;

  /// No description provided for @calendarBulkCreateRecurring.
  ///
  /// In en, this message translates to:
  /// **'Bulk-create recurring'**
  String get calendarBulkCreateRecurring;

  /// No description provided for @calendarAddSession.
  ///
  /// In en, this message translates to:
  /// **'Add session'**
  String get calendarAddSession;

  /// No description provided for @calendarDeleteSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete session?'**
  String get calendarDeleteSessionTitle;

  /// No description provided for @calendarDeleteSessionContent.
  ///
  /// In en, this message translates to:
  /// **'This does not cancel or notify already-booked customers.'**
  String get calendarDeleteSessionContent;

  /// No description provided for @calendarBlockedDateBadge.
  ///
  /// In en, this message translates to:
  /// **'Blocked date'**
  String get calendarBlockedDateBadge;

  /// No description provided for @calendarNoSessionsOnDay.
  ///
  /// In en, this message translates to:
  /// **'No sessions on this day'**
  String get calendarNoSessionsOnDay;

  /// No description provided for @calendarBranchLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get calendarBranchLabel;

  /// No description provided for @calendarAllBranchesOption.
  ///
  /// In en, this message translates to:
  /// **'All branches'**
  String get calendarAllBranchesOption;

  /// No description provided for @calendarReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get calendarReasonLabel;

  /// No description provided for @calendarAdding.
  ///
  /// In en, this message translates to:
  /// **'Adding…'**
  String get calendarAdding;

  /// No description provided for @calendarAddBlockedDate.
  ///
  /// In en, this message translates to:
  /// **'Add blocked date'**
  String get calendarAddBlockedDate;

  /// No description provided for @calendarCurrentlyBlocked.
  ///
  /// In en, this message translates to:
  /// **'Currently blocked'**
  String get calendarCurrentlyBlocked;

  /// No description provided for @calendarNoBlockedDates.
  ///
  /// In en, this message translates to:
  /// **'No blocked dates'**
  String get calendarNoBlockedDates;

  /// No description provided for @calendarUnblockDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Unblock this date?'**
  String get calendarUnblockDateTitle;

  /// No description provided for @calendarSessionBookedCount.
  ///
  /// In en, this message translates to:
  /// **'{booked}/{capacity} booked'**
  String calendarSessionBookedCount(int booked, int capacity);

  /// No description provided for @calendarSessionWaitlistedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} waitlisted'**
  String calendarSessionWaitlistedCount(int count);

  /// No description provided for @calendarDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String calendarDateLabel(String date);

  /// No description provided for @calendarUnblockDateContent.
  ///
  /// In en, this message translates to:
  /// **'Staff will be able to create sessions on {date} again.'**
  String calendarUnblockDateContent(String date);

  /// No description provided for @sessionFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit session'**
  String get sessionFormEditTitle;

  /// No description provided for @sessionFormClassLabel.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get sessionFormClassLabel;

  /// No description provided for @sessionFormInstructorLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructor'**
  String get sessionFormInstructorLabel;

  /// No description provided for @sessionFormBranchPoolLabel.
  ///
  /// In en, this message translates to:
  /// **'Branch / Pool'**
  String get sessionFormBranchPoolLabel;

  /// No description provided for @sessionFormCapacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get sessionFormCapacityLabel;

  /// No description provided for @sessionFormSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String sessionFormSaveFailed(String error);

  /// No description provided for @sessionFormStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Start: {time}'**
  String sessionFormStartLabel(String time);

  /// No description provided for @sessionFormEndLabel.
  ///
  /// In en, this message translates to:
  /// **'End: {time}'**
  String sessionFormEndLabel(String time);

  /// No description provided for @recurringSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk-create recurring sessions'**
  String get recurringSessionTitle;

  /// No description provided for @recurringSessionMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get recurringSessionMon;

  /// No description provided for @recurringSessionTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get recurringSessionTue;

  /// No description provided for @recurringSessionWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get recurringSessionWed;

  /// No description provided for @recurringSessionThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get recurringSessionThu;

  /// No description provided for @recurringSessionFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get recurringSessionFri;

  /// No description provided for @recurringSessionSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get recurringSessionSat;

  /// No description provided for @recurringSessionSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get recurringSessionSun;

  /// No description provided for @recurringSessionCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get recurringSessionCreating;

  /// No description provided for @recurringSessionCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create sessions'**
  String get recurringSessionCreateButton;

  /// No description provided for @recurringSessionFromLabel.
  ///
  /// In en, this message translates to:
  /// **'From: {date}'**
  String recurringSessionFromLabel(String date);

  /// No description provided for @recurringSessionToLabel.
  ///
  /// In en, this message translates to:
  /// **'To: {date}'**
  String recurringSessionToLabel(String date);

  /// No description provided for @recurringSessionCreatedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Created {count} sessions'**
  String recurringSessionCreatedSnackbar(int count);

  /// No description provided for @recurringSessionCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create sessions: {error}'**
  String recurringSessionCreateFailed(String error);

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @categoriesAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get categoriesAddButton;

  /// No description provided for @categoriesEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No categories yet — add one to let members filter classes.'**
  String get categoriesEmptyState;

  /// No description provided for @categoriesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get categoriesDeleteTitle;

  /// No description provided for @categoriesDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will no longer be available to tag classes.'**
  String categoriesDeleteMessage(String name);

  /// No description provided for @categoriesSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String categoriesSaveFailed(String error);

  /// No description provided for @categoriesAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get categoriesAddTitle;

  /// No description provided for @categoriesEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get categoriesEditTitle;

  /// No description provided for @categoriesNameEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (EN)'**
  String get categoriesNameEnLabel;

  /// No description provided for @categoriesNameArLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (AR)'**
  String get categoriesNameArLabel;

  /// No description provided for @bannersTitle.
  ///
  /// In en, this message translates to:
  /// **'Banners'**
  String get bannersTitle;

  /// No description provided for @bannersAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add banner'**
  String get bannersAddButton;

  /// No description provided for @bannersEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No banners yet — the mobile home screen will show none until you add one.'**
  String get bannersEmptyState;

  /// No description provided for @bannersDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete banner?'**
  String get bannersDeleteTitle;

  /// No description provided for @bannersDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed from the mobile home screen.'**
  String bannersDeleteMessage(String title);

  /// No description provided for @bannersSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String bannersSaveFailed(String error);

  /// No description provided for @bannersAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add banner'**
  String get bannersAddTitle;

  /// No description provided for @bannersEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit banner'**
  String get bannersEditTitle;

  /// No description provided for @bannersTitleEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Title (EN)'**
  String get bannersTitleEnLabel;

  /// No description provided for @bannersTitleArLabel.
  ///
  /// In en, this message translates to:
  /// **'Title (AR)'**
  String get bannersTitleArLabel;

  /// No description provided for @bannersSubtitleEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtitle (EN)'**
  String get bannersSubtitleEnLabel;

  /// No description provided for @bannersSubtitleArLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtitle (AR)'**
  String get bannersSubtitleArLabel;

  /// No description provided for @bannersImageUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get bannersImageUrlLabel;

  /// No description provided for @bannersLinkActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Link action (e.g. class:c1, packages)'**
  String get bannersLinkActionLabel;

  /// No description provided for @bannersActiveDateRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Active date range (optional)'**
  String get bannersActiveDateRangeLabel;

  /// No description provided for @bannersActiveFromLabel.
  ///
  /// In en, this message translates to:
  /// **'Active from'**
  String get bannersActiveFromLabel;

  /// No description provided for @bannersActiveUntilLabel.
  ///
  /// In en, this message translates to:
  /// **'Active until'**
  String get bannersActiveUntilLabel;

  /// No description provided for @bannersNoLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get bannersNoLimitLabel;

  /// No description provided for @bannersClearDateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get bannersClearDateTooltip;

  /// No description provided for @bannersPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get bannersPreviewLabel;

  /// No description provided for @bannersPreviewTitlePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Banner title'**
  String get bannersPreviewTitlePlaceholder;

  /// No description provided for @bannersPreviewSubtitlePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Banner subtitle'**
  String get bannersPreviewSubtitlePlaceholder;

  /// No description provided for @bannersPreviewActiveNote.
  ///
  /// In en, this message translates to:
  /// **'Would show now on the mobile home screen'**
  String get bannersPreviewActiveNote;

  /// No description provided for @bannersPreviewInactiveNote.
  ///
  /// In en, this message translates to:
  /// **'Would NOT show right now (inactive or outside date range)'**
  String get bannersPreviewInactiveNote;

  /// No description provided for @packagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Packages & Pricing'**
  String get packagesTitle;

  /// No description provided for @packagesAddPackageTitle.
  ///
  /// In en, this message translates to:
  /// **'Add package'**
  String get packagesAddPackageTitle;

  /// No description provided for @packagesEditPackageTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit package'**
  String get packagesEditPackageTitle;

  /// No description provided for @packagesEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No packages yet.'**
  String get packagesEmptyState;

  /// No description provided for @packagesPopularBadge.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get packagesPopularBadge;

  /// No description provided for @packagesUnlimitedLabel.
  ///
  /// In en, this message translates to:
  /// **'unlimited'**
  String get packagesUnlimitedLabel;

  /// No description provided for @packagesDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete package?'**
  String get packagesDeleteConfirmTitle;

  /// No description provided for @packagesSessionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions'**
  String packagesSessionsCount(int count);

  /// No description provided for @packagesDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String packagesDaysCount(int count);

  /// No description provided for @packagesPriceEgp.
  ///
  /// In en, this message translates to:
  /// **'{price} EGP'**
  String packagesPriceEgp(String price);

  /// No description provided for @packagesDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will no longer be purchasable. Existing owned packages are unaffected.'**
  String packagesDeleteConfirmMessage(String name);

  /// No description provided for @packageFormNameEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (EN)'**
  String get packageFormNameEnLabel;

  /// No description provided for @packageFormNameArLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (AR)'**
  String get packageFormNameArLabel;

  /// No description provided for @packageFormDescriptionEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (EN)'**
  String get packageFormDescriptionEnLabel;

  /// No description provided for @packageFormDescriptionArLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (AR)'**
  String get packageFormDescriptionArLabel;

  /// No description provided for @packageFormTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get packageFormTypeLabel;

  /// No description provided for @packageFormSessionCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Session count'**
  String get packageFormSessionCountLabel;

  /// No description provided for @packageFormValidityDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Validity (days)'**
  String get packageFormValidityDaysLabel;

  /// No description provided for @packageFormPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price (EGP)'**
  String get packageFormPriceLabel;

  /// No description provided for @packageFormMarkAsPopularLabel.
  ///
  /// In en, this message translates to:
  /// **'Mark as popular'**
  String get packageFormMarkAsPopularLabel;

  /// No description provided for @packageFormMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than 0'**
  String get packageFormMustBePositive;

  /// No description provided for @packageFormSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String packageFormSaveFailed(String error);

  /// No description provided for @paymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payments & Reports'**
  String get paymentsTitle;

  /// No description provided for @paymentsTotalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total revenue'**
  String get paymentsTotalRevenue;

  /// No description provided for @paymentsSuccessfulTransactions.
  ///
  /// In en, this message translates to:
  /// **'Successful transactions'**
  String get paymentsSuccessfulTransactions;

  /// No description provided for @paymentsRevenueReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Revenue report'**
  String get paymentsRevenueReportTitle;

  /// No description provided for @paymentsRevenueReportDescription.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months, succeeded transactions only. Class breakdown is best-effort — transactions without a linked booking (e.g. older ones) are grouped under \"{otherClassLabel}\".'**
  String paymentsRevenueReportDescription(String otherClassLabel);

  /// No description provided for @paymentsOtherClassLabel.
  ///
  /// In en, this message translates to:
  /// **'Other / Unlinked'**
  String get paymentsOtherClassLabel;

  /// No description provided for @paymentsFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get paymentsFiltersTitle;

  /// No description provided for @paymentsTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get paymentsTransactionsTitle;

  /// No description provided for @paymentsFilterByDateRange.
  ///
  /// In en, this message translates to:
  /// **'Filter by date range'**
  String get paymentsFilterByDateRange;

  /// No description provided for @paymentsDateRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'{start} to {end}'**
  String paymentsDateRangeLabel(String start, String end);

  /// No description provided for @paymentsClearDateFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear date filter'**
  String get paymentsClearDateFilter;

  /// No description provided for @paymentsClassLabel.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get paymentsClassLabel;

  /// No description provided for @paymentsAllClasses.
  ///
  /// In en, this message translates to:
  /// **'All classes'**
  String get paymentsAllClasses;

  /// No description provided for @paymentsRefundConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Refund this transaction?'**
  String get paymentsRefundConfirmTitle;

  /// No description provided for @paymentsRefundConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Refunds {amount} {currency} for \"{description}\". This cannot be undone from here.'**
  String paymentsRefundConfirmContent(
    String amount,
    String currency,
    String description,
  );

  /// No description provided for @paymentsRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get paymentsRefund;

  /// No description provided for @paymentsNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions match the current filters.'**
  String get paymentsNoTransactions;

  /// No description provided for @paymentsRevenueByMonth.
  ///
  /// In en, this message translates to:
  /// **'Revenue by month'**
  String get paymentsRevenueByMonth;

  /// No description provided for @paymentsNoRevenuePeriod.
  ///
  /// In en, this message translates to:
  /// **'No revenue in this period.'**
  String get paymentsNoRevenuePeriod;

  /// No description provided for @paymentsRevenueByClass.
  ///
  /// In en, this message translates to:
  /// **'Revenue by class'**
  String get paymentsRevenueByClass;

  /// No description provided for @paymentsStatusSucceeded.
  ///
  /// In en, this message translates to:
  /// **'Succeeded'**
  String get paymentsStatusSucceeded;

  /// No description provided for @paymentsStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get paymentsStatusFailed;

  /// No description provided for @paymentsStatusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get paymentsStatusRefunded;

  /// No description provided for @paymentsStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get paymentsStatusPending;

  /// No description provided for @paymentMethodsEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No payment methods yet — add one to offer it at checkout.'**
  String get paymentMethodsEmptyState;

  /// No description provided for @paymentMethodFormAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add payment method'**
  String get paymentMethodFormAddTitle;

  /// No description provided for @paymentMethodFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit payment method'**
  String get paymentMethodFormEditTitle;

  /// No description provided for @paymentMethodFormNameEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (EN)'**
  String get paymentMethodFormNameEnLabel;

  /// No description provided for @paymentMethodFormNameArLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (AR)'**
  String get paymentMethodFormNameArLabel;

  /// No description provided for @paymentMethodFormLogoUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Logo URL'**
  String get paymentMethodFormLogoUrlLabel;

  /// No description provided for @paymentMethodFormUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://...'**
  String get paymentMethodFormUrlHint;

  /// No description provided for @paymentMethodFormPaymentLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment link URL'**
  String get paymentMethodFormPaymentLinkLabel;

  /// No description provided for @paymentMethodFormPaymentLinkHelper.
  ///
  /// In en, this message translates to:
  /// **'Opened when the customer taps \"Pay Now\" at checkout'**
  String get paymentMethodFormPaymentLinkHelper;

  /// No description provided for @paymentMethodFormActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shown to customers at checkout'**
  String get paymentMethodFormActiveSubtitle;

  /// No description provided for @reportsRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get reportsRefreshTooltip;

  /// No description provided for @reportsBookings30d.
  ///
  /// In en, this message translates to:
  /// **'Bookings (30d)'**
  String get reportsBookings30d;

  /// No description provided for @reportsAttendanceRate.
  ///
  /// In en, this message translates to:
  /// **'Attendance rate'**
  String get reportsAttendanceRate;

  /// No description provided for @reportsRevenue6mo.
  ///
  /// In en, this message translates to:
  /// **'Revenue (6mo)'**
  String get reportsRevenue6mo;

  /// No description provided for @reportsNewMembers6mo.
  ///
  /// In en, this message translates to:
  /// **'New members (6mo)'**
  String get reportsNewMembers6mo;

  /// No description provided for @reportsBookingsTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookings trend (last 30 days)'**
  String get reportsBookingsTrendTitle;

  /// No description provided for @reportsBookingsTrendDescription.
  ///
  /// In en, this message translates to:
  /// **'Count of bookings created per day.'**
  String get reportsBookingsTrendDescription;

  /// No description provided for @reportsAttendanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Completed vs. cancelled bookings (all time). Cancellations are treated as non-attendance — this app doesn\'t track a separate no-show flag, so it\'s an approximation.'**
  String get reportsAttendanceDescription;

  /// No description provided for @reportsCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'completed'**
  String get reportsCompletedLabel;

  /// No description provided for @reportsPopularClassesAndTimesTitle.
  ///
  /// In en, this message translates to:
  /// **'Popular classes & times'**
  String get reportsPopularClassesAndTimesTitle;

  /// No description provided for @reportsPopularClassesTimesDescription.
  ///
  /// In en, this message translates to:
  /// **'Ranked by booking count over the last 30 days.'**
  String get reportsPopularClassesTimesDescription;

  /// No description provided for @reportsTopClasses.
  ///
  /// In en, this message translates to:
  /// **'Top classes'**
  String get reportsTopClasses;

  /// No description provided for @reportsPopularTimes.
  ///
  /// In en, this message translates to:
  /// **'Popular times'**
  String get reportsPopularTimes;

  /// No description provided for @reportsNoBookingsInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No bookings in this period.'**
  String get reportsNoBookingsInPeriod;

  /// No description provided for @reportsRevenueTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Revenue trend (last 6 months)'**
  String get reportsRevenueTrendTitle;

  /// No description provided for @reportsRevenueTrendDescription.
  ///
  /// In en, this message translates to:
  /// **'Sum of succeeded transactions, by month.'**
  String get reportsRevenueTrendDescription;

  /// No description provided for @reportsNoRevenueInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No revenue in this period.'**
  String get reportsNoRevenueInPeriod;

  /// No description provided for @reportsMemberGrowthTitle.
  ///
  /// In en, this message translates to:
  /// **'Member growth (last 6 months)'**
  String get reportsMemberGrowthTitle;

  /// No description provided for @reportsMemberGrowthDescription.
  ///
  /// In en, this message translates to:
  /// **'New customer signups, by month.'**
  String get reportsMemberGrowthDescription;

  /// No description provided for @reportsNoNewMembersInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No new members in this period.'**
  String get reportsNoNewMembersInPeriod;

  /// No description provided for @reportsMonthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get reportsMonthJan;

  /// No description provided for @reportsMonthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get reportsMonthFeb;

  /// No description provided for @reportsMonthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get reportsMonthMar;

  /// No description provided for @reportsMonthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get reportsMonthApr;

  /// No description provided for @reportsMonthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get reportsMonthMay;

  /// No description provided for @reportsMonthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get reportsMonthJun;

  /// No description provided for @reportsMonthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get reportsMonthJul;

  /// No description provided for @reportsMonthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get reportsMonthAug;

  /// No description provided for @reportsMonthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get reportsMonthSep;

  /// No description provided for @reportsMonthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get reportsMonthOct;

  /// No description provided for @reportsMonthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get reportsMonthNov;

  /// No description provided for @reportsMonthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get reportsMonthDec;

  /// No description provided for @reportsFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load reports: {error}'**
  String reportsFailedToLoad(String error);

  /// No description provided for @reportsCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'Completed: {count}'**
  String reportsCompletedCount(int count);

  /// No description provided for @reportsCancelledCount.
  ///
  /// In en, this message translates to:
  /// **'Cancelled: {count}'**
  String reportsCancelledCount(int count);

  /// No description provided for @reportsRevenueTooltip.
  ///
  /// In en, this message translates to:
  /// **'{month}: {value} EGP'**
  String reportsRevenueTooltip(String month, String value);

  /// No description provided for @reportsMemberGrowthTooltip.
  ///
  /// In en, this message translates to:
  /// **'{month}: {count}'**
  String reportsMemberGrowthTooltip(String month, int count);

  /// No description provided for @membersTitle.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get membersTitle;

  /// No description provided for @membersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email'**
  String get membersSearchHint;

  /// No description provided for @membersNoResults.
  ///
  /// In en, this message translates to:
  /// **'No members found.'**
  String get membersNoResults;

  /// No description provided for @membersReactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get membersReactivate;

  /// No description provided for @membersSuspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get membersSuspend;

  /// No description provided for @membersFamilyMembersCount.
  ///
  /// In en, this message translates to:
  /// **'Family members ({count})'**
  String membersFamilyMembersCount(int count);

  /// No description provided for @membersBookingsCount.
  ///
  /// In en, this message translates to:
  /// **'Bookings ({count})'**
  String membersBookingsCount(int count);

  /// No description provided for @membersPaymentHistoryCount.
  ///
  /// In en, this message translates to:
  /// **'Payment history ({count})'**
  String membersPaymentHistoryCount(int count);

  /// No description provided for @membersNoPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments yet.'**
  String get membersNoPayments;

  /// No description provided for @membersEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get membersEditProfile;

  /// No description provided for @membersNoDescription.
  ///
  /// In en, this message translates to:
  /// **'(no description)'**
  String get membersNoDescription;

  /// No description provided for @membersAwardBadge.
  ///
  /// In en, this message translates to:
  /// **'Award badge'**
  String get membersAwardBadge;

  /// No description provided for @membersAddProgressNoteAction.
  ///
  /// In en, this message translates to:
  /// **'Add progress note'**
  String get membersAddProgressNoteAction;

  /// No description provided for @membersAward.
  ///
  /// In en, this message translates to:
  /// **'Award'**
  String get membersAward;

  /// No description provided for @membersNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get membersNameLabel;

  /// No description provided for @membersPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get membersPhoneLabel;

  /// No description provided for @membersTitleEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Title (EN)'**
  String get membersTitleEnLabel;

  /// No description provided for @membersTitleArLabel.
  ///
  /// In en, this message translates to:
  /// **'Title (AR)'**
  String get membersTitleArLabel;

  /// No description provided for @membersIconNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon name (Material, e.g. emoji_events)'**
  String get membersIconNameLabel;

  /// No description provided for @membersNoteEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (EN)'**
  String get membersNoteEnLabel;

  /// No description provided for @membersNoteArLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (AR)'**
  String get membersNoteArLabel;

  /// No description provided for @membersInstructorNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructor name'**
  String get membersInstructorNameLabel;

  /// No description provided for @membersFailedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String membersFailedToSave(String error);

  /// No description provided for @membersBadgesLabel.
  ///
  /// In en, this message translates to:
  /// **'Badges: {badges}'**
  String membersBadgesLabel(String badges);

  /// No description provided for @membersProgressNotesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} progress note(s)'**
  String membersProgressNotesCount(int count);

  /// No description provided for @membersFamilyMemberAge.
  ///
  /// In en, this message translates to:
  /// **'{name} ({age}y)'**
  String membersFamilyMemberAge(String name, int age);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Center'**
  String get notificationsTitle;

  /// No description provided for @notificationsComposeBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Compose broadcast'**
  String get notificationsComposeBroadcast;

  /// No description provided for @notificationsFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load broadcasts: {error}'**
  String notificationsFailedToLoad(String error);

  /// No description provided for @notificationsEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No broadcasts sent yet.'**
  String get notificationsEmptyState;

  /// No description provided for @notificationsSegmentExpiringPackage.
  ///
  /// In en, this message translates to:
  /// **'Expiring package this week'**
  String get notificationsSegmentExpiringPackage;

  /// No description provided for @notificationsSegmentNoBooking.
  ///
  /// In en, this message translates to:
  /// **'No booking in last 30 days'**
  String get notificationsSegmentNoBooking;

  /// No description provided for @notificationsTargetSegmentDesc.
  ///
  /// In en, this message translates to:
  /// **'segment: {segment}'**
  String notificationsTargetSegmentDesc(String segment);

  /// No description provided for @notificationsTargetSingleUser.
  ///
  /// In en, this message translates to:
  /// **'Single user'**
  String get notificationsTargetSingleUser;

  /// No description provided for @notificationsTargetAllUsers.
  ///
  /// In en, this message translates to:
  /// **'All users'**
  String get notificationsTargetAllUsers;

  /// No description provided for @notificationsTargetSegmentOption.
  ///
  /// In en, this message translates to:
  /// **'Segment'**
  String get notificationsTargetSegmentOption;

  /// No description provided for @notificationsBodyTargetLine.
  ///
  /// In en, this message translates to:
  /// **'{body} · target: {target}'**
  String notificationsBodyTargetLine(String body, String target);

  /// No description provided for @notificationsScheduledFor.
  ///
  /// In en, this message translates to:
  /// **'Scheduled for {date}'**
  String notificationsScheduledFor(String date);

  /// No description provided for @notificationsLoadingStats.
  ///
  /// In en, this message translates to:
  /// **'Loading delivery stats…'**
  String get notificationsLoadingStats;

  /// No description provided for @notificationsFailedToLoadStats.
  ///
  /// In en, this message translates to:
  /// **'Failed to load delivery stats: {error}'**
  String notificationsFailedToLoadStats(String error);

  /// No description provided for @notificationsDeliveryStats.
  ///
  /// In en, this message translates to:
  /// **'Delivered: {delivered} · Read: {read}'**
  String notificationsDeliveryStats(int delivered, int read);

  /// No description provided for @notificationsStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get notificationsStatusDraft;

  /// No description provided for @notificationsStatusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get notificationsStatusScheduled;

  /// No description provided for @notificationsStatusSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get notificationsStatusSent;

  /// No description provided for @notificationsRequiredFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Title (EN) and Message (EN) are required.'**
  String get notificationsRequiredFieldsError;

  /// No description provided for @notificationsPickMemberError.
  ///
  /// In en, this message translates to:
  /// **'Pick a member to target.'**
  String get notificationsPickMemberError;

  /// No description provided for @notificationsFailedToSend.
  ///
  /// In en, this message translates to:
  /// **'Failed to send: {error}'**
  String notificationsFailedToSend(String error);

  /// No description provided for @notificationsTitleEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Title (EN)'**
  String get notificationsTitleEnLabel;

  /// No description provided for @notificationsTitleArLabel.
  ///
  /// In en, this message translates to:
  /// **'Title (AR)'**
  String get notificationsTitleArLabel;

  /// No description provided for @notificationsMessageEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Message (EN)'**
  String get notificationsMessageEnLabel;

  /// No description provided for @notificationsMessageArLabel.
  ///
  /// In en, this message translates to:
  /// **'Message (AR)'**
  String get notificationsMessageArLabel;

  /// No description provided for @notificationsTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get notificationsTargetLabel;

  /// No description provided for @notificationsSearchMemberLabel.
  ///
  /// In en, this message translates to:
  /// **'Search member by name or email'**
  String get notificationsSearchMemberLabel;

  /// No description provided for @notificationsSelectedMember.
  ///
  /// In en, this message translates to:
  /// **'Selected: {name}'**
  String notificationsSelectedMember(String name);

  /// No description provided for @notificationsScheduleForLater.
  ///
  /// In en, this message translates to:
  /// **'Schedule for later'**
  String get notificationsScheduleForLater;

  /// No description provided for @notificationsScheduleOffHint.
  ///
  /// In en, this message translates to:
  /// **'Off = send immediately'**
  String get notificationsScheduleOffHint;

  /// No description provided for @notificationsSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get notificationsSending;

  /// No description provided for @notificationsScheduleButton.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get notificationsScheduleButton;

  /// No description provided for @notificationsSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get notificationsSendButton;

  /// No description provided for @settingsSaveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get settingsSaveChangesButton;

  /// No description provided for @settingsSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSavedMessage;

  /// No description provided for @settingsSaveFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String settingsSaveFailedMessage(String error);

  /// No description provided for @settingsBrandingSection.
  ///
  /// In en, this message translates to:
  /// **'Branding'**
  String get settingsBrandingSection;

  /// No description provided for @settingsPrimaryColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Primary color (hex)'**
  String get settingsPrimaryColorLabel;

  /// No description provided for @settingsLogoUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Logo URL'**
  String get settingsLogoUrlLabel;

  /// No description provided for @settingsContactSupportSection.
  ///
  /// In en, this message translates to:
  /// **'Contact & Support'**
  String get settingsContactSupportSection;

  /// No description provided for @settingsWhatsappNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number (e.g. +966500000000)'**
  String get settingsWhatsappNumberLabel;

  /// No description provided for @settingsContactEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact email'**
  String get settingsContactEmailLabel;

  /// No description provided for @settingsTermsUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Terms & conditions URL'**
  String get settingsTermsUrlLabel;

  /// No description provided for @settingsPrivacyUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy URL'**
  String get settingsPrivacyUrlLabel;

  /// No description provided for @settingsFaqEnglishSection.
  ///
  /// In en, this message translates to:
  /// **'FAQ (English)'**
  String get settingsFaqEnglishSection;

  /// No description provided for @settingsFaqArabicSection.
  ///
  /// In en, this message translates to:
  /// **'FAQ (Arabic)'**
  String get settingsFaqArabicSection;

  /// No description provided for @settingsFaqQuestionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get settingsFaqQuestionLabel;

  /// No description provided for @settingsFaqAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get settingsFaqAnswerLabel;

  /// No description provided for @settingsFaqNewQuestion.
  ///
  /// In en, this message translates to:
  /// **'New question'**
  String get settingsFaqNewQuestion;

  /// No description provided for @settingsFaqNewAnswer.
  ///
  /// In en, this message translates to:
  /// **'New answer'**
  String get settingsFaqNewAnswer;

  /// No description provided for @staffTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff Accounts & Permissions'**
  String get staffTitle;

  /// No description provided for @staffGrantAccessButton.
  ///
  /// In en, this message translates to:
  /// **'Grant access'**
  String get staffGrantAccessButton;

  /// No description provided for @staffAdminOnlyNotice.
  ///
  /// In en, this message translates to:
  /// **'Only admins can grant or revoke dashboard access.'**
  String get staffAdminOnlyNotice;

  /// No description provided for @staffEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No staff/admin accounts yet.'**
  String get staffEmptyState;

  /// No description provided for @staffRevokeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Revoke to customer'**
  String get staffRevokeTooltip;

  /// No description provided for @staffRevokeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke dashboard access?'**
  String get staffRevokeDialogTitle;

  /// No description provided for @staffRevokeDialogContent.
  ///
  /// In en, this message translates to:
  /// **'{name} will lose staff/admin access and become a regular customer.'**
  String staffRevokeDialogContent(String name);

  /// No description provided for @staffRevokeButton.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get staffRevokeButton;

  /// No description provided for @staffRevokeFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to revoke access: {error}'**
  String staffRevokeFailedMessage(String error);

  /// No description provided for @staffGrantDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Grant dashboard access'**
  String get staffGrantDialogTitle;

  /// No description provided for @staffUserUidLabel.
  ///
  /// In en, this message translates to:
  /// **'User UID (from Members screen / Auth)'**
  String get staffUserUidLabel;

  /// No description provided for @staffRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get staffRoleLabel;

  /// No description provided for @staffRoleStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffRoleStaff;

  /// No description provided for @staffRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get staffRoleAdmin;

  /// No description provided for @staffGranting.
  ///
  /// In en, this message translates to:
  /// **'Granting…'**
  String get staffGranting;

  /// No description provided for @staffGrantButton.
  ///
  /// In en, this message translates to:
  /// **'Grant'**
  String get staffGrantButton;

  /// No description provided for @staffGrantFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to grant access: {error}'**
  String staffGrantFailedMessage(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
