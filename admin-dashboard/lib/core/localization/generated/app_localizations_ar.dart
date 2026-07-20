// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonSaving => 'جارٍ الحفظ…';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonAdd => 'إضافة';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonActive => 'نشط';

  @override
  String get commonInactive => 'غير نشط';

  @override
  String get commonRequired => 'مطلوب';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonYes => 'نعم';

  @override
  String get commonNo => 'لا';

  @override
  String get navDashboard => 'الرئيسية';

  @override
  String get navRequests => 'الطلبات';

  @override
  String get navClasses => 'الحصص';

  @override
  String get navCalendar => 'التقويم';

  @override
  String get navCategories => 'الفئات';

  @override
  String get navBanners => 'البانرات';

  @override
  String get navPackages => 'الباقات';

  @override
  String get navPayments => 'المدفوعات';

  @override
  String get navPaymentMethods => 'طرق الدفع';

  @override
  String get navReports => 'التقارير والتحليلات';

  @override
  String get navMembers => 'الأعضاء';

  @override
  String get navInstructors => 'المدربين';

  @override
  String get navNotifications => 'الإشعارات';

  @override
  String get navSettings => 'محتوى التطبيق والإعدادات';

  @override
  String get navStaff => 'حسابات الموظفين';

  @override
  String get navCollapseMenu => 'طي القائمة';

  @override
  String get navExpandMenu => 'توسيع القائمة';

  @override
  String get navCloseMenu => 'إغلاق القائمة';

  @override
  String get navSignOut => 'تسجيل الخروج';

  @override
  String get navSwitchToArabic => 'التبديل إلى العربية';

  @override
  String get navSwitchToEnglish => 'التبديل إلى الإنجليزية';

  @override
  String get loginEmail => 'البريد الإلكتروني';

  @override
  String get loginPassword => 'كلمة المرور';

  @override
  String get loginSignIn => 'تسجيل الدخول';

  @override
  String get dashboardTitle => 'لوحة التحكم';

  @override
  String get dashboardActiveClasses => 'الفصول النشطة';

  @override
  String get dashboardTotalMembers => 'إجمالي الأعضاء';

  @override
  String get dashboardWaitlistedBookings => 'الحجوزات في قائمة الانتظار';

  @override
  String get dashboardTodaysBookings => 'حجوزات اليوم';

  @override
  String get dashboardRevenueThisMonth => 'الإيرادات هذا الشهر';

  @override
  String get dashboardUpcomingSessions => 'الجلسات القادمة (7 أيام)';

  @override
  String get dashboardFullNearFullClasses => 'فصول ممتلئة / شبه ممتلئة';

  @override
  String get dashboardPackagesExpiringSoon => 'باقات تنتهي قريبا';

  @override
  String get dashboardSidebarHint =>
      'استخدم الشريط الجانبي لإدارة الفصول وتقويم الحجوزات واللافتات والباقات والمزيد. كل تغيير هنا يظهر مباشرة في تطبيق الجوال فورا — دون الحاجة لإصدار جديد.';

  @override
  String get requestsTitle => 'الطلبات';

  @override
  String get requestsRefundRequestsHeading => 'طلبات الاسترداد';

  @override
  String get requestsRefundRequestsSubtitle =>
      'طلبات استرداد بدأها العملاء بانتظار اتخاذ قرار.';

  @override
  String get requestsApproveRefundTitle => 'الموافقة على الاسترداد؟';

  @override
  String get requestsDenyRefundTitle => 'رفض الاسترداد؟';

  @override
  String get requestsApproveRefundContent =>
      'سيتم وضع علامة على المعاملة كمستردة وإخطار العميل. لا يمكن التراجع عن هذا الإجراء من هنا.';

  @override
  String get requestsDenyRefundContent =>
      'سيتم إخطار العميل برفض طلب الاسترداد الخاص به.';

  @override
  String get requestsApproveButton => 'قبول';

  @override
  String get requestsDenyButton => 'رفض';

  @override
  String get requestsNoReasonGiven => 'لم يتم تقديم سبب';

  @override
  String get requestsNoPendingRefundRequests =>
      'لا توجد طلبات استرداد قيد الانتظار.';

  @override
  String get requestsWaitlistedBookingsHeading => 'الحجوزات في قائمة الانتظار';

  @override
  String get requestsWaitlistSubtitle =>
      'الترقية تتم تلقائيا عند إلغاء حجز مؤكد — هذه القائمة للعرض فقط وليست لاتخاذ إجراء يدوي.';

  @override
  String get requestsNoOneWaitlisted => 'لا يوجد أحد في قائمة الانتظار حاليا.';

  @override
  String get requestsRecentCancellationsHeading => 'الإلغاءات الأخيرة';

  @override
  String get requestsNoRecentCancellations => 'لا توجد إلغاءات حديثة.';

  @override
  String requestsRequestedOn(String date) {
    return 'تم الطلب في $date';
  }

  @override
  String requestsSessionLabel(String sessionId) {
    return 'الحصة: $sessionId';
  }

  @override
  String get classesTitle => 'الحصص';

  @override
  String get classesAddButton => 'إضافة حصة';

  @override
  String get classesEmptyState => 'لا توجد حصص بعد — أضف حصة للبدء.';

  @override
  String classesRowSummary(String categories, String duration, String price) {
    return '$categories · $duration دقيقة · $price EGP';
  }

  @override
  String get classesDeleteTitle => 'حذف الحصة؟';

  @override
  String classesDeleteContent(String title) {
    return 'هذا لن يحذف الجلسات الحالية الخاصة بـ \"$title\".';
  }

  @override
  String get classFormEditTitle => 'تعديل الحصة';

  @override
  String get classFormTitleEnLabel => 'العنوان (بالإنجليزية)';

  @override
  String get classFormTitleArLabel => 'العنوان (بالعربية)';

  @override
  String get classFormDescriptionEnLabel => 'الوصف (بالإنجليزية)';

  @override
  String get classFormDescriptionArLabel => 'الوصف (بالعربية)';

  @override
  String get classFormCategoriesLabel => 'الفئات';

  @override
  String get classFormPriceLabel => 'السعر (EGP)';

  @override
  String get classFormDurationLabel => 'المدة (دقيقة)';

  @override
  String get classFormInstructorLabel => 'المدرب';

  @override
  String get classFormBranchLabel => 'الفرع / المسبح';

  @override
  String get classFormSelectCategoryError => 'يرجى اختيار فئة واحدة على الأقل';

  @override
  String get classFormSelectInstructorBranchError => 'يرجى اختيار مدرب وفرع';

  @override
  String classFormSaveError(String error) {
    return 'فشل الحفظ: $error';
  }

  @override
  String get instructorsTitle => 'المدربون';

  @override
  String get instructorsAddButton => 'إضافة مدرب';

  @override
  String get instructorsEmptyState => 'لا يوجد مدربون بعد.';

  @override
  String get instructorsViewScheduleTooltip => 'عرض الجدول';

  @override
  String get instructorsDeleteTitle => 'حذف المدرب؟';

  @override
  String instructorsDeleteContent(String name) {
    return 'لن يكون بإمكان تعيين \"$name\" للحصص أو الجلسات بعد الآن.';
  }

  @override
  String instructorScheduleTitle(String name) {
    return '$name — الجلسات القادمة';
  }

  @override
  String get instructorScheduleEmptyState => 'لا توجد جلسات قادمة.';

  @override
  String get instructorFormEditTitle => 'تعديل المدرب';

  @override
  String get instructorFormNameEnLabel => 'الاسم (بالإنجليزية)';

  @override
  String get instructorFormNameArLabel => 'الاسم (بالعربية)';

  @override
  String get instructorFormBioEnLabel => 'نبذة (بالإنجليزية)';

  @override
  String get instructorFormBioArLabel => 'نبذة (بالعربية)';

  @override
  String get instructorFormSpecialtiesLabel => 'التخصصات (مفصولة بفاصلة)';

  @override
  String instructorFormSaveError(String error) {
    return 'فشل الحفظ: $error';
  }

  @override
  String get calendarTitle => 'التقويم والحصص';

  @override
  String get calendarManageBlockedDates => 'إدارة التواريخ المحظورة';

  @override
  String get calendarBulkCreateRecurring => 'إنشاء حصص متكررة بالجملة';

  @override
  String get calendarAddSession => 'إضافة حصة';

  @override
  String get calendarDeleteSessionTitle => 'حذف الحصة؟';

  @override
  String get calendarDeleteSessionContent =>
      'هذا الإجراء لا يلغي الحجوزات الحالية ولا يُشعر العملاء الذين حجزوا بالفعل.';

  @override
  String get calendarBlockedDateBadge => 'تاريخ محظور';

  @override
  String get calendarNoSessionsOnDay => 'لا توجد حصص في هذا اليوم';

  @override
  String get calendarBranchLabel => 'الفرع';

  @override
  String get calendarAllBranchesOption => 'كل الفروع';

  @override
  String get calendarReasonLabel => 'السبب';

  @override
  String get calendarAdding => 'جارٍ الإضافة…';

  @override
  String get calendarAddBlockedDate => 'إضافة تاريخ محظور';

  @override
  String get calendarCurrentlyBlocked => 'التواريخ المحظورة حاليًا';

  @override
  String get calendarNoBlockedDates => 'لا توجد تواريخ محظورة';

  @override
  String get calendarUnblockDateTitle => 'إلغاء حظر هذا التاريخ؟';

  @override
  String calendarSessionBookedCount(int booked, int capacity) {
    return '$booked/$capacity محجوز';
  }

  @override
  String calendarSessionWaitlistedCount(int count) {
    return '$count في قائمة الانتظار';
  }

  @override
  String calendarDateLabel(String date) {
    return 'التاريخ: $date';
  }

  @override
  String calendarUnblockDateContent(String date) {
    return 'سيتمكن الموظفون من إنشاء حصص في $date مرة أخرى.';
  }

  @override
  String get sessionFormEditTitle => 'تعديل الحصة';

  @override
  String get sessionFormClassLabel => 'الفصل';

  @override
  String get sessionFormInstructorLabel => 'المدرب';

  @override
  String get sessionFormBranchPoolLabel => 'الفرع / المسبح';

  @override
  String get sessionFormCapacityLabel => 'السعة';

  @override
  String sessionFormSaveFailed(String error) {
    return 'فشل الحفظ: $error';
  }

  @override
  String sessionFormStartLabel(String time) {
    return 'البداية: $time';
  }

  @override
  String sessionFormEndLabel(String time) {
    return 'النهاية: $time';
  }

  @override
  String get recurringSessionTitle => 'إنشاء حصص متكررة بالجملة';

  @override
  String get recurringSessionMon => 'الإثنين';

  @override
  String get recurringSessionTue => 'الثلاثاء';

  @override
  String get recurringSessionWed => 'الأربعاء';

  @override
  String get recurringSessionThu => 'الخميس';

  @override
  String get recurringSessionFri => 'الجمعة';

  @override
  String get recurringSessionSat => 'السبت';

  @override
  String get recurringSessionSun => 'الأحد';

  @override
  String get recurringSessionCreating => 'جارٍ الإنشاء…';

  @override
  String get recurringSessionCreateButton => 'إنشاء الحصص';

  @override
  String recurringSessionFromLabel(String date) {
    return 'من: $date';
  }

  @override
  String recurringSessionToLabel(String date) {
    return 'إلى: $date';
  }

  @override
  String recurringSessionCreatedSnackbar(int count) {
    return 'تم إنشاء $count حصة';
  }

  @override
  String recurringSessionCreateFailed(String error) {
    return 'فشل إنشاء الحصص: $error';
  }

  @override
  String get categoriesTitle => 'الفئات';

  @override
  String get categoriesAddButton => 'إضافة فئة';

  @override
  String get categoriesEmptyState =>
      'لا توجد فئات بعد — أضف فئة لتمكين الأعضاء من تصفية الحصص.';

  @override
  String get categoriesDeleteTitle => 'حذف الفئة؟';

  @override
  String categoriesDeleteMessage(String name) {
    return 'لن تكون \"$name\" متاحة بعد الآن لتصنيف الحصص.';
  }

  @override
  String categoriesSaveFailed(String error) {
    return 'فشل الحفظ: $error';
  }

  @override
  String get categoriesAddTitle => 'إضافة فئة';

  @override
  String get categoriesEditTitle => 'تعديل الفئة';

  @override
  String get categoriesNameEnLabel => 'الاسم (إنجليزي)';

  @override
  String get categoriesNameArLabel => 'الاسم (عربي)';

  @override
  String get bannersTitle => 'البانرات';

  @override
  String get bannersAddButton => 'إضافة بانر';

  @override
  String get bannersEmptyState =>
      'لا توجد بانرات بعد — لن تظهر أي بانرات في الشاشة الرئيسية للتطبيق حتى تضيف واحدًا.';

  @override
  String get bannersDeleteTitle => 'حذف البانر؟';

  @override
  String bannersDeleteMessage(String title) {
    return 'سيتم إزالة \"$title\" من الشاشة الرئيسية للتطبيق.';
  }

  @override
  String bannersSaveFailed(String error) {
    return 'فشل الحفظ: $error';
  }

  @override
  String get bannersAddTitle => 'إضافة بانر';

  @override
  String get bannersEditTitle => 'تعديل البانر';

  @override
  String get bannersTitleEnLabel => 'العنوان (إنجليزي)';

  @override
  String get bannersTitleArLabel => 'العنوان (عربي)';

  @override
  String get bannersSubtitleEnLabel => 'العنوان الفرعي (إنجليزي)';

  @override
  String get bannersSubtitleArLabel => 'العنوان الفرعي (عربي)';

  @override
  String get bannersImageUrlLabel => 'رابط الصورة';

  @override
  String get bannersLinkActionLabel =>
      'إجراء الرابط (مثال: class:c1, packages)';

  @override
  String get bannersActiveDateRangeLabel => 'نطاق تاريخ التفعيل (اختياري)';

  @override
  String get bannersActiveFromLabel => 'نشط من';

  @override
  String get bannersActiveUntilLabel => 'نشط حتى';

  @override
  String get bannersNoLimitLabel => 'بلا حد';

  @override
  String get bannersClearDateTooltip => 'مسح';

  @override
  String get bannersPreviewLabel => 'معاينة';

  @override
  String get bannersPreviewTitlePlaceholder => 'عنوان البانر';

  @override
  String get bannersPreviewSubtitlePlaceholder => 'العنوان الفرعي للبانر';

  @override
  String get bannersPreviewActiveNote =>
      'سيظهر الآن في الشاشة الرئيسية للتطبيق';

  @override
  String get bannersPreviewInactiveNote =>
      'لن يظهر الآن (غير نشط أو خارج النطاق الزمني)';

  @override
  String get packagesTitle => 'الباقات والأسعار';

  @override
  String get packagesAddPackageTitle => 'إضافة باقة';

  @override
  String get packagesEditPackageTitle => 'تعديل الباقة';

  @override
  String get packagesEmptyState => 'لا توجد باقات بعد.';

  @override
  String get packagesPopularBadge => 'شائع';

  @override
  String get packagesUnlimitedLabel => 'غير محدود';

  @override
  String get packagesDeleteConfirmTitle => 'حذف الباقة؟';

  @override
  String packagesSessionsCount(int count) {
    return '$count حصة';
  }

  @override
  String packagesDaysCount(int count) {
    return '$count يوم';
  }

  @override
  String packagesPriceEgp(String price) {
    return '$price EGP';
  }

  @override
  String packagesDeleteConfirmMessage(String name) {
    return 'لن يكون بالإمكان شراء \"$name\" بعد الآن. الباقات المملوكة حاليًا لن تتأثر.';
  }

  @override
  String get packageFormNameEnLabel => 'الاسم (إنجليزي)';

  @override
  String get packageFormNameArLabel => 'الاسم (عربي)';

  @override
  String get packageFormDescriptionEnLabel => 'الوصف (إنجليزي)';

  @override
  String get packageFormDescriptionArLabel => 'الوصف (عربي)';

  @override
  String get packageFormTypeLabel => 'النوع';

  @override
  String get packageFormSessionCountLabel => 'عدد الحصص';

  @override
  String get packageFormValidityDaysLabel => 'مدة الصلاحية (أيام)';

  @override
  String get packageFormPriceLabel => 'السعر (EGP)';

  @override
  String get packageFormMarkAsPopularLabel => 'وضع علامة كباقة شائعة';

  @override
  String get packageFormMustBePositive => 'يجب أن تكون القيمة أكبر من 0';

  @override
  String packageFormSaveFailed(String error) {
    return 'فشل الحفظ: $error';
  }

  @override
  String get paymentsTitle => 'المدفوعات والتقارير';

  @override
  String get paymentsTotalRevenue => 'إجمالي الإيرادات';

  @override
  String get paymentsSuccessfulTransactions => 'المعاملات الناجحة';

  @override
  String get paymentsRevenueReportTitle => 'تقرير الإيرادات';

  @override
  String paymentsRevenueReportDescription(String otherClassLabel) {
    return 'آخر 6 أشهر، المعاملات الناجحة فقط. تصنيف الإيرادات حسب الفصل تقديري — يتم تجميع المعاملات غير المرتبطة بحجز (مثل المعاملات القديمة) تحت \"$otherClassLabel\".';
  }

  @override
  String get paymentsOtherClassLabel => 'أخرى / غير مرتبطة';

  @override
  String get paymentsFiltersTitle => 'التصفية';

  @override
  String get paymentsTransactionsTitle => 'المعاملات';

  @override
  String get paymentsFilterByDateRange => 'التصفية حسب النطاق الزمني';

  @override
  String paymentsDateRangeLabel(String start, String end) {
    return '$start إلى $end';
  }

  @override
  String get paymentsClearDateFilter => 'مسح تصفية التاريخ';

  @override
  String get paymentsClassLabel => 'الفصل';

  @override
  String get paymentsAllClasses => 'جميع الفصول';

  @override
  String get paymentsRefundConfirmTitle => 'استرداد هذه المعاملة؟';

  @override
  String paymentsRefundConfirmContent(
    String amount,
    String currency,
    String description,
  ) {
    return 'سيتم استرداد $amount $currency مقابل \"$description\". لا يمكن التراجع عن هذا الإجراء من هنا.';
  }

  @override
  String get paymentsRefund => 'استرداد';

  @override
  String get paymentsNoTransactions =>
      'لا توجد معاملات مطابقة للمرشحات الحالية.';

  @override
  String get paymentsRevenueByMonth => 'الإيرادات حسب الشهر';

  @override
  String get paymentsNoRevenuePeriod => 'لا توجد إيرادات في هذه الفترة.';

  @override
  String get paymentsRevenueByClass => 'الإيرادات حسب الفصل';

  @override
  String get paymentsStatusSucceeded => 'ناجحة';

  @override
  String get paymentsStatusFailed => 'فاشلة';

  @override
  String get paymentsStatusRefunded => 'مستردة';

  @override
  String get paymentsStatusPending => 'قيد الانتظار';

  @override
  String get paymentMethodsEmptyState =>
      'لا توجد طرق دفع بعد — أضف طريقة لعرضها عند الدفع.';

  @override
  String get paymentMethodFormAddTitle => 'إضافة طريقة دفع';

  @override
  String get paymentMethodFormEditTitle => 'تعديل طريقة الدفع';

  @override
  String get paymentMethodFormNameEnLabel => 'الاسم (إنجليزي)';

  @override
  String get paymentMethodFormNameArLabel => 'الاسم (عربي)';

  @override
  String get paymentMethodFormLogoUrlLabel => 'رابط الشعار';

  @override
  String get paymentMethodFormUrlHint => 'https://...';

  @override
  String get paymentMethodFormPaymentLinkLabel => 'رابط الدفع';

  @override
  String get paymentMethodFormPaymentLinkHelper =>
      'يتم فتحه عندما يضغط العميل على \"ادفع الآن\" عند الدفع';

  @override
  String get paymentMethodFormActiveSubtitle => 'يظهر للعملاء عند الدفع';

  @override
  String get reportsRefreshTooltip => 'تحديث';

  @override
  String get reportsBookings30d => 'الحجوزات (30 يومًا)';

  @override
  String get reportsAttendanceRate => 'معدل الحضور';

  @override
  String get reportsRevenue6mo => 'الإيرادات (6 أشهر)';

  @override
  String get reportsNewMembers6mo => 'أعضاء جدد (6 أشهر)';

  @override
  String get reportsBookingsTrendTitle => 'اتجاه الحجوزات (آخر 30 يومًا)';

  @override
  String get reportsBookingsTrendDescription =>
      'عدد الحجوزات التي تم إنشاؤها يوميًا.';

  @override
  String get reportsAttendanceDescription =>
      'الحجوزات المكتملة مقابل الملغاة (منذ البداية). تُعامل الحجوزات الملغاة على أنها عدم حضور — لا يتتبع هذا التطبيق علامة تغيّب منفصلة، لذا فإن هذا الرقم تقريبي.';

  @override
  String get reportsCompletedLabel => 'مكتمل';

  @override
  String get reportsPopularClassesAndTimesTitle =>
      'الفصول والأوقات الأكثر رواجًا';

  @override
  String get reportsPopularClassesTimesDescription =>
      'مرتبة حسب عدد الحجوزات خلال آخر 30 يومًا.';

  @override
  String get reportsTopClasses => 'أفضل الفصول';

  @override
  String get reportsPopularTimes => 'الأوقات الأكثر رواجًا';

  @override
  String get reportsNoBookingsInPeriod => 'لا توجد حجوزات في هذه الفترة.';

  @override
  String get reportsRevenueTrendTitle => 'اتجاه الإيرادات (آخر 6 أشهر)';

  @override
  String get reportsRevenueTrendDescription =>
      'مجموع المعاملات الناجحة، حسب الشهر.';

  @override
  String get reportsNoRevenueInPeriod => 'لا توجد إيرادات في هذه الفترة.';

  @override
  String get reportsMemberGrowthTitle => 'نمو الأعضاء (آخر 6 أشهر)';

  @override
  String get reportsMemberGrowthDescription =>
      'تسجيلات العملاء الجدد، حسب الشهر.';

  @override
  String get reportsNoNewMembersInPeriod => 'لا يوجد أعضاء جدد في هذه الفترة.';

  @override
  String get reportsMonthJan => 'يناير';

  @override
  String get reportsMonthFeb => 'فبراير';

  @override
  String get reportsMonthMar => 'مارس';

  @override
  String get reportsMonthApr => 'أبريل';

  @override
  String get reportsMonthMay => 'مايو';

  @override
  String get reportsMonthJun => 'يونيو';

  @override
  String get reportsMonthJul => 'يوليو';

  @override
  String get reportsMonthAug => 'أغسطس';

  @override
  String get reportsMonthSep => 'سبتمبر';

  @override
  String get reportsMonthOct => 'أكتوبر';

  @override
  String get reportsMonthNov => 'نوفمبر';

  @override
  String get reportsMonthDec => 'ديسمبر';

  @override
  String reportsFailedToLoad(String error) {
    return 'فشل تحميل التقارير: $error';
  }

  @override
  String reportsCompletedCount(int count) {
    return 'مكتمل: $count';
  }

  @override
  String reportsCancelledCount(int count) {
    return 'ملغى: $count';
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
  String get membersTitle => 'الأعضاء';

  @override
  String get membersSearchHint => 'البحث بالاسم أو البريد الإلكتروني';

  @override
  String get membersNoResults => 'لم يتم العثور على أعضاء.';

  @override
  String get membersReactivate => 'إعادة تفعيل';

  @override
  String get membersSuspend => 'إيقاف';

  @override
  String membersFamilyMembersCount(int count) {
    return 'أفراد العائلة ($count)';
  }

  @override
  String membersBookingsCount(int count) {
    return 'الحجوزات ($count)';
  }

  @override
  String membersPaymentHistoryCount(int count) {
    return 'سجل المدفوعات ($count)';
  }

  @override
  String get membersNoPayments => 'لا توجد مدفوعات بعد.';

  @override
  String get membersEditProfile => 'تعديل الملف الشخصي';

  @override
  String get membersNoDescription => '(بدون وصف)';

  @override
  String get membersAwardBadge => 'منح شارة';

  @override
  String get membersAddProgressNoteAction => 'إضافة ملاحظة تقدم';

  @override
  String get membersAward => 'منح';

  @override
  String get membersNameLabel => 'الاسم';

  @override
  String get membersPhoneLabel => 'الهاتف';

  @override
  String get membersTitleEnLabel => 'العنوان (إنجليزي)';

  @override
  String get membersTitleArLabel => 'العنوان (عربي)';

  @override
  String get membersIconNameLabel =>
      'اسم الأيقونة (Material، مثال: emoji_events)';

  @override
  String get membersNoteEnLabel => 'ملاحظة (إنجليزي)';

  @override
  String get membersNoteArLabel => 'ملاحظة (عربي)';

  @override
  String get membersInstructorNameLabel => 'اسم المدرب';

  @override
  String membersFailedToSave(String error) {
    return 'فشل الحفظ: $error';
  }

  @override
  String membersBadgesLabel(String badges) {
    return 'الشارات: $badges';
  }

  @override
  String membersProgressNotesCount(int count) {
    return '$count ملاحظة تقدم';
  }

  @override
  String membersFamilyMemberAge(String name, int age) {
    return '$name ($age سنة)';
  }

  @override
  String get notificationsTitle => 'مركز الإشعارات';

  @override
  String get notificationsComposeBroadcast => 'إنشاء بث';

  @override
  String notificationsFailedToLoad(String error) {
    return 'فشل تحميل البثوث: $error';
  }

  @override
  String get notificationsEmptyState => 'لم يتم إرسال أي بث بعد.';

  @override
  String get notificationsSegmentExpiringPackage => 'باقة تنتهي هذا الأسبوع';

  @override
  String get notificationsSegmentNoBooking => 'لا يوجد حجز خلال آخر 30 يومًا';

  @override
  String notificationsTargetSegmentDesc(String segment) {
    return 'الفئة: $segment';
  }

  @override
  String get notificationsTargetSingleUser => 'مستخدم واحد';

  @override
  String get notificationsTargetAllUsers => 'جميع المستخدمين';

  @override
  String get notificationsTargetSegmentOption => 'الفئة';

  @override
  String notificationsBodyTargetLine(String body, String target) {
    return '$body · الهدف: $target';
  }

  @override
  String notificationsScheduledFor(String date) {
    return 'مجدول لـ $date';
  }

  @override
  String get notificationsLoadingStats => 'جارٍ تحميل إحصاءات التسليم…';

  @override
  String notificationsFailedToLoadStats(String error) {
    return 'فشل تحميل إحصاءات التسليم: $error';
  }

  @override
  String notificationsDeliveryStats(int delivered, int read) {
    return 'تم التسليم: $delivered · تمت القراءة: $read';
  }

  @override
  String get notificationsStatusDraft => 'مسودة';

  @override
  String get notificationsStatusScheduled => 'مجدولة';

  @override
  String get notificationsStatusSent => 'تم الإرسال';

  @override
  String get notificationsRequiredFieldsError =>
      'العنوان (إنجليزي) والرسالة (إنجليزي) مطلوبان.';

  @override
  String get notificationsPickMemberError => 'اختر عضوًا لاستهدافه.';

  @override
  String notificationsFailedToSend(String error) {
    return 'فشل الإرسال: $error';
  }

  @override
  String get notificationsTitleEnLabel => 'العنوان (إنجليزي)';

  @override
  String get notificationsTitleArLabel => 'العنوان (عربي)';

  @override
  String get notificationsMessageEnLabel => 'الرسالة (إنجليزي)';

  @override
  String get notificationsMessageArLabel => 'الرسالة (عربي)';

  @override
  String get notificationsTargetLabel => 'الهدف';

  @override
  String get notificationsSearchMemberLabel =>
      'البحث عن عضو بالاسم أو البريد الإلكتروني';

  @override
  String notificationsSelectedMember(String name) {
    return 'المحدد: $name';
  }

  @override
  String get notificationsScheduleForLater => 'الجدولة لوقت لاحق';

  @override
  String get notificationsScheduleOffHint => 'إيقاف = الإرسال فورًا';

  @override
  String get notificationsSending => 'جارٍ الإرسال…';

  @override
  String get notificationsScheduleButton => 'جدولة';

  @override
  String get notificationsSendButton => 'إرسال';

  @override
  String get settingsSaveChangesButton => 'حفظ التغييرات';

  @override
  String get settingsSavedMessage => 'تم حفظ الإعدادات';

  @override
  String settingsSaveFailedMessage(String error) {
    return 'فشل الحفظ: $error';
  }

  @override
  String get settingsBrandingSection => 'العلامة التجارية';

  @override
  String get settingsPrimaryColorLabel => 'اللون الأساسي (hex)';

  @override
  String get settingsLogoUrlLabel => 'رابط الشعار';

  @override
  String get settingsContactSupportSection => 'التواصل والدعم';

  @override
  String get settingsWhatsappNumberLabel => 'رقم واتساب (مثال: +966500000000)';

  @override
  String get settingsContactEmailLabel => 'البريد الإلكتروني للتواصل';

  @override
  String get settingsTermsUrlLabel => 'رابط الشروط والأحكام';

  @override
  String get settingsPrivacyUrlLabel => 'رابط سياسة الخصوصية';

  @override
  String get settingsFaqEnglishSection => 'الأسئلة الشائعة (بالإنجليزية)';

  @override
  String get settingsFaqArabicSection => 'الأسئلة الشائعة (بالعربية)';

  @override
  String get settingsFaqQuestionLabel => 'السؤال';

  @override
  String get settingsFaqAnswerLabel => 'الإجابة';

  @override
  String get settingsFaqNewQuestion => 'سؤال جديد';

  @override
  String get settingsFaqNewAnswer => 'إجابة جديدة';

  @override
  String get staffTitle => 'حسابات الموظفين والصلاحيات';

  @override
  String get staffGrantAccessButton => 'منح الصلاحية';

  @override
  String get staffAdminOnlyNotice =>
      'يمكن للمشرفين فقط منح أو إلغاء صلاحية الوصول للوحة التحكم.';

  @override
  String get staffEmptyState => 'لا يوجد حسابات موظفين أو مشرفين بعد.';

  @override
  String get staffRevokeTooltip => 'إلغاء الصلاحية وتحويل إلى عميل';

  @override
  String get staffRevokeDialogTitle =>
      'هل تريد إلغاء صلاحية الوصول للوحة التحكم؟';

  @override
  String staffRevokeDialogContent(String name) {
    return 'سيفقد $name صلاحية الموظف/المشرف ويصبح عميلاً عادياً.';
  }

  @override
  String get staffRevokeButton => 'إلغاء الصلاحية';

  @override
  String staffRevokeFailedMessage(String error) {
    return 'فشل إلغاء الصلاحية: $error';
  }

  @override
  String get staffGrantDialogTitle => 'منح صلاحية الوصول للوحة التحكم';

  @override
  String get staffUserUidLabel =>
      'معرف المستخدم (UID) (من شاشة الأعضاء / Auth)';

  @override
  String get staffRoleLabel => 'الدور';

  @override
  String get staffRoleStaff => 'موظف';

  @override
  String get staffRoleAdmin => 'مشرف';

  @override
  String get staffGranting => 'جارٍ المنح…';

  @override
  String get staffGrantButton => 'منح';

  @override
  String staffGrantFailedMessage(String error) {
    return 'فشل منح الصلاحية: $error';
  }
}
