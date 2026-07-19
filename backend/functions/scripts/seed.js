// Seeds the Firebase emulators with a first admin account and demo CMS
// content (branches, instructors, classes, sessions, packages, banners,
// app settings) so the admin dashboard and mobile app have real data to
// work against locally. Run with the emulators already running:
//   node scripts/seed.js
const admin = require("firebase-admin");

// Defaults to the safe "demo-" emulator project (the "demo-" prefix makes
// the Admin SDK refuse to touch real infrastructure even with no real
// credentials). Override with FIREBASE_PROJECT_ID=<real-project-id> to seed
// a real deployed project instead — picks up credentials the normal way,
// via `gcloud auth application-default login` or a
// GOOGLE_APPLICATION_CREDENTIALS service-account key.
const projectId = process.env.FIREBASE_PROJECT_ID || "demo-swim-academy";
admin.initializeApp({ projectId });
const db = admin.firestore();
const auth = admin.auth();

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function ensureAdmin() {
  const email = "admin@swimacademy.test";
  const password = "admin123456";
  let user;
  let isNewUser = false;
  try {
    user = await auth.getUserByEmail(email);
  } catch {
    user = await auth.createUser({ email, password, displayName: "Admin" });
    isNewUser = true;
  }

  if (isNewUser) {
    // Creating a user fires the onUserCreate Cloud Function trigger
    // asynchronously, which sets role: 'customer' and writes the
    // Firestore profile — it isn't awaited by createUser() above, so
    // setting our admin claim immediately would race it and could get
    // silently overwritten back to 'customer'. Wait for the trigger's
    // Firestore write to land (proof it already ran its claim write)
    // before setting the real admin claim, so ours applies last.
    for (let attempt = 0; attempt < 20; attempt++) {
      const doc = await db.collection("users").doc(user.uid).get();
      if (doc.exists) break;
      await sleep(300);
    }
  }

  await auth.setCustomUserClaims(user.uid, { role: "admin" });
  await db.collection("users").doc(user.uid).set(
    {
      id: user.uid,
      name: "Admin",
      email,
      phone: "",
      preferredLanguage: "en",
      role: "admin",
      suspended: false,
      notificationPreferences: { reminders: true, promotions: true, announcements: true },
      createdAt: admin.firestore.Timestamp.now(),
    },
    { merge: true }
  );
  console.log(`Admin ready: ${email} / ${password} (uid ${user.uid})`);
  return user.uid;
}

async function seedContent(adminUid) {
  const categories = [
    { id: "kids", nameEn: "Kids", nameAr: "أطفال", order: 0 },
    { id: "adults", nameEn: "Adults", nameAr: "بالغون", order: 1 },
    { id: "beginner", nameEn: "Beginner", nameAr: "مبتدئ", order: 2 },
    { id: "intermediate", nameEn: "Intermediate", nameAr: "متوسط", order: 3 },
    { id: "advanced", nameEn: "Advanced", nameAr: "متقدم", order: 4 },
    { id: "private", nameEn: "Private", nameAr: "خاص", order: 5 },
    { id: "ladiesOnly", nameEn: "Ladies-only", nameAr: "نسائي فقط", order: 6 },
  ];
  const branches = [
    { id: "b1", name: "Al Olaya Aquatic Center", nameAr: "نادي العليا المائي", address: "Al Olaya, Riyadh", addressAr: "العليا، الرياض", imageAsset: "" },
    { id: "b2", name: "Jeddah Corniche Pool", nameAr: "مسبح كورنيش جدة", address: "Corniche Road, Jeddah", addressAr: "طريق الكورنيش، جدة", imageAsset: "" },
  ];
  const instructors = [
    { id: "i1", name: "Sarah Al-Otaibi", nameAr: "سارة العتيبي", bio: "Ladies-only & kids specialist.", bioAr: "متخصصة في الحصص النسائية والأطفال.", rating: 4.9, specialties: ["Ladies-only", "Kids"] },
    { id: "i2", name: "Mohammed Al-Harbi", nameAr: "محمد الحربي", bio: "Former national team, adults & private.", bioAr: "عضو سابق في المنتخب الوطني.", rating: 4.8, specialties: ["Adults", "Private"] },
  ];
  const classes = [
    {
      id: "c1", title: "Kids Beginner Splash", titleAr: "سباحة الأطفال للمبتدئين",
      description: "Water safety and basic strokes for ages 4-8.", descriptionAr: "السلامة في الماء والحركات الأساسية.",
      categories: ["kids", "beginner"], durationMinutes: 45, price: 150, currency: "EGP",
      instructorId: "i1", branchId: "b1", rating: 4.9, reviewCount: 12, heroColorHex: "#0EA5A4", heroIcon: "child_friendly",
    },
    {
      id: "c2", title: "Adult Advanced Techniques", titleAr: "تقنيات متقدمة للكبار",
      description: "Stroke refinement with a former national coach.", descriptionAr: "تطوير تقنية السباحة مع مدرب سابق.",
      categories: ["adults", "advanced"], durationMinutes: 60, price: 220, currency: "EGP",
      instructorId: "i2", branchId: "b2", rating: 4.8, reviewCount: 6, heroColorHex: "#1E293B", heroIcon: "bolt",
    },
  ];
  const packages = [
    { id: "p1", name: "8-Session Pack", nameAr: "باقة 8 حصص", description: "Use across any class within 60 days.", descriptionAr: "استخدمها في أي حصة خلال 60 يوماً.", type: "sessionPack", sessionCount: 8, validityDays: 60, price: 1100, currency: "EGP", isPopular: false },
    { id: "p2", name: "Monthly Unlimited", nameAr: "اشتراك شهري مفتوح", description: "Unlimited group sessions for 30 days.", descriptionAr: "حصص جماعية غير محدودة لمدة 30 يوماً.", type: "monthlyUnlimited", sessionCount: null, validityDays: 30, price: 1400, currency: "EGP", isPopular: true },
  ];
  const banners = [
    { id: "bn1", title: "Summer offer: 20% off", titleAr: "عرض الصيف: خصم 20%", subtitle: "On Monthly Unlimited packages", subtitleAr: "على باقات الاشتراك الشهري", imageUrl: "", linkAction: "packages", order: 0, isActive: true },
  ];

  const batch = db.batch();
  for (const cat of categories) batch.set(db.collection("categories").doc(cat.id), { ...cat, updatedBy: adminUid });
  for (const b of branches) batch.set(db.collection("branches").doc(b.id), b);
  for (const i of instructors) batch.set(db.collection("instructors").doc(i.id), { ...i, updatedBy: adminUid });
  for (const c of classes) batch.set(db.collection("classes").doc(c.id), { ...c, updatedBy: adminUid });
  for (const p of packages) batch.set(db.collection("packages").doc(p.id), { ...p, updatedBy: adminUid });
  for (const bn of banners) batch.set(db.collection("banners").doc(bn.id), { ...bn, updatedBy: adminUid });
  batch.set(db.collection("appSettings").doc("config"), {
    brandPrimaryColorHex: "#0EA5A4",
    logoUrl: null,
    faqEn: [{ question: "How do I book a class?", answer: "Browse Home or Calendar, pick a slot, and confirm." }],
    faqAr: [{ question: "كيف أحجز حصة؟", answer: "تصفح الرئيسية أو التقويم واختر موعداً ثم أكّد." }],
    termsUrl: null,
    privacyUrl: null,
    whatsappNumber: "+966500000000",
    contactEmail: "support@swimacademy.test",
    updatedBy: adminUid,
  });
  await batch.commit();

  // Recurring sessions for the next 21 days.
  const sessionTemplates = [
    { classId: "c1", weekday: 2, startMinutes: 960, capacity: 10 }, // Tuesday 16:00
    { classId: "c1", weekday: 4, startMinutes: 960, capacity: 10 }, // Thursday 16:00
    { classId: "c2", weekday: 1, startMinutes: 1200, capacity: 8 }, // Monday 20:00
  ];
  const durationByClass = { c1: 45, c2: 60 };
  const sessionsBatch = db.batch();
  const today = new Date();
  for (let i = 0; i < 21; i++) {
    const date = new Date(today.getFullYear(), today.getMonth(), today.getDate() + i);
    for (const t of sessionTemplates) {
      if (date.getDay() === 0 ? 7 : date.getDay()) {
        const isoWeekday = date.getDay() === 0 ? 7 : date.getDay();
        if (isoWeekday !== t.weekday) continue;
        const classDef = classes.find((c) => c.id === t.classId);
        const ref = db.collection("sessions").doc();
        sessionsBatch.set(ref, {
          id: ref.id,
          classId: t.classId,
          date: admin.firestore.Timestamp.fromDate(date),
          startMinutes: t.startMinutes,
          endMinutes: t.startMinutes + durationByClass[t.classId],
          capacity: t.capacity,
          bookedCount: 0,
          waitlistCount: 0,
          instructorId: classDef.instructorId,
          branchId: classDef.branchId,
        });
      }
    }
  }
  await sessionsBatch.commit();
  console.log("Seeded categories, branches, instructors, classes, sessions, packages, banners, app settings.");
}

async function main() {
  const adminUid = await ensureAdmin();
  await seedContent(adminUid);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("SEED FAILED:", err);
    process.exit(1);
  });
