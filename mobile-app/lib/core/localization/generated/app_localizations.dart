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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Swim Academy'**
  String get appName;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get actionSeeAll;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @actionFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get actionFilter;

  /// No description provided for @actionApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get actionApply;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get actionYes;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get actionGetStarted;

  /// No description provided for @actionLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get actionLogout;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Showing last saved data.'**
  String get offlineBanner;

  /// No description provided for @emptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyStateTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get navBookings;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @onboardTitle1.
  ///
  /// In en, this message translates to:
  /// **'Learn to swim, at your pace'**
  String get onboardTitle1;

  /// No description provided for @onboardSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Browse classes for every age and level across our branches.'**
  String get onboardSubtitle1;

  /// No description provided for @onboardTitle2.
  ///
  /// In en, this message translates to:
  /// **'Book in seconds'**
  String get onboardTitle2;

  /// No description provided for @onboardSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Pick a date, pick a time, and you\'re booked — with instant confirmation.'**
  String get onboardSubtitle2;

  /// No description provided for @onboardTitle3.
  ///
  /// In en, this message translates to:
  /// **'Track every milestone'**
  String get onboardTitle3;

  /// No description provided for @onboardSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Follow your family\'s swimming progress, badges, and instructor notes.'**
  String get onboardSubtitle3;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to manage your bookings and packages.'**
  String get authLoginSubtitle;

  /// No description provided for @authEmailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or phone'**
  String get authEmailOrPhone;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLogin;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegister;

  /// No description provided for @authOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get authOrContinueWith;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authContinueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authContinueWithApple;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the academy — book classes for you and your family.'**
  String get authRegisterSubtitle;

  /// No description provided for @authFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authFullName;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get authPhone;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authAgreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our Terms & Privacy Policy'**
  String get authAgreeToTerms;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a reset link.'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authSendResetLink;

  /// No description provided for @authResetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent — check your inbox.'**
  String get authResetLinkSent;

  /// No description provided for @authOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your account'**
  String get authOtpTitle;

  /// No description provided for @authOtpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit code we sent to {destination}'**
  String authOtpSubtitle(String destination);

  /// No description provided for @authOtpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get authOtpResend;

  /// No description provided for @authOtpVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authOtpVerify;

  /// No description provided for @authGuestBrowse.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get authGuestBrowse;

  /// No description provided for @authValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get authValidationRequired;

  /// No description provided for @authValidationEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get authValidationEmail;

  /// No description provided for @authValidationPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authValidationPasswordLength;

  /// No description provided for @authValidationPasswordMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authValidationPasswordMatch;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search classes, instructors…'**
  String get homeSearchHint;

  /// No description provided for @homeCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get homeCategories;

  /// No description provided for @homeFeaturedClasses.
  ///
  /// In en, this message translates to:
  /// **'Featured classes'**
  String get homeFeaturedClasses;

  /// No description provided for @homeUpcomingClasses.
  ///
  /// In en, this message translates to:
  /// **'Upcoming classes'**
  String get homeUpcomingClasses;

  /// No description provided for @homeBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book now'**
  String get homeBookNow;

  /// No description provided for @homePromoOffersTitle.
  ///
  /// In en, this message translates to:
  /// **'Offers & announcements'**
  String get homePromoOffersTitle;

  /// No description provided for @categoryKids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get categoryKids;

  /// No description provided for @categoryAdults.
  ///
  /// In en, this message translates to:
  /// **'Adults'**
  String get categoryAdults;

  /// No description provided for @categoryBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get categoryBeginner;

  /// No description provided for @categoryIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get categoryIntermediate;

  /// No description provided for @categoryAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get categoryAdvanced;

  /// No description provided for @categoryPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get categoryPrivate;

  /// No description provided for @categoryLadiesOnly.
  ///
  /// In en, this message translates to:
  /// **'Ladies-only'**
  String get categoryLadiesOnly;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter classes'**
  String get filterTitle;

  /// No description provided for @filterLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get filterLevel;

  /// No description provided for @filterAgeGroup.
  ///
  /// In en, this message translates to:
  /// **'Age group'**
  String get filterAgeGroup;

  /// No description provided for @filterBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch/Pool'**
  String get filterBranch;

  /// No description provided for @filterDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get filterDay;

  /// No description provided for @classDetailsAbout.
  ///
  /// In en, this message translates to:
  /// **'About this class'**
  String get classDetailsAbout;

  /// No description provided for @classDetailsLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get classDetailsLevel;

  /// No description provided for @classDetailsDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get classDetailsDuration;

  /// No description provided for @classDetailsInstructor.
  ///
  /// In en, this message translates to:
  /// **'Instructor'**
  String get classDetailsInstructor;

  /// No description provided for @classDetailsBranch.
  ///
  /// In en, this message translates to:
  /// **'Pool / Branch'**
  String get classDetailsBranch;

  /// No description provided for @classDetailsPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get classDetailsPrice;

  /// No description provided for @classDetailsAvailableSessions.
  ///
  /// In en, this message translates to:
  /// **'Available sessions'**
  String get classDetailsAvailableSessions;

  /// No description provided for @classDetailsBookClass.
  ///
  /// In en, this message translates to:
  /// **'Book this class'**
  String get classDetailsBookClass;

  /// No description provided for @classDetailsReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get classDetailsReviews;

  /// No description provided for @classDetailsNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet — be the first!'**
  String get classDetailsNoReviews;

  /// No description provided for @classDetailsMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String classDetailsMinutes(int count);

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking calendar'**
  String get calendarTitle;

  /// No description provided for @calendarViewMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendarViewMonth;

  /// No description provided for @calendarViewWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get calendarViewWeek;

  /// No description provided for @calendarViewDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get calendarViewDay;

  /// No description provided for @calendarSpotsLeft.
  ///
  /// In en, this message translates to:
  /// **'{left} of {total} spots left'**
  String calendarSpotsLeft(int left, int total);

  /// No description provided for @calendarFull.
  ///
  /// In en, this message translates to:
  /// **'Full — join waitlist'**
  String get calendarFull;

  /// No description provided for @calendarNoSessions.
  ///
  /// In en, this message translates to:
  /// **'No sessions on this day'**
  String get calendarNoSessions;

  /// No description provided for @calendarSelectParticipant.
  ///
  /// In en, this message translates to:
  /// **'Who is this booking for?'**
  String get calendarSelectParticipant;

  /// No description provided for @calendarSelectParticipantSelf.
  ///
  /// In en, this message translates to:
  /// **'Myself'**
  String get calendarSelectParticipantSelf;

  /// No description provided for @calendarRecurringOption.
  ///
  /// In en, this message translates to:
  /// **'Repeat weekly'**
  String get calendarRecurringOption;

  /// No description provided for @calendarRecurringWeeks.
  ///
  /// In en, this message translates to:
  /// **'Number of weeks'**
  String get calendarRecurringWeeks;

  /// No description provided for @calendarConfirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get calendarConfirmBooking;

  /// No description provided for @calendarJoinWaitlist.
  ///
  /// In en, this message translates to:
  /// **'Join waitlist'**
  String get calendarJoinWaitlist;

  /// No description provided for @bookingConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed!'**
  String get bookingConfirmationTitle;

  /// No description provided for @bookingWaitlistTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re on the waitlist'**
  String get bookingWaitlistTitle;

  /// No description provided for @bookingConfirmationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A confirmation has been sent to your notifications.'**
  String get bookingConfirmationSubtitle;

  /// No description provided for @bookingWaitlistSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you the moment a spot opens up.'**
  String get bookingWaitlistSubtitle;

  /// No description provided for @bookingConfirmationAddToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to device calendar'**
  String get bookingConfirmationAddToCalendar;

  /// No description provided for @bookingConfirmationViewBookings.
  ///
  /// In en, this message translates to:
  /// **'View my bookings'**
  String get bookingConfirmationViewBookings;

  /// No description provided for @bookingConfirmationBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get bookingConfirmationBackHome;

  /// No description provided for @myBookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'My bookings'**
  String get myBookingsTitle;

  /// No description provided for @myBookingsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get myBookingsUpcoming;

  /// No description provided for @myBookingsPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get myBookingsPast;

  /// No description provided for @myBookingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet — browse classes to get started.'**
  String get myBookingsEmpty;

  /// No description provided for @myBookingsReschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get myBookingsReschedule;

  /// No description provided for @myBookingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get myBookingsCancel;

  /// No description provided for @myBookingsCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel this booking? {policy}'**
  String myBookingsCancelConfirm(String policy);

  /// No description provided for @myBookingsCancellationPolicy.
  ///
  /// In en, this message translates to:
  /// **'Free cancellation up to 24h before the session.'**
  String get myBookingsCancellationPolicy;

  /// No description provided for @myBookingsCancelTooLate.
  ///
  /// In en, this message translates to:
  /// **'Cancellations must be made at least 24 hours before the session starts.'**
  String get myBookingsCancelTooLate;

  /// No description provided for @myBookingsRateSession.
  ///
  /// In en, this message translates to:
  /// **'Rate this session'**
  String get myBookingsRateSession;

  /// No description provided for @myBookingsStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get myBookingsStatusConfirmed;

  /// No description provided for @myBookingsStatusWaitlisted.
  ///
  /// In en, this message translates to:
  /// **'Waitlisted'**
  String get myBookingsStatusWaitlisted;

  /// No description provided for @myBookingsStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get myBookingsStatusCancelled;

  /// No description provided for @myBookingsStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get myBookingsStatusCompleted;

  /// No description provided for @familyTitle.
  ///
  /// In en, this message translates to:
  /// **'Family members'**
  String get familyTitle;

  /// No description provided for @familyAdd.
  ///
  /// In en, this message translates to:
  /// **'Add family member'**
  String get familyAdd;

  /// No description provided for @familyEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit family member'**
  String get familyEdit;

  /// No description provided for @familyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add a family member to book classes for them.'**
  String get familyEmpty;

  /// No description provided for @familyName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get familyName;

  /// No description provided for @familyDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get familyDateOfBirth;

  /// No description provided for @familyGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get familyGender;

  /// No description provided for @familyGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get familyGenderMale;

  /// No description provided for @familyGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get familyGenderFemale;

  /// No description provided for @familyMedicalNotes.
  ///
  /// In en, this message translates to:
  /// **'Medical notes (optional)'**
  String get familyMedicalNotes;

  /// No description provided for @familySwimmingLevel.
  ///
  /// In en, this message translates to:
  /// **'Swimming level'**
  String get familySwimmingLevel;

  /// No description provided for @familyLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {level} of 5'**
  String familyLevelLabel(int level);

  /// No description provided for @familyBadges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get familyBadges;

  /// No description provided for @familyProgressNotes.
  ///
  /// In en, this message translates to:
  /// **'Instructor notes'**
  String get familyProgressNotes;

  /// No description provided for @familyNoBadgesYet.
  ///
  /// In en, this message translates to:
  /// **'No badges earned yet'**
  String get familyNoBadgesYet;

  /// No description provided for @familyNoNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No instructor notes yet'**
  String get familyNoNotesYet;

  /// No description provided for @familyAgeYears.
  ///
  /// In en, this message translates to:
  /// **'{age} years old'**
  String familyAgeYears(int age);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditProfile;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get profilePersonalInfo;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileNotificationPrefs.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences'**
  String get profileNotificationPrefs;

  /// No description provided for @profileFamilyMembers.
  ///
  /// In en, this message translates to:
  /// **'Family members'**
  String get profileFamilyMembers;

  /// No description provided for @profileMyPackages.
  ///
  /// In en, this message translates to:
  /// **'My packages'**
  String get profileMyPackages;

  /// No description provided for @profilePaymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get profilePaymentHistory;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get profileSupport;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profileLogoutConfirm;

  /// No description provided for @packagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Packages & pricing'**
  String get packagesTitle;

  /// No description provided for @packagesMyPackages.
  ///
  /// In en, this message translates to:
  /// **'My active packages'**
  String get packagesMyPackages;

  /// No description provided for @packagesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available packages'**
  String get packagesAvailable;

  /// No description provided for @packagesSessionsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions left'**
  String packagesSessionsLeft(int count);

  /// No description provided for @packagesUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited sessions'**
  String get packagesUnlimited;

  /// No description provided for @packagesExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Expires in {days} days'**
  String packagesExpiresIn(int days);

  /// No description provided for @packagesPopular.
  ///
  /// In en, this message translates to:
  /// **'Most popular'**
  String get packagesPopular;

  /// No description provided for @packagesPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get packagesPurchase;

  /// No description provided for @packagesRenew.
  ///
  /// In en, this message translates to:
  /// **'Renew'**
  String get packagesRenew;

  /// No description provided for @packagesValidFor.
  ///
  /// In en, this message translates to:
  /// **'Valid for {days} days'**
  String packagesValidFor(int days);

  /// No description provided for @packagesNoneActive.
  ///
  /// In en, this message translates to:
  /// **'You have no active packages'**
  String get packagesNoneActive;

  /// No description provided for @checkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// No description provided for @checkoutOrderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get checkoutOrderSummary;

  /// No description provided for @checkoutPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get checkoutPaymentMethod;

  /// No description provided for @checkoutNoPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'No payment methods are available right now — please try again later.'**
  String get checkoutNoPaymentMethods;

  /// No description provided for @checkoutCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get checkoutCardNumber;

  /// No description provided for @checkoutCardExpiry.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get checkoutCardExpiry;

  /// No description provided for @checkoutCardCvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get checkoutCardCvv;

  /// No description provided for @checkoutTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get checkoutTotal;

  /// No description provided for @checkoutPayNow.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String checkoutPayNow(String amount);

  /// No description provided for @checkoutProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing payment…'**
  String get checkoutProcessing;

  /// No description provided for @checkoutSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get checkoutSuccessTitle;

  /// No description provided for @checkoutSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your package is now active.'**
  String get checkoutSuccessSubtitle;

  /// No description provided for @checkoutFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get checkoutFailedTitle;

  /// No description provided for @checkoutFailedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please check your payment details and try again.'**
  String get checkoutFailedSubtitle;

  /// No description provided for @checkoutSecureNotice.
  ///
  /// In en, this message translates to:
  /// **'Payments are securely processed — we never store your card details.'**
  String get checkoutSecureNotice;

  /// No description provided for @paymentHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get paymentHistoryTitle;

  /// No description provided for @paymentHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get paymentHistoryEmpty;

  /// No description provided for @paymentHistoryDownloadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Download receipt'**
  String get paymentHistoryDownloadReceipt;

  /// No description provided for @paymentHistoryReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get paymentHistoryReceiptTitle;

  /// No description provided for @paymentHistoryRequestRefund.
  ///
  /// In en, this message translates to:
  /// **'Request refund'**
  String get paymentHistoryRequestRefund;

  /// No description provided for @paymentHistoryRefundDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Request a refund'**
  String get paymentHistoryRefundDialogTitle;

  /// No description provided for @paymentHistoryRefundReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Briefly tell us why you\'re requesting a refund'**
  String get paymentHistoryRefundReasonHint;

  /// No description provided for @paymentHistoryRefundSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit request'**
  String get paymentHistoryRefundSubmit;

  /// No description provided for @paymentHistoryRefundSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Refund request submitted'**
  String get paymentHistoryRefundSubmitted;

  /// No description provided for @paymentHistoryRefundPending.
  ///
  /// In en, this message translates to:
  /// **'Refund requested — pending review'**
  String get paymentHistoryRefundPending;

  /// No description provided for @paymentStatusSucceeded.
  ///
  /// In en, this message translates to:
  /// **'Succeeded'**
  String get paymentStatusSucceeded;

  /// No description provided for @paymentStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get paymentStatusPending;

  /// No description provided for @paymentStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get paymentStatusFailed;

  /// No description provided for @paymentStatusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get paymentStatusRefunded;

  /// No description provided for @receiptTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get receiptTransactionId;

  /// No description provided for @receiptDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get receiptDate;

  /// No description provided for @receiptDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get receiptDescription;

  /// No description provided for @receiptAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get receiptAmount;

  /// No description provided for @receiptMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get receiptMethod;

  /// No description provided for @receiptStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get receiptStatus;

  /// No description provided for @receiptShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get receiptShare;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get notificationsEmpty;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get settingsLanguageArabic;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsDarkModeSystem;

  /// No description provided for @settingsDarkModeOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settingsDarkModeOn;

  /// No description provided for @settingsDarkModeOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingsDarkModeOff;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get settingsSupport;

  /// No description provided for @settingsWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Chat on WhatsApp'**
  String get settingsWhatsapp;

  /// No description provided for @settingsFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get settingsFaq;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & conditions'**
  String get settingsTerms;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all bookings. This cannot be undone.'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App version {version}'**
  String settingsAppVersion(String version);

  /// No description provided for @settingsBiometricLock.
  ///
  /// In en, this message translates to:
  /// **'Face ID / biometric lock'**
  String get settingsBiometricLock;

  /// No description provided for @settingsBiometricLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require Face ID or fingerprint to open the app'**
  String get settingsBiometricLockSubtitle;

  /// No description provided for @appLockTitle.
  ///
  /// In en, this message translates to:
  /// **'App locked'**
  String get appLockTitle;

  /// No description provided for @appLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify it\'s you to continue'**
  String get appLockSubtitle;

  /// No description provided for @appLockUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get appLockUnlock;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get faqTitle;
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
