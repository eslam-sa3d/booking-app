// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'أكاديمية السباحة';

  @override
  String get actionOk => 'موافق';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionNext => 'التالي';

  @override
  String get actionBack => 'رجوع';

  @override
  String get actionDone => 'تم';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionSeeAll => 'عرض الكل';

  @override
  String get actionSearch => 'بحث';

  @override
  String get actionFilter => 'تصفية';

  @override
  String get actionApply => 'تطبيق';

  @override
  String get actionClear => 'مسح';

  @override
  String get actionConfirm => 'تأكيد';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get actionAdd => 'إضافة';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionYes => 'نعم';

  @override
  String get actionSkip => 'تخطي';

  @override
  String get actionGetStarted => 'ابدأ الآن';

  @override
  String get actionLogout => 'تسجيل الخروج';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get errorGeneric => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get offlineBanner =>
      'أنت غير متصل بالإنترنت. يتم عرض آخر بيانات محفوظة.';

  @override
  String get emptyStateTitle => 'لا يوجد شيء هنا بعد';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navBookings => 'الحجوزات';

  @override
  String get navCalendar => 'التقويم';

  @override
  String get navProfile => 'حسابي';

  @override
  String get onboardTitle1 => 'تعلّم السباحة بالسرعة التي تناسبك';

  @override
  String get onboardSubtitle1 => 'تصفح الحصص لكل الأعمار والمستويات في فروعنا.';

  @override
  String get onboardTitle2 => 'احجز في ثوانٍ';

  @override
  String get onboardSubtitle2 =>
      'اختر التاريخ والوقت، ويتم الحجز فوراً مع تأكيد لحظي.';

  @override
  String get onboardTitle3 => 'تابع كل إنجاز';

  @override
  String get onboardSubtitle3 =>
      'تابع تقدم عائلتك في السباحة والشارات وملاحظات المدربين.';

  @override
  String get authLoginTitle => 'مرحباً بعودتك';

  @override
  String get authLoginSubtitle => 'سجّل الدخول لإدارة حجوزاتك وباقاتك.';

  @override
  String get authEmailOrPhone => 'البريد الإلكتروني أو رقم الجوال';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authLogin => 'تسجيل الدخول';

  @override
  String get authNoAccount => 'ليس لديك حساب؟';

  @override
  String get authRegister => 'إنشاء حساب';

  @override
  String get authOrContinueWith => 'أو تابع باستخدام';

  @override
  String get authContinueWithGoogle => 'المتابعة باستخدام Google';

  @override
  String get authContinueWithApple => 'المتابعة باستخدام Apple';

  @override
  String get authRegisterTitle => 'أنشئ حسابك';

  @override
  String get authRegisterSubtitle =>
      'انضم إلى الأكاديمية واحجز الحصص لك ولعائلتك.';

  @override
  String get authFullName => 'الاسم الكامل';

  @override
  String get authEmail => 'البريد الإلكتروني';

  @override
  String get authPhone => 'رقم الجوال';

  @override
  String get authConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get authAlreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get authAgreeToTerms =>
      'بالمتابعة أنت توافق على الشروط وسياسة الخصوصية';

  @override
  String get authForgotPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get authForgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين.';

  @override
  String get authSendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get authResetLinkSent =>
      'تم إرسال رابط إعادة التعيين — تحقق من بريدك.';

  @override
  String get authOtpTitle => 'تحقق من حسابك';

  @override
  String authOtpSubtitle(String destination) {
    return 'أدخل الرمز المكوّن من 4 أرقام المرسل إلى $destination';
  }

  @override
  String get authOtpResend => 'إعادة إرسال الرمز';

  @override
  String get authOtpVerify => 'تحقق';

  @override
  String get authGuestBrowse => 'المتابعة كزائر';

  @override
  String get authValidationRequired => 'هذا الحقل مطلوب';

  @override
  String get authValidationEmail => 'أدخل بريداً إلكترونياً صحيحاً';

  @override
  String get authValidationPasswordLength =>
      'يجب ألا تقل كلمة المرور عن 6 أحرف';

  @override
  String get authValidationPasswordMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String homeGreeting(String name) {
    return 'مرحباً، $name';
  }

  @override
  String get homeSearchHint => 'ابحث عن حصص، مدربين…';

  @override
  String get homeCategories => 'الفئات';

  @override
  String get homeFeaturedClasses => 'حصص مميزة';

  @override
  String get homeUpcomingClasses => 'الحصص القادمة';

  @override
  String get homeBookNow => 'احجز الآن';

  @override
  String get homePromoOffersTitle => 'عروض وإعلانات';

  @override
  String get categoryKids => 'أطفال';

  @override
  String get categoryAdults => 'كبار';

  @override
  String get categoryBeginner => 'مبتدئ';

  @override
  String get categoryIntermediate => 'متوسط';

  @override
  String get categoryAdvanced => 'متقدم';

  @override
  String get categoryPrivate => 'خاص';

  @override
  String get categoryLadiesOnly => 'نسائي فقط';

  @override
  String get filterTitle => 'تصفية الحصص';

  @override
  String get filterLevel => 'المستوى';

  @override
  String get filterAgeGroup => 'الفئة العمرية';

  @override
  String get filterBranch => 'الفرع / المسبح';

  @override
  String get filterDay => 'اليوم';

  @override
  String get classDetailsAbout => 'عن هذه الحصة';

  @override
  String get classDetailsLevel => 'المستوى';

  @override
  String get classDetailsDuration => 'المدة';

  @override
  String get classDetailsInstructor => 'المدرب';

  @override
  String get classDetailsBranch => 'المسبح / الفرع';

  @override
  String get classDetailsPrice => 'السعر';

  @override
  String get classDetailsAvailableSessions => 'المواعيد المتاحة';

  @override
  String get classDetailsBookClass => 'احجز هذه الحصة';

  @override
  String get classDetailsReviews => 'التقييمات';

  @override
  String get classDetailsNoReviews => 'لا توجد تقييمات بعد — كن أول من يقيّم!';

  @override
  String classDetailsMinutes(int count) {
    return '$count دقيقة';
  }

  @override
  String get calendarTitle => 'تقويم الحجز';

  @override
  String get calendarViewMonth => 'شهر';

  @override
  String get calendarViewWeek => 'أسبوع';

  @override
  String get calendarViewDay => 'يوم';

  @override
  String calendarSpotsLeft(int left, int total) {
    return 'متبقي $left من $total أماكن';
  }

  @override
  String get calendarFull => 'مكتمل — انضم لقائمة الانتظار';

  @override
  String get calendarNoSessions => 'لا توجد حصص في هذا اليوم';

  @override
  String get calendarSelectParticipant => 'لمن هذا الحجز؟';

  @override
  String get calendarSelectParticipantSelf => 'لنفسي';

  @override
  String get calendarRecurringOption => 'تكرار أسبوعي';

  @override
  String get calendarRecurringWeeks => 'عدد الأسابيع';

  @override
  String get calendarConfirmBooking => 'تأكيد الحجز';

  @override
  String get calendarJoinWaitlist => 'انضم لقائمة الانتظار';

  @override
  String get bookingConfirmationTitle => 'تم تأكيد الحجز!';

  @override
  String get bookingWaitlistTitle => 'أنت في قائمة الانتظار';

  @override
  String get bookingConfirmationSubtitle => 'تم إرسال التأكيد إلى إشعاراتك.';

  @override
  String get bookingWaitlistSubtitle => 'سنعلمك فور توفر مكان.';

  @override
  String get bookingConfirmationAddToCalendar => 'إضافة إلى تقويم الجهاز';

  @override
  String get bookingConfirmationViewBookings => 'عرض حجوزاتي';

  @override
  String get bookingConfirmationBackHome => 'العودة للرئيسية';

  @override
  String get myBookingsTitle => 'حجوزاتي';

  @override
  String get myBookingsUpcoming => 'القادمة';

  @override
  String get myBookingsPast => 'السابقة';

  @override
  String get myBookingsEmpty => 'لا توجد حجوزات بعد — تصفح الحصص للبدء.';

  @override
  String get myBookingsReschedule => 'إعادة الجدولة';

  @override
  String get myBookingsCancel => 'إلغاء الحجز';

  @override
  String myBookingsCancelConfirm(String policy) {
    return 'هل تريد إلغاء هذا الحجز؟ $policy';
  }

  @override
  String get myBookingsCancellationPolicy =>
      'إلغاء مجاني حتى 24 ساعة قبل موعد الحصة.';

  @override
  String get myBookingsCancelTooLate =>
      'يجب إلغاء الحجز قبل 24 ساعة على الأقل من موعد الحصة.';

  @override
  String get myBookingsRateSession => 'قيّم هذه الحصة';

  @override
  String get myBookingsStatusConfirmed => 'مؤكد';

  @override
  String get myBookingsStatusWaitlisted => 'قائمة الانتظار';

  @override
  String get myBookingsStatusCancelled => 'ملغى';

  @override
  String get myBookingsStatusCompleted => 'مكتمل';

  @override
  String get familyTitle => 'أفراد العائلة';

  @override
  String get familyAdd => 'إضافة فرد من العائلة';

  @override
  String get familyEdit => 'تعديل فرد العائلة';

  @override
  String get familyEmpty => 'أضف فرداً من العائلة لحجز الحصص له.';

  @override
  String get familyName => 'الاسم';

  @override
  String get familyDateOfBirth => 'تاريخ الميلاد';

  @override
  String get familyGender => 'الجنس';

  @override
  String get familyGenderMale => 'ذكر';

  @override
  String get familyGenderFemale => 'أنثى';

  @override
  String get familyMedicalNotes => 'ملاحظات طبية (اختياري)';

  @override
  String get familySwimmingLevel => 'مستوى السباحة';

  @override
  String familyLevelLabel(int level) {
    return 'المستوى $level من 5';
  }

  @override
  String get familyBadges => 'الشارات';

  @override
  String get familyProgressNotes => 'ملاحظات المدرب';

  @override
  String get familyNoBadgesYet => 'لا توجد شارات بعد';

  @override
  String get familyNoNotesYet => 'لا توجد ملاحظات من المدرب بعد';

  @override
  String familyAgeYears(int age) {
    return '$age سنة';
  }

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileEditProfile => 'تعديل الملف الشخصي';

  @override
  String get profilePersonalInfo => 'المعلومات الشخصية';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get profileNotificationPrefs => 'تفضيلات الإشعارات';

  @override
  String get profileFamilyMembers => 'أفراد العائلة';

  @override
  String get profileMyPackages => 'باقاتي';

  @override
  String get profilePaymentHistory => 'سجل المدفوعات';

  @override
  String get profileSettings => 'الإعدادات';

  @override
  String get profileSupport => 'الدعم';

  @override
  String get profileLogoutConfirm => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get packagesTitle => 'الباقات والأسعار';

  @override
  String get packagesMyPackages => 'باقاتي النشطة';

  @override
  String get packagesAvailable => 'الباقات المتاحة';

  @override
  String packagesSessionsLeft(int count) {
    return 'متبقي $count حصص';
  }

  @override
  String get packagesUnlimited => 'حصص غير محدودة';

  @override
  String packagesExpiresIn(int days) {
    return 'تنتهي خلال $days يوماً';
  }

  @override
  String get packagesPopular => 'الأكثر طلباً';

  @override
  String get packagesPurchase => 'شراء';

  @override
  String get packagesRenew => 'تجديد';

  @override
  String packagesValidFor(int days) {
    return 'صالحة لمدة $days يوماً';
  }

  @override
  String get packagesNoneActive => 'ليس لديك باقات نشطة';

  @override
  String get checkoutTitle => 'الدفع';

  @override
  String get checkoutOrderSummary => 'ملخص الطلب';

  @override
  String get checkoutPaymentMethod => 'طريقة الدفع';

  @override
  String get checkoutNoPaymentMethods =>
      'لا تتوفر طرق دفع حالياً — يرجى المحاولة لاحقاً.';

  @override
  String get checkoutCardNumber => 'رقم البطاقة';

  @override
  String get checkoutCardExpiry => 'شهر/سنة';

  @override
  String get checkoutCardCvv => 'رمز التحقق';

  @override
  String get checkoutTotal => 'الإجمالي';

  @override
  String checkoutPayNow(String amount) {
    return 'ادفع $amount';
  }

  @override
  String get checkoutProcessing => 'جارٍ معالجة الدفع…';

  @override
  String get checkoutSuccessTitle => 'تم الدفع بنجاح';

  @override
  String get checkoutSuccessSubtitle => 'باقتك أصبحت نشطة الآن.';

  @override
  String get checkoutFailedTitle => 'فشلت عملية الدفع';

  @override
  String get checkoutFailedSubtitle =>
      'يرجى التحقق من بيانات الدفع والمحاولة مرة أخرى.';

  @override
  String get checkoutSecureNotice =>
      'تتم معالجة المدفوعات بشكل آمن — لا نقوم أبداً بتخزين بيانات بطاقتك.';

  @override
  String get paymentHistoryTitle => 'سجل المدفوعات';

  @override
  String get paymentHistoryEmpty => 'لا توجد مدفوعات بعد';

  @override
  String get paymentHistoryDownloadReceipt => 'تحميل الإيصال';

  @override
  String get paymentHistoryReceiptTitle => 'الإيصال';

  @override
  String get paymentHistoryRequestRefund => 'طلب استرداد';

  @override
  String get paymentHistoryRefundDialogTitle => 'طلب استرداد الأموال';

  @override
  String get paymentHistoryRefundReasonHint =>
      'أخبرنا باختصار سبب طلب الاسترداد';

  @override
  String get paymentHistoryRefundSubmit => 'إرسال الطلب';

  @override
  String get paymentHistoryRefundSubmitted => 'تم إرسال طلب الاسترداد';

  @override
  String get paymentHistoryRefundPending => 'تم طلب الاسترداد — قيد المراجعة';

  @override
  String get paymentStatusSucceeded => 'ناجحة';

  @override
  String get paymentStatusPending => 'قيد الانتظار';

  @override
  String get paymentStatusFailed => 'فشلت';

  @override
  String get paymentStatusRefunded => 'مستردة';

  @override
  String get receiptTransactionId => 'رقم العملية';

  @override
  String get receiptDate => 'التاريخ';

  @override
  String get receiptDescription => 'الوصف';

  @override
  String get receiptAmount => 'المبلغ';

  @override
  String get receiptMethod => 'طريقة الدفع';

  @override
  String get receiptStatus => 'الحالة';

  @override
  String get receiptShare => 'مشاركة';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsMarkAllRead => 'تحديد الكل كمقروء';

  @override
  String get notificationsEmpty => 'لا توجد إشعارات جديدة';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsDarkMode => 'الوضع الداكن';

  @override
  String get settingsDarkModeSystem => 'افتراضي النظام';

  @override
  String get settingsDarkModeOn => 'مفعّل';

  @override
  String get settingsDarkModeOff => 'متوقف';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsSupport => 'تواصل مع الدعم';

  @override
  String get settingsWhatsapp => 'تواصل عبر واتساب';

  @override
  String get settingsFaq => 'الأسئلة الشائعة';

  @override
  String get settingsTerms => 'الشروط والأحكام';

  @override
  String get settingsPrivacy => 'سياسة الخصوصية';

  @override
  String get settingsDeleteAccount => 'حذف الحساب';

  @override
  String get settingsDeleteAccountConfirm =>
      'سيتم حذف حسابك وجميع حجوزاتك نهائياً. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String settingsAppVersion(String version) {
    return 'إصدار التطبيق $version';
  }

  @override
  String get faqTitle => 'الأسئلة الشائعة';
}
