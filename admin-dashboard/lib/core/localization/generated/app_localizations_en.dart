// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonSave => 'Save';

  @override
  String get commonSaving => 'Saving…';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonActive => 'Active';

  @override
  String get commonInactive => 'Inactive';

  @override
  String get commonRequired => 'Required';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navRequests => 'Requests';

  @override
  String get navClasses => 'Classes';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navCategories => 'Categories';

  @override
  String get navBanners => 'Banners';

  @override
  String get navPackages => 'Packages';

  @override
  String get navPayments => 'Payments';

  @override
  String get navPaymentMethods => 'Payment Methods';

  @override
  String get navReports => 'Reports & Analytics';

  @override
  String get navMembers => 'Members';

  @override
  String get navInstructors => 'Instructors';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navSettings => 'App Content & Settings';

  @override
  String get navStaff => 'Staff Accounts';

  @override
  String get navCollapseMenu => 'Collapse menu';

  @override
  String get navExpandMenu => 'Expand menu';

  @override
  String get navCloseMenu => 'Close menu';

  @override
  String get navSignOut => 'Sign out';

  @override
  String get navSwitchToArabic => 'Switch to Arabic';

  @override
  String get navSwitchToEnglish => 'Switch to English';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginSignIn => 'Sign in';

  @override
  String get loginStaffOnlyNotice =>
      'Staff and admin accounts only. Ask an admin to grant access via Staff Accounts.';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardActiveClasses => 'Active classes';

  @override
  String get dashboardTotalMembers => 'Total members';

  @override
  String get dashboardWaitlistedBookings => 'Waitlisted bookings';

  @override
  String get dashboardTodaysBookings => 'Today\'s bookings';

  @override
  String get dashboardRevenueThisMonth => 'Revenue this month';

  @override
  String get dashboardUpcomingSessions => 'Upcoming sessions (7d)';

  @override
  String get dashboardFullNearFullClasses => 'Full / near-full classes';

  @override
  String get dashboardPackagesExpiringSoon => 'Packages expiring soon';

  @override
  String get dashboardSidebarHint =>
      'Use the sidebar to manage classes, the booking calendar, banners, packages, and more. Every change here is live in the mobile app immediately — no release needed.';

  @override
  String get requestsTitle => 'Requests';

  @override
  String get requestsRefundRequestsHeading => 'Refund requests';

  @override
  String get requestsRefundRequestsSubtitle =>
      'Customer-initiated refund requests awaiting a decision.';

  @override
  String get requestsApproveRefundTitle => 'Approve refund?';

  @override
  String get requestsDenyRefundTitle => 'Deny refund?';

  @override
  String get requestsApproveRefundContent =>
      'This marks the transaction as refunded and notifies the customer. This cannot be undone from here.';

  @override
  String get requestsDenyRefundContent =>
      'The customer will be notified their refund request was denied.';

  @override
  String get requestsApproveButton => 'Approve';

  @override
  String get requestsDenyButton => 'Deny';

  @override
  String get requestsNoReasonGiven => 'No reason given';

  @override
  String get requestsNoPendingRefundRequests => 'No pending refund requests.';

  @override
  String get requestsWaitlistedBookingsHeading => 'Waitlisted bookings';

  @override
  String get requestsWaitlistSubtitle =>
      'Promotion is automatic when a confirmed booking is cancelled — this list is for visibility, not manual action.';

  @override
  String get requestsNoOneWaitlisted => 'No one is currently waitlisted.';

  @override
  String get requestsRecentCancellationsHeading => 'Recent cancellations';

  @override
  String get requestsNoRecentCancellations => 'No recent cancellations.';

  @override
  String requestsRequestedOn(String date) {
    return 'Requested $date';
  }

  @override
  String requestsSessionLabel(String sessionId) {
    return 'Session: $sessionId';
  }

  @override
  String get classesTitle => 'Classes';

  @override
  String get classesAddButton => 'Add class';

  @override
  String get classesEmptyState => 'No classes yet — add one to get started.';

  @override
  String classesRowSummary(String categories, String duration, String price) {
    return '$categories · $duration min · $price EGP';
  }

  @override
  String get classesDeleteTitle => 'Delete class?';

  @override
  String classesDeleteContent(String title) {
    return 'This does not delete existing sessions for \"$title\".';
  }

  @override
  String get classFormEditTitle => 'Edit class';

  @override
  String get classFormTitleEnLabel => 'Title (EN)';

  @override
  String get classFormTitleArLabel => 'Title (AR)';

  @override
  String get classFormDescriptionEnLabel => 'Description (EN)';

  @override
  String get classFormDescriptionArLabel => 'Description (AR)';

  @override
  String get classFormCategoriesLabel => 'Categories';

  @override
  String get classFormPriceLabel => 'Price (EGP)';

  @override
  String get classFormDurationLabel => 'Duration (min)';

  @override
  String get classFormInstructorLabel => 'Instructor';

  @override
  String get classFormBranchLabel => 'Branch / Pool';

  @override
  String get classFormSelectCategoryError => 'Select at least one category';

  @override
  String get classFormSelectInstructorBranchError =>
      'Select an instructor and branch';

  @override
  String classFormSaveError(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get instructorsTitle => 'Instructors';

  @override
  String get instructorsAddButton => 'Add instructor';

  @override
  String get instructorsEmptyState => 'No instructors yet.';

  @override
  String get instructorsViewScheduleTooltip => 'View schedule';

  @override
  String get instructorsDeleteTitle => 'Delete instructor?';

  @override
  String instructorsDeleteContent(String name) {
    return '\"$name\" will no longer be assignable to classes or sessions.';
  }

  @override
  String instructorScheduleTitle(String name) {
    return '$name — upcoming sessions';
  }

  @override
  String get instructorScheduleEmptyState => 'No upcoming sessions.';

  @override
  String get instructorFormEditTitle => 'Edit instructor';

  @override
  String get instructorFormNameEnLabel => 'Name (EN)';

  @override
  String get instructorFormNameArLabel => 'Name (AR)';

  @override
  String get instructorFormBioEnLabel => 'Bio (EN)';

  @override
  String get instructorFormBioArLabel => 'Bio (AR)';

  @override
  String get instructorFormSpecialtiesLabel => 'Specialties (comma-separated)';

  @override
  String instructorFormSaveError(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get calendarTitle => 'Calendar & Sessions';

  @override
  String get calendarManageBlockedDates => 'Manage blocked dates';

  @override
  String get calendarBulkCreateRecurring => 'Bulk-create recurring';

  @override
  String get calendarAddSession => 'Add session';

  @override
  String get calendarDeleteSessionTitle => 'Delete session?';

  @override
  String get calendarDeleteSessionContent =>
      'This does not cancel or notify already-booked customers.';

  @override
  String get calendarBlockedDateBadge => 'Blocked date';

  @override
  String get calendarNoSessionsOnDay => 'No sessions on this day';

  @override
  String get calendarBranchLabel => 'Branch';

  @override
  String get calendarAllBranchesOption => 'All branches';

  @override
  String get calendarReasonLabel => 'Reason';

  @override
  String get calendarAdding => 'Adding…';

  @override
  String get calendarAddBlockedDate => 'Add blocked date';

  @override
  String get calendarCurrentlyBlocked => 'Currently blocked';

  @override
  String get calendarNoBlockedDates => 'No blocked dates';

  @override
  String get calendarUnblockDateTitle => 'Unblock this date?';

  @override
  String calendarSessionBookedCount(int booked, int capacity) {
    return '$booked/$capacity booked';
  }

  @override
  String calendarSessionWaitlistedCount(int count) {
    return '$count waitlisted';
  }

  @override
  String calendarDateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String calendarUnblockDateContent(String date) {
    return 'Staff will be able to create sessions on $date again.';
  }

  @override
  String get sessionFormEditTitle => 'Edit session';

  @override
  String get sessionFormClassLabel => 'Class';

  @override
  String get sessionFormInstructorLabel => 'Instructor';

  @override
  String get sessionFormBranchPoolLabel => 'Branch / Pool';

  @override
  String get sessionFormCapacityLabel => 'Capacity';

  @override
  String sessionFormSaveFailed(String error) {
    return 'Failed to save: $error';
  }

  @override
  String sessionFormStartLabel(String time) {
    return 'Start: $time';
  }

  @override
  String sessionFormEndLabel(String time) {
    return 'End: $time';
  }

  @override
  String get recurringSessionTitle => 'Bulk-create recurring sessions';

  @override
  String get recurringSessionMon => 'Mon';

  @override
  String get recurringSessionTue => 'Tue';

  @override
  String get recurringSessionWed => 'Wed';

  @override
  String get recurringSessionThu => 'Thu';

  @override
  String get recurringSessionFri => 'Fri';

  @override
  String get recurringSessionSat => 'Sat';

  @override
  String get recurringSessionSun => 'Sun';

  @override
  String get recurringSessionCreating => 'Creating…';

  @override
  String get recurringSessionCreateButton => 'Create sessions';

  @override
  String recurringSessionFromLabel(String date) {
    return 'From: $date';
  }

  @override
  String recurringSessionToLabel(String date) {
    return 'To: $date';
  }

  @override
  String recurringSessionCreatedSnackbar(int count) {
    return 'Created $count sessions';
  }

  @override
  String recurringSessionCreateFailed(String error) {
    return 'Failed to create sessions: $error';
  }

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get categoriesAddButton => 'Add category';

  @override
  String get categoriesEmptyState =>
      'No categories yet — add one to let members filter classes.';

  @override
  String get categoriesDeleteTitle => 'Delete category?';

  @override
  String categoriesDeleteMessage(String name) {
    return '\"$name\" will no longer be available to tag classes.';
  }

  @override
  String categoriesSaveFailed(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get categoriesAddTitle => 'Add category';

  @override
  String get categoriesEditTitle => 'Edit category';

  @override
  String get categoriesNameEnLabel => 'Name (EN)';

  @override
  String get categoriesNameArLabel => 'Name (AR)';

  @override
  String get bannersTitle => 'Banners';

  @override
  String get bannersAddButton => 'Add banner';

  @override
  String get bannersEmptyState =>
      'No banners yet — the mobile home screen will show none until you add one.';

  @override
  String get bannersDeleteTitle => 'Delete banner?';

  @override
  String bannersDeleteMessage(String title) {
    return '\"$title\" will be removed from the mobile home screen.';
  }

  @override
  String bannersSaveFailed(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get bannersAddTitle => 'Add banner';

  @override
  String get bannersEditTitle => 'Edit banner';

  @override
  String get bannersTitleEnLabel => 'Title (EN)';

  @override
  String get bannersTitleArLabel => 'Title (AR)';

  @override
  String get bannersSubtitleEnLabel => 'Subtitle (EN)';

  @override
  String get bannersSubtitleArLabel => 'Subtitle (AR)';

  @override
  String get bannersImageUrlLabel => 'Image URL';

  @override
  String get bannersLinkActionLabel => 'Link action (e.g. class:c1, packages)';

  @override
  String get bannersActiveDateRangeLabel => 'Active date range (optional)';

  @override
  String get bannersActiveFromLabel => 'Active from';

  @override
  String get bannersActiveUntilLabel => 'Active until';

  @override
  String get bannersNoLimitLabel => 'No limit';

  @override
  String get bannersClearDateTooltip => 'Clear';

  @override
  String get bannersPreviewLabel => 'Preview';

  @override
  String get bannersPreviewTitlePlaceholder => 'Banner title';

  @override
  String get bannersPreviewSubtitlePlaceholder => 'Banner subtitle';

  @override
  String get bannersPreviewActiveNote =>
      'Would show now on the mobile home screen';

  @override
  String get bannersPreviewInactiveNote =>
      'Would NOT show right now (inactive or outside date range)';

  @override
  String get packagesTitle => 'Packages & Pricing';

  @override
  String get packagesAddPackageTitle => 'Add package';

  @override
  String get packagesEditPackageTitle => 'Edit package';

  @override
  String get packagesEmptyState => 'No packages yet.';

  @override
  String get packagesPopularBadge => 'Popular';

  @override
  String get packagesUnlimitedLabel => 'unlimited';

  @override
  String get packagesDeleteConfirmTitle => 'Delete package?';

  @override
  String packagesSessionsCount(int count) {
    return '$count sessions';
  }

  @override
  String packagesDaysCount(int count) {
    return '$count days';
  }

  @override
  String packagesPriceEgp(String price) {
    return '$price EGP';
  }

  @override
  String packagesDeleteConfirmMessage(String name) {
    return '\"$name\" will no longer be purchasable. Existing owned packages are unaffected.';
  }

  @override
  String get packageFormNameEnLabel => 'Name (EN)';

  @override
  String get packageFormNameArLabel => 'Name (AR)';

  @override
  String get packageFormDescriptionEnLabel => 'Description (EN)';

  @override
  String get packageFormDescriptionArLabel => 'Description (AR)';

  @override
  String get packageFormTypeLabel => 'Type';

  @override
  String get packageFormSessionCountLabel => 'Session count';

  @override
  String get packageFormValidityDaysLabel => 'Validity (days)';

  @override
  String get packageFormPriceLabel => 'Price (EGP)';

  @override
  String get packageFormMarkAsPopularLabel => 'Mark as popular';

  @override
  String get packageFormMustBePositive => 'Must be greater than 0';

  @override
  String packageFormSaveFailed(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get paymentsTitle => 'Payments & Reports';

  @override
  String get paymentsTotalRevenue => 'Total revenue';

  @override
  String get paymentsSuccessfulTransactions => 'Successful transactions';

  @override
  String get paymentsRevenueReportTitle => 'Revenue report';

  @override
  String paymentsRevenueReportDescription(String otherClassLabel) {
    return 'Last 6 months, succeeded transactions only. Class breakdown is best-effort — transactions without a linked booking (e.g. older ones) are grouped under \"$otherClassLabel\".';
  }

  @override
  String get paymentsOtherClassLabel => 'Other / Unlinked';

  @override
  String get paymentsFiltersTitle => 'Filters';

  @override
  String get paymentsTransactionsTitle => 'Transactions';

  @override
  String get paymentsFilterByDateRange => 'Filter by date range';

  @override
  String paymentsDateRangeLabel(String start, String end) {
    return '$start to $end';
  }

  @override
  String get paymentsClearDateFilter => 'Clear date filter';

  @override
  String get paymentsClassLabel => 'Class';

  @override
  String get paymentsAllClasses => 'All classes';

  @override
  String get paymentsRefundConfirmTitle => 'Refund this transaction?';

  @override
  String paymentsRefundConfirmContent(
    String amount,
    String currency,
    String description,
  ) {
    return 'Refunds $amount $currency for \"$description\". This cannot be undone from here.';
  }

  @override
  String get paymentsRefund => 'Refund';

  @override
  String get paymentsNoTransactions =>
      'No transactions match the current filters.';

  @override
  String get paymentsRevenueByMonth => 'Revenue by month';

  @override
  String get paymentsNoRevenuePeriod => 'No revenue in this period.';

  @override
  String get paymentsRevenueByClass => 'Revenue by class';

  @override
  String get paymentsStatusSucceeded => 'Succeeded';

  @override
  String get paymentsStatusFailed => 'Failed';

  @override
  String get paymentsStatusRefunded => 'Refunded';

  @override
  String get paymentsStatusPending => 'Pending';

  @override
  String get paymentMethodsEmptyState =>
      'No payment methods yet — add one to offer it at checkout.';

  @override
  String get paymentMethodFormAddTitle => 'Add payment method';

  @override
  String get paymentMethodFormEditTitle => 'Edit payment method';

  @override
  String get paymentMethodFormNameEnLabel => 'Name (EN)';

  @override
  String get paymentMethodFormNameArLabel => 'Name (AR)';

  @override
  String get paymentMethodFormLogoUrlLabel => 'Logo URL';

  @override
  String get paymentMethodFormUrlHint => 'https://...';

  @override
  String get paymentMethodFormPaymentLinkLabel => 'Payment link URL';

  @override
  String get paymentMethodFormPaymentLinkHelper =>
      'Opened when the customer taps \"Pay Now\" at checkout';

  @override
  String get paymentMethodFormActiveSubtitle =>
      'Shown to customers at checkout';

  @override
  String get reportsRefreshTooltip => 'Refresh';

  @override
  String get reportsBookings30d => 'Bookings (30d)';

  @override
  String get reportsAttendanceRate => 'Attendance rate';

  @override
  String get reportsRevenue6mo => 'Revenue (6mo)';

  @override
  String get reportsNewMembers6mo => 'New members (6mo)';

  @override
  String get reportsBookingsTrendTitle => 'Bookings trend (last 30 days)';

  @override
  String get reportsBookingsTrendDescription =>
      'Count of bookings created per day.';

  @override
  String get reportsAttendanceDescription =>
      'Completed vs. cancelled bookings (all time). Cancellations are treated as non-attendance — this app doesn\'t track a separate no-show flag, so it\'s an approximation.';

  @override
  String get reportsCompletedLabel => 'completed';

  @override
  String get reportsPopularClassesAndTimesTitle => 'Popular classes & times';

  @override
  String get reportsPopularClassesTimesDescription =>
      'Ranked by booking count over the last 30 days.';

  @override
  String get reportsTopClasses => 'Top classes';

  @override
  String get reportsPopularTimes => 'Popular times';

  @override
  String get reportsNoBookingsInPeriod => 'No bookings in this period.';

  @override
  String get reportsRevenueTrendTitle => 'Revenue trend (last 6 months)';

  @override
  String get reportsRevenueTrendDescription =>
      'Sum of succeeded transactions, by month.';

  @override
  String get reportsNoRevenueInPeriod => 'No revenue in this period.';

  @override
  String get reportsMemberGrowthTitle => 'Member growth (last 6 months)';

  @override
  String get reportsMemberGrowthDescription =>
      'New customer signups, by month.';

  @override
  String get reportsNoNewMembersInPeriod => 'No new members in this period.';

  @override
  String get reportsMonthJan => 'Jan';

  @override
  String get reportsMonthFeb => 'Feb';

  @override
  String get reportsMonthMar => 'Mar';

  @override
  String get reportsMonthApr => 'Apr';

  @override
  String get reportsMonthMay => 'May';

  @override
  String get reportsMonthJun => 'Jun';

  @override
  String get reportsMonthJul => 'Jul';

  @override
  String get reportsMonthAug => 'Aug';

  @override
  String get reportsMonthSep => 'Sep';

  @override
  String get reportsMonthOct => 'Oct';

  @override
  String get reportsMonthNov => 'Nov';

  @override
  String get reportsMonthDec => 'Dec';

  @override
  String reportsFailedToLoad(String error) {
    return 'Failed to load reports: $error';
  }

  @override
  String reportsCompletedCount(int count) {
    return 'Completed: $count';
  }

  @override
  String reportsCancelledCount(int count) {
    return 'Cancelled: $count';
  }

  @override
  String reportsRevenueTooltip(String month, String value) {
    return '$month: $value EGP';
  }

  @override
  String reportsMemberGrowthTooltip(String month, int count) {
    return '$month: $count';
  }

  @override
  String get membersTitle => 'Members';

  @override
  String get membersSearchHint => 'Search by name or email';

  @override
  String get membersNoResults => 'No members found.';

  @override
  String get membersReactivate => 'Reactivate';

  @override
  String get membersSuspend => 'Suspend';

  @override
  String membersFamilyMembersCount(int count) {
    return 'Family members ($count)';
  }

  @override
  String membersBookingsCount(int count) {
    return 'Bookings ($count)';
  }

  @override
  String membersPaymentHistoryCount(int count) {
    return 'Payment history ($count)';
  }

  @override
  String get membersNoPayments => 'No payments yet.';

  @override
  String get membersEditProfile => 'Edit profile';

  @override
  String get membersNoDescription => '(no description)';

  @override
  String get membersAwardBadge => 'Award badge';

  @override
  String get membersAddProgressNoteAction => 'Add progress note';

  @override
  String get membersAward => 'Award';

  @override
  String get membersNameLabel => 'Name';

  @override
  String get membersPhoneLabel => 'Phone';

  @override
  String get membersTitleEnLabel => 'Title (EN)';

  @override
  String get membersTitleArLabel => 'Title (AR)';

  @override
  String get membersIconNameLabel => 'Icon name (Material, e.g. emoji_events)';

  @override
  String get membersNoteEnLabel => 'Note (EN)';

  @override
  String get membersNoteArLabel => 'Note (AR)';

  @override
  String get membersInstructorNameLabel => 'Instructor name';

  @override
  String membersFailedToSave(String error) {
    return 'Failed to save: $error';
  }

  @override
  String membersBadgesLabel(String badges) {
    return 'Badges: $badges';
  }

  @override
  String membersProgressNotesCount(int count) {
    return '$count progress note(s)';
  }

  @override
  String membersFamilyMemberAge(String name, int age) {
    return '$name (${age}y)';
  }

  @override
  String get notificationsTitle => 'Notification Center';

  @override
  String get notificationsComposeBroadcast => 'Compose broadcast';

  @override
  String notificationsFailedToLoad(String error) {
    return 'Failed to load broadcasts: $error';
  }

  @override
  String get notificationsEmptyState => 'No broadcasts sent yet.';

  @override
  String get notificationsSegmentExpiringPackage =>
      'Expiring package this week';

  @override
  String get notificationsSegmentNoBooking => 'No booking in last 30 days';

  @override
  String notificationsTargetSegmentDesc(String segment) {
    return 'segment: $segment';
  }

  @override
  String get notificationsTargetSingleUser => 'Single user';

  @override
  String get notificationsTargetAllUsers => 'All users';

  @override
  String get notificationsTargetSegmentOption => 'Segment';

  @override
  String notificationsBodyTargetLine(String body, String target) {
    return '$body · target: $target';
  }

  @override
  String notificationsScheduledFor(String date) {
    return 'Scheduled for $date';
  }

  @override
  String get notificationsLoadingStats => 'Loading delivery stats…';

  @override
  String notificationsFailedToLoadStats(String error) {
    return 'Failed to load delivery stats: $error';
  }

  @override
  String notificationsDeliveryStats(int delivered, int read) {
    return 'Delivered: $delivered · Read: $read';
  }

  @override
  String get notificationsStatusDraft => 'Draft';

  @override
  String get notificationsStatusScheduled => 'Scheduled';

  @override
  String get notificationsStatusSent => 'Sent';

  @override
  String get notificationsRequiredFieldsError =>
      'Title (EN) and Message (EN) are required.';

  @override
  String get notificationsPickMemberError => 'Pick a member to target.';

  @override
  String notificationsFailedToSend(String error) {
    return 'Failed to send: $error';
  }

  @override
  String get notificationsTitleEnLabel => 'Title (EN)';

  @override
  String get notificationsTitleArLabel => 'Title (AR)';

  @override
  String get notificationsMessageEnLabel => 'Message (EN)';

  @override
  String get notificationsMessageArLabel => 'Message (AR)';

  @override
  String get notificationsTargetLabel => 'Target';

  @override
  String get notificationsSearchMemberLabel => 'Search member by name or email';

  @override
  String notificationsSelectedMember(String name) {
    return 'Selected: $name';
  }

  @override
  String get notificationsScheduleForLater => 'Schedule for later';

  @override
  String get notificationsScheduleOffHint => 'Off = send immediately';

  @override
  String get notificationsSending => 'Sending…';

  @override
  String get notificationsScheduleButton => 'Schedule';

  @override
  String get notificationsSendButton => 'Send';

  @override
  String get settingsSaveChangesButton => 'Save changes';

  @override
  String get settingsSavedMessage => 'Settings saved';

  @override
  String settingsSaveFailedMessage(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get settingsBrandingSection => 'Branding';

  @override
  String get settingsPrimaryColorLabel => 'Primary color (hex)';

  @override
  String get settingsLogoUrlLabel => 'Logo URL';

  @override
  String get settingsContactSupportSection => 'Contact & Support';

  @override
  String get settingsWhatsappNumberLabel =>
      'WhatsApp number (e.g. +966500000000)';

  @override
  String get settingsContactEmailLabel => 'Contact email';

  @override
  String get settingsTermsUrlLabel => 'Terms & conditions URL';

  @override
  String get settingsPrivacyUrlLabel => 'Privacy policy URL';

  @override
  String get settingsFaqEnglishSection => 'FAQ (English)';

  @override
  String get settingsFaqArabicSection => 'FAQ (Arabic)';

  @override
  String get settingsFaqQuestionLabel => 'Question';

  @override
  String get settingsFaqAnswerLabel => 'Answer';

  @override
  String get settingsFaqNewQuestion => 'New question';

  @override
  String get settingsFaqNewAnswer => 'New answer';

  @override
  String get staffTitle => 'Staff Accounts & Permissions';

  @override
  String get staffGrantAccessButton => 'Grant access';

  @override
  String get staffAdminOnlyNotice =>
      'Only admins can grant or revoke dashboard access.';

  @override
  String get staffEmptyState => 'No staff/admin accounts yet.';

  @override
  String get staffRevokeTooltip => 'Revoke to customer';

  @override
  String get staffRevokeDialogTitle => 'Revoke dashboard access?';

  @override
  String staffRevokeDialogContent(String name) {
    return '$name will lose staff/admin access and become a regular customer.';
  }

  @override
  String get staffRevokeButton => 'Revoke';

  @override
  String staffRevokeFailedMessage(String error) {
    return 'Failed to revoke access: $error';
  }

  @override
  String get staffGrantDialogTitle => 'Grant dashboard access';

  @override
  String get staffUserUidLabel => 'User UID (from Members screen / Auth)';

  @override
  String get staffRoleLabel => 'Role';

  @override
  String get staffRoleStaff => 'Staff';

  @override
  String get staffRoleAdmin => 'Admin';

  @override
  String get staffGranting => 'Granting…';

  @override
  String get staffGrantButton => 'Grant';

  @override
  String staffGrantFailedMessage(String error) {
    return 'Failed to grant access: $error';
  }
}
