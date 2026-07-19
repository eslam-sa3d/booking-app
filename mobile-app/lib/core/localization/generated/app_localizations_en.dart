// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Swim Academy';

  @override
  String get actionOk => 'OK';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionNext => 'Next';

  @override
  String get actionBack => 'Back';

  @override
  String get actionDone => 'Done';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionSeeAll => 'See all';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionClose => 'Close';

  @override
  String get actionYes => 'Yes';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionGetStarted => 'Get started';

  @override
  String get actionLogout => 'Log out';

  @override
  String get loading => 'Loading…';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get offlineBanner => 'You\'re offline. Showing last saved data.';

  @override
  String get emptyStateTitle => 'Nothing here yet';

  @override
  String get navHome => 'Home';

  @override
  String get navBookings => 'Bookings';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navProfile => 'Profile';

  @override
  String get onboardTitle1 => 'Learn to swim, at your pace';

  @override
  String get onboardSubtitle1 =>
      'Browse classes for every age and level across our branches.';

  @override
  String get onboardTitle2 => 'Book in seconds';

  @override
  String get onboardSubtitle2 =>
      'Pick a date, pick a time, and you\'re booked — with instant confirmation.';

  @override
  String get onboardTitle3 => 'Track every milestone';

  @override
  String get onboardSubtitle3 =>
      'Follow your family\'s swimming progress, badges, and instructor notes.';

  @override
  String get authLoginTitle => 'Welcome back';

  @override
  String get authLoginSubtitle =>
      'Log in to manage your bookings and packages.';

  @override
  String get authEmailOrPhone => 'Email or phone';

  @override
  String get authPassword => 'Password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authLogin => 'Log in';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authRegister => 'Register';

  @override
  String get authOrContinueWith => 'Or continue with';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authContinueWithApple => 'Continue with Apple';

  @override
  String get authRegisterTitle => 'Create your account';

  @override
  String get authRegisterSubtitle =>
      'Join the academy — book classes for you and your family.';

  @override
  String get authFullName => 'Full name';

  @override
  String get authEmail => 'Email';

  @override
  String get authPhone => 'Phone number';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authAlreadyHaveAccount => 'Already have an account?';

  @override
  String get authAgreeToTerms =>
      'By continuing you agree to our Terms & Privacy Policy';

  @override
  String get authForgotPasswordTitle => 'Reset your password';

  @override
  String get authForgotPasswordSubtitle =>
      'Enter your email and we\'ll send you a reset link.';

  @override
  String get authSendResetLink => 'Send reset link';

  @override
  String get authResetLinkSent => 'Reset link sent — check your inbox.';

  @override
  String get authOtpTitle => 'Verify your account';

  @override
  String authOtpSubtitle(String destination) {
    return 'Enter the 4-digit code we sent to $destination';
  }

  @override
  String get authOtpResend => 'Resend code';

  @override
  String get authOtpVerify => 'Verify';

  @override
  String get authGuestBrowse => 'Continue as guest';

  @override
  String get authValidationRequired => 'This field is required';

  @override
  String get authValidationEmail => 'Enter a valid email address';

  @override
  String get authValidationPasswordLength =>
      'Password must be at least 6 characters';

  @override
  String get authValidationPasswordMatch => 'Passwords do not match';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeSearchHint => 'Search classes, instructors…';

  @override
  String get homeCategories => 'Categories';

  @override
  String get homeFeaturedClasses => 'Featured classes';

  @override
  String get homeUpcomingClasses => 'Upcoming classes';

  @override
  String get homeBookNow => 'Book now';

  @override
  String get homePromoOffersTitle => 'Offers & announcements';

  @override
  String get homeLoadMore => 'Load more';

  @override
  String get categoryKids => 'Kids';

  @override
  String get categoryAdults => 'Adults';

  @override
  String get categoryBeginner => 'Beginner';

  @override
  String get categoryIntermediate => 'Intermediate';

  @override
  String get categoryAdvanced => 'Advanced';

  @override
  String get categoryPrivate => 'Private';

  @override
  String get categoryLadiesOnly => 'Ladies-only';

  @override
  String get filterTitle => 'Filter classes';

  @override
  String get filterLevel => 'Level';

  @override
  String get filterAgeGroup => 'Age group';

  @override
  String get filterBranch => 'Branch/Pool';

  @override
  String get filterDay => 'Day';

  @override
  String get classDetailsAbout => 'About this class';

  @override
  String get classDetailsLevel => 'Level';

  @override
  String get classDetailsDuration => 'Duration';

  @override
  String get classDetailsInstructor => 'Instructor';

  @override
  String get classDetailsBranch => 'Pool / Branch';

  @override
  String get classDetailsPrice => 'Price';

  @override
  String get classDetailsAvailableSessions => 'Available sessions';

  @override
  String get classDetailsBookClass => 'Book this class';

  @override
  String get classDetailsReviews => 'Reviews';

  @override
  String get classDetailsNoReviews => 'No reviews yet — be the first!';

  @override
  String classDetailsMinutes(int count) {
    return '$count min';
  }

  @override
  String get calendarTitle => 'Booking calendar';

  @override
  String get calendarViewMonth => 'Month';

  @override
  String get calendarViewWeek => 'Week';

  @override
  String get calendarViewDay => 'Day';

  @override
  String calendarSpotsLeft(int left, int total) {
    return '$left of $total spots left';
  }

  @override
  String get calendarFull => 'Full — join waitlist';

  @override
  String get calendarNoSessions => 'No sessions on this day';

  @override
  String get calendarSelectParticipant => 'Who is this booking for?';

  @override
  String get calendarSelectParticipantSelf => 'Myself';

  @override
  String get calendarRecurringOption => 'Repeat weekly';

  @override
  String get calendarRecurringWeeks => 'Number of weeks';

  @override
  String get calendarConfirmBooking => 'Confirm booking';

  @override
  String get calendarJoinWaitlist => 'Join waitlist';

  @override
  String get bookingConfirmationTitle => 'Booking confirmed!';

  @override
  String get bookingWaitlistTitle => 'You\'re on the waitlist';

  @override
  String get bookingConfirmationSubtitle =>
      'A confirmation has been sent to your notifications.';

  @override
  String get bookingWaitlistSubtitle =>
      'We\'ll notify you the moment a spot opens up.';

  @override
  String get bookingConfirmationAddToCalendar => 'Add to device calendar';

  @override
  String get bookingConfirmationViewBookings => 'View my bookings';

  @override
  String get bookingConfirmationBackHome => 'Back to home';

  @override
  String get myBookingsTitle => 'My bookings';

  @override
  String get myBookingsUpcoming => 'Upcoming';

  @override
  String get myBookingsPast => 'Past';

  @override
  String get myBookingsEmpty =>
      'No bookings yet — browse classes to get started.';

  @override
  String get myBookingsReschedule => 'Reschedule';

  @override
  String get myBookingsCancel => 'Cancel booking';

  @override
  String myBookingsCancelConfirm(String policy) {
    return 'Cancel this booking? $policy';
  }

  @override
  String get myBookingsCancellationPolicy =>
      'Free cancellation up to 24h before the session.';

  @override
  String get myBookingsCancelTooLate =>
      'Cancellations must be made at least 24 hours before the session starts.';

  @override
  String get myBookingsRateSession => 'Rate this session';

  @override
  String get myBookingsStatusPending => 'Confirming…';

  @override
  String get myBookingsStatusConfirmed => 'Confirmed';

  @override
  String get myBookingsStatusWaitlisted => 'Waitlisted';

  @override
  String get myBookingsStatusCancelled => 'Cancelled';

  @override
  String get myBookingsStatusCompleted => 'Completed';

  @override
  String get familyTitle => 'Family members';

  @override
  String get familyAdd => 'Add family member';

  @override
  String get familyEdit => 'Edit family member';

  @override
  String get familyEmpty => 'Add a family member to book classes for them.';

  @override
  String get familyName => 'Name';

  @override
  String get familyDateOfBirth => 'Date of birth';

  @override
  String get familyGender => 'Gender';

  @override
  String get familyGenderMale => 'Male';

  @override
  String get familyGenderFemale => 'Female';

  @override
  String get familyMedicalNotes => 'Medical notes (optional)';

  @override
  String get familySwimmingLevel => 'Swimming level';

  @override
  String familyLevelLabel(int level) {
    return 'Level $level of 5';
  }

  @override
  String get familyBadges => 'Badges';

  @override
  String get familyProgressNotes => 'Instructor notes';

  @override
  String get familyNoBadgesYet => 'No badges earned yet';

  @override
  String get familyNoNotesYet => 'No instructor notes yet';

  @override
  String familyAgeYears(int age) {
    return '$age years old';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEditProfile => 'Edit profile';

  @override
  String get profilePersonalInfo => 'Personal information';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileNotificationPrefs => 'Notification preferences';

  @override
  String get profileFamilyMembers => 'Family members';

  @override
  String get profileMyPackages => 'My packages';

  @override
  String get profilePaymentHistory => 'Payment history';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileSupport => 'Support';

  @override
  String get profileLogoutConfirm => 'Are you sure you want to log out?';

  @override
  String get profileChooseFromGallery => 'Choose from gallery';

  @override
  String get profileTakePhoto => 'Take a photo';

  @override
  String get profilePhotoUpdated => 'Profile photo updated';

  @override
  String get profilePhotoUploadError =>
      'Couldn\'t upload photo. Please try again.';

  @override
  String get profileChangePhoto => 'Change profile photo';

  @override
  String get profileConfirmPassword => 'Confirm your password';

  @override
  String get profileReauthMessage =>
      'For your security, please re-enter your password to continue.';

  @override
  String get profileEmailReauthRequired =>
      'Email not updated — re-authentication is required.';

  @override
  String get profileEmailChangeHelper =>
      'Changing this sends a verification link to the new address.';

  @override
  String profileEmailVerificationSent(String email) {
    return 'A verification link was sent to $email. Confirm it to finish updating your email.';
  }

  @override
  String get packagesTitle => 'Packages & pricing';

  @override
  String get packagesMyPackages => 'My active packages';

  @override
  String get packagesAvailable => 'Available packages';

  @override
  String packagesSessionsLeft(int count) {
    return '$count sessions left';
  }

  @override
  String get packagesUnlimited => 'Unlimited sessions';

  @override
  String packagesExpiresIn(int days) {
    return 'Expires in $days days';
  }

  @override
  String get packagesPopular => 'Most popular';

  @override
  String get packagesPurchase => 'Purchase';

  @override
  String get packagesRenew => 'Renew';

  @override
  String packagesValidFor(int days) {
    return 'Valid for $days days';
  }

  @override
  String get packagesNoneActive => 'You have no active packages';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutOrderSummary => 'Order summary';

  @override
  String get checkoutPaymentMethod => 'Payment method';

  @override
  String get checkoutNoPaymentMethods =>
      'No payment methods are available right now — please try again later.';

  @override
  String get checkoutCardNumber => 'Card number';

  @override
  String get checkoutCardExpiry => 'MM/YY';

  @override
  String get checkoutCardCvv => 'CVV';

  @override
  String get checkoutTotal => 'Total';

  @override
  String checkoutPayNow(String amount) {
    return 'Pay $amount';
  }

  @override
  String get checkoutProcessing => 'Processing payment…';

  @override
  String get checkoutSuccessTitle => 'Payment successful';

  @override
  String get checkoutSuccessSubtitle => 'Your package is now active.';

  @override
  String get checkoutFailedTitle => 'Payment failed';

  @override
  String get checkoutFailedSubtitle =>
      'Please check your payment details and try again.';

  @override
  String get checkoutSecureNotice =>
      'Payments are securely processed — we never store your card details.';

  @override
  String get checkoutPayNowLink => 'Pay Now';

  @override
  String get checkoutMethodDetailInstructions =>
      'Tap the button below to complete your payment. We\'ll confirm it once it\'s received.';

  @override
  String get checkoutPendingTitle => 'Payment pending';

  @override
  String get checkoutPendingSubtitle =>
      'We\'ll confirm your payment once it\'s received and activate your package. You can check the status anytime in Payment History.';

  @override
  String get paymentHistoryTitle => 'Payment history';

  @override
  String get paymentHistoryEmpty => 'No payments yet';

  @override
  String get paymentHistoryDownloadReceipt => 'Download receipt';

  @override
  String get paymentHistoryReceiptTitle => 'Receipt';

  @override
  String get paymentHistoryRequestRefund => 'Request refund';

  @override
  String get paymentHistoryRefundDialogTitle => 'Request a refund';

  @override
  String get paymentHistoryRefundReasonHint =>
      'Briefly tell us why you\'re requesting a refund';

  @override
  String get paymentHistoryRefundSubmit => 'Submit request';

  @override
  String get paymentHistoryRefundSubmitted => 'Refund request submitted';

  @override
  String get paymentHistoryRefundPending => 'Refund requested — pending review';

  @override
  String get paymentStatusSucceeded => 'Succeeded';

  @override
  String get paymentStatusPending => 'Pending';

  @override
  String get paymentStatusFailed => 'Failed';

  @override
  String get paymentStatusRefunded => 'Refunded';

  @override
  String get receiptTransactionId => 'Transaction ID';

  @override
  String get receiptDate => 'Date';

  @override
  String get receiptDescription => 'Description';

  @override
  String get receiptAmount => 'Amount';

  @override
  String get receiptMethod => 'Payment method';

  @override
  String get receiptStatus => 'Status';

  @override
  String get receiptShare => 'Share';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsEmpty => 'You\'re all caught up';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsDarkModeSystem => 'System default';

  @override
  String get settingsDarkModeOn => 'On';

  @override
  String get settingsDarkModeOff => 'Off';

  @override
  String get settingsNotifications => 'Push notifications';

  @override
  String get settingsSupport => 'Contact support';

  @override
  String get settingsWhatsapp => 'Chat on WhatsApp';

  @override
  String get settingsFaq => 'FAQ';

  @override
  String get settingsTerms => 'Terms & conditions';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDeleteAccountConfirm =>
      'This will permanently delete your account and all bookings. This cannot be undone.';

  @override
  String settingsAppVersion(String version) {
    return 'App version $version';
  }

  @override
  String get settingsBiometricLock => 'Face ID / biometric lock';

  @override
  String get settingsBiometricLockSubtitle =>
      'Require Face ID or fingerprint to open the app';

  @override
  String get settingsWhatsappUnavailable =>
      'WhatsApp support isn\'t available yet.';

  @override
  String get settingsEmailUnavailable => 'Email support isn\'t available yet.';

  @override
  String get settingsContentNotPublished =>
      'This content hasn\'t been published yet.';

  @override
  String get settingsEmailSupport => 'Email support';

  @override
  String get settingsReminderToggle => 'Toggle session reminders';

  @override
  String get settingsReminderLabel => 'Session reminders';

  @override
  String get settingsPromotionsToggle => 'Toggle promotions and offers';

  @override
  String get settingsPromotionsLabel => 'Promotions & offers';

  @override
  String get settingsAnnouncementsToggle => 'Toggle announcements';

  @override
  String get settingsAnnouncementsLabel => 'Announcements';

  @override
  String get appLockTitle => 'App locked';

  @override
  String get appLockSubtitle => 'Verify it\'s you to continue';

  @override
  String get appLockUnlock => 'Unlock';

  @override
  String get faqTitle => 'Frequently asked questions';

  @override
  String get faqEmpty => 'No FAQs are available yet.';

  @override
  String get faqLoadError => 'Couldn\'t load the FAQs. Please try again later.';
}
