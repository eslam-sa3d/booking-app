import '../../models/models.dart';

/// Static in-memory seed data shared by every Mock*Repository.
///
/// This is the single place to swap for a real backend later: replace the
/// getters below with Firestore/REST calls and every repository/provider
/// built on top keeps working unchanged.
class MockSeedData {
  MockSeedData._();

  static final List<Branch> branches = [
    const Branch(
      id: 'b1',
      name: 'Al Olaya Aquatic Center',
      nameAr: 'نادي العليا المائي',
      address: 'Al Olaya, Riyadh',
      addressAr: 'العليا، الرياض',
    ),
    const Branch(
      id: 'b2',
      name: 'Jeddah Corniche Pool',
      nameAr: 'مسبح كورنيش جدة',
      address: 'Corniche Road, Jeddah',
      addressAr: 'طريق الكورنيش، جدة',
    ),
  ];

  static final List<Instructor> instructors = [
    const Instructor(
      id: 'i1',
      name: 'Sarah Al-Otaibi',
      nameAr: 'سارة العتيبي',
      bio: 'Certified swim coach specializing in ladies-only and kids beginner classes, 8 years experience.',
      bioAr: 'مدربة سباحة معتمدة متخصصة في الحصص النسائية وحصص الأطفال المبتدئين، خبرة 8 سنوات.',
      rating: 4.9,
      specialties: ['Ladies-only', 'Kids', 'Beginner'],
    ),
    const Instructor(
      id: 'i2',
      name: 'Mohammed Al-Harbi',
      nameAr: 'محمد الحربي',
      bio: 'Former national swim team member, now coaching adults and private lessons.',
      bioAr: 'عضو سابق في منتخب السباحة الوطني، يدرب حالياً حصص الكبار والحصص الخاصة.',
      rating: 4.8,
      specialties: ['Adults', 'Advanced', 'Private'],
    ),
    const Instructor(
      id: 'i3',
      name: 'Lina Youssef',
      nameAr: 'لينا يوسف',
      bio: 'Loves teaching kids to swim with fun, safety-first methods.',
      bioAr: 'تحب تعليم الأطفال السباحة بأساليب ممتعة تركز على السلامة أولاً.',
      rating: 4.9,
      specialties: ['Kids', 'Beginner'],
    ),
    const Instructor(
      id: 'i4',
      name: 'Omar Al-Zahrani',
      nameAr: 'عمر الزهراني',
      bio: 'Focuses on stroke correction and building confidence in intermediate swimmers.',
      bioAr: 'يركز على تصحيح الحركات وبناء الثقة لدى السباحين متوسطي المستوى.',
      rating: 4.7,
      specialties: ['Intermediate', 'Adults'],
    ),
    const Instructor(
      id: 'i5',
      name: 'Fatima Al-Qahtani',
      nameAr: 'فاطمة القحطاني',
      bio: 'Specializes in ladies-only fitness swimming and private coaching.',
      bioAr: 'متخصصة في السباحة النسائية اللياقية والتدريب الخاص.',
      rating: 4.8,
      specialties: ['Ladies-only', 'Private'],
    ),
  ];

  static final List<SwimClass> classes = [
    const SwimClass(
      id: 'c1',
      title: 'Kids Beginner Splash',
      titleAr: 'سباحة الأطفال للمبتدئين',
      description:
          'A gentle introduction to water safety and basic strokes for children ages 4-8, in a fun, encouraging environment.',
      descriptionAr: 'مقدمة لطيفة للسلامة في الماء والحركات الأساسية للأطفال من سن 4-8 سنوات في بيئة ممتعة ومشجعة.',
      categories: [ClassCategory.kids, ClassCategory.beginner],
      durationMinutes: 45,
      price: 150,
      instructorId: 'i3',
      branchId: 'b1',
      rating: 4.9,
      reviewCount: 128,
      heroColorHex: '#0EA5A4',
      heroIcon: 'child_friendly',
    ),
    const SwimClass(
      id: 'c2',
      title: 'Kids Level Up',
      titleAr: 'تطوير مهارات الأطفال',
      description: 'For kids who can already float and kick — building toward independent freestyle and backstroke.',
      descriptionAr: 'للأطفال الذين يستطيعون الطفو والركل بالفعل، لتطوير السباحة الحرة والظهر بشكل مستقل.',
      categories: [ClassCategory.kids, ClassCategory.intermediate],
      durationMinutes: 45,
      price: 160,
      instructorId: 'i3',
      branchId: 'b1',
      rating: 4.8,
      reviewCount: 76,
      heroColorHex: '#2563EB',
      heroIcon: 'emoji_events',
    ),
    const SwimClass(
      id: 'c3',
      title: 'Adult Beginner Swim',
      titleAr: 'سباحة الكبار للمبتدئين',
      description: 'Never learned to swim? Start here — water confidence, floating, and basic strokes for adults.',
      descriptionAr: 'لم تتعلم السباحة من قبل؟ ابدأ هنا: الثقة في الماء، الطفو، والحركات الأساسية للكبار.',
      categories: [ClassCategory.adults, ClassCategory.beginner],
      durationMinutes: 60,
      price: 180,
      instructorId: 'i2',
      branchId: 'b1',
      rating: 4.7,
      reviewCount: 54,
      heroColorHex: '#0EA5A4',
      heroIcon: 'pool',
    ),
    const SwimClass(
      id: 'c4',
      title: 'Adult Advanced Techniques',
      titleAr: 'تقنيات متقدمة للكبار',
      description: 'Refine your stroke technique, endurance, and speed with a former national team coach.',
      descriptionAr: 'طوّر تقنية السباحة والتحمل والسرعة مع مدرب سابق في المنتخب الوطني.',
      categories: [ClassCategory.adults, ClassCategory.advanced],
      durationMinutes: 60,
      price: 220,
      instructorId: 'i2',
      branchId: 'b2',
      rating: 4.9,
      reviewCount: 41,
      heroColorHex: '#1E293B',
      heroIcon: 'bolt',
    ),
    const SwimClass(
      id: 'c5',
      title: 'Ladies-Only Morning Swim',
      titleAr: 'سباحة صباحية نسائية',
      description: 'A relaxed, women-only session focused on water confidence and fitness in a private setting.',
      descriptionAr: 'حصة نسائية هادئة تركز على الثقة في الماء واللياقة في بيئة خاصة.',
      categories: [ClassCategory.ladiesOnly, ClassCategory.beginner],
      durationMinutes: 60,
      price: 190,
      instructorId: 'i1',
      branchId: 'b1',
      rating: 5.0,
      reviewCount: 63,
      heroColorHex: '#DB2777',
      heroIcon: 'favorite',
    ),
    const SwimClass(
      id: 'c6',
      title: 'Ladies-Only Fitness Swim',
      titleAr: 'سباحة لياقة نسائية',
      description: 'High-energy lap swimming for women looking to build fitness and stamina.',
      descriptionAr: 'سباحة عالية الطاقة للنساء الراغبات في بناء اللياقة والتحمل.',
      categories: [ClassCategory.ladiesOnly, ClassCategory.intermediate],
      durationMinutes: 60,
      price: 200,
      instructorId: 'i5',
      branchId: 'b2',
      rating: 4.8,
      reviewCount: 37,
      heroColorHex: '#DB2777',
      heroIcon: 'favorite',
    ),
    const SwimClass(
      id: 'c7',
      title: 'Private 1-on-1 Coaching',
      titleAr: 'تدريب خاص فردي',
      description: 'Fully personalized coaching session tailored to your goals, at your pace.',
      descriptionAr: 'حصة تدريب مخصصة بالكامل تناسب أهدافك وسرعتك الخاصة.',
      categories: [ClassCategory.private, ClassCategory.advanced],
      durationMinutes: 45,
      price: 350,
      instructorId: 'i2',
      branchId: 'b2',
      rating: 5.0,
      reviewCount: 29,
      heroColorHex: '#7C3AED',
      heroIcon: 'star',
    ),
    const SwimClass(
      id: 'c8',
      title: 'Intermediate Stroke Clinic',
      titleAr: 'ورشة تصحيح الحركات',
      description: 'Small-group clinic focused on correcting technique for freestyle, backstroke, and breaststroke.',
      descriptionAr: 'ورشة عمل لمجموعات صغيرة تركز على تصحيح حركات السباحة الحرة والظهر والصدر.',
      categories: [ClassCategory.intermediate, ClassCategory.adults],
      durationMinutes: 60,
      price: 200,
      instructorId: 'i4',
      branchId: 'b2',
      rating: 4.6,
      reviewCount: 22,
      heroColorHex: '#2563EB',
      heroIcon: 'waves',
    ),
  ];

  static final List<SwimPackage> packages = [
    const SwimPackage(
      id: 'p1',
      name: '8-Session Pack',
      nameAr: 'باقة 8 حصص',
      description: 'Use across any class within 60 days. Great for trying different sessions.',
      descriptionAr: 'استخدمها في أي حصة خلال 60 يوماً. مثالية لتجربة حصص مختلفة.',
      type: PackageType.sessionPack,
      sessionCount: 8,
      validityDays: 60,
      price: 1100,
    ),
    const SwimPackage(
      id: 'p2',
      name: 'Monthly Unlimited',
      nameAr: 'اشتراك شهري مفتوح',
      description: 'Unlimited group sessions for 30 days. Best value for regular swimmers.',
      descriptionAr: 'حصص جماعية غير محدودة لمدة 30 يوماً. الأفضل للسباحين المنتظمين.',
      type: PackageType.monthlyUnlimited,
      validityDays: 30,
      price: 1400,
      isPopular: true,
    ),
    const SwimPackage(
      id: 'p3',
      name: 'Private Lessons Pack',
      nameAr: 'باقة الدروس الخاصة',
      description: '5 one-on-one private coaching sessions with the instructor of your choice.',
      descriptionAr: '5 حصص تدريب خاصة فردية مع المدرب الذي تختاره.',
      type: PackageType.privateLessons,
      sessionCount: 5,
      validityDays: 90,
      price: 1650,
    ),
    const SwimPackage(
      id: 'p4',
      name: '4-Session Starter Pack',
      nameAr: 'باقة البداية 4 حصص',
      description: 'A short pack to get started, valid for 30 days.',
      descriptionAr: 'باقة قصيرة للبدء، صالحة لمدة 30 يوماً.',
      type: PackageType.sessionPack,
      sessionCount: 4,
      validityDays: 30,
      price: 600,
    ),
  ];

  /// weekday (1=Mon..7=Sun) -> startMinutes, capacity, per class id
  static final Map<String, List<_SessionTemplate>> _sessionTemplates = {
    'c1': [_SessionTemplate(2, 16 * 60, 10), _SessionTemplate(4, 16 * 60, 10)],
    'c2': [_SessionTemplate(2, 17 * 60, 8), _SessionTemplate(4, 17 * 60, 8)],
    'c3': [_SessionTemplate(1, 19 * 60, 12), _SessionTemplate(3, 19 * 60, 12)],
    'c4': [_SessionTemplate(1, 20 * 60, 8), _SessionTemplate(6, 9 * 60, 8)],
    'c5': [_SessionTemplate(7, 9 * 60, 10), _SessionTemplate(2, 9 * 60, 10)],
    'c6': [_SessionTemplate(6, 10 * 60, 8), _SessionTemplate(3, 18 * 60, 8)],
    'c7': [_SessionTemplate(5, 15 * 60, 1), _SessionTemplate(7, 15 * 60, 1)],
    'c8': [_SessionTemplate(5, 17 * 60, 6), _SessionTemplate(2, 20 * 60, 6)],
  };

  /// Generates rolling sessions for the next [days] days for every class.
  /// Regenerated fresh (deterministic per-day booked counts) each time it's
  /// called so the calendar always has upcoming slots relative to "today".
  static List<SwimSession> generateSessions({int days = 28}) {
    final sessions = <SwimSession>[];
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    for (final entry in _sessionTemplates.entries) {
      final classId = entry.key;
      final swimClass = classes.firstWhere((c) => c.id == classId);
      for (final template in entry.value) {
        for (int i = 0; i < days; i++) {
          final date = startOfToday.add(Duration(days: i));
          if (date.weekday != template.weekday) continue;
          final dateSeed = date.day + date.month * 31 + classId.hashCode;
          final bookedCount = (dateSeed % (template.capacity + 3)).clamp(0, template.capacity);
          sessions.add(
            SwimSession(
              id: '${classId}_${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}_${template.startMinutes}',
              classId: classId,
              date: date,
              startMinutes: template.startMinutes,
              endMinutes: template.startMinutes + swimClass.durationMinutes,
              capacity: template.capacity,
              bookedCount: bookedCount,
              instructorId: swimClass.instructorId,
              branchId: swimClass.branchId,
            ),
          );
        }
      }
    }
    sessions.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return sessions;
  }
}

class _SessionTemplate {
  final int weekday;
  final int startMinutes;
  final int capacity;
  const _SessionTemplate(this.weekday, this.startMinutes, this.capacity);
}
