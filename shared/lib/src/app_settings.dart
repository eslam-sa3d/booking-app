class FaqEntry {
  final String question;
  final String answer;
  const FaqEntry({required this.question, required this.answer});

  Map<String, dynamic> toMap() => {'question': question, 'answer': answer};

  factory FaqEntry.fromMap(Map<String, dynamic> map) =>
      FaqEntry(question: map['question'] as String? ?? '', answer: map['answer'] as String? ?? '');
}

/// appSettings/config — singleton doc, staff/admin-editable, drives the
/// mobile app's Settings/Support/FAQ screens.
class AppSettings {
  final String brandPrimaryColorHex;
  final String? logoUrl;
  final List<FaqEntry> faqEn;
  final List<FaqEntry> faqAr;
  final String? termsUrl;
  final String? privacyUrl;
  final String? whatsappNumber;
  final String? contactEmail;

  const AppSettings({
    this.brandPrimaryColorHex = '#0EA5A4',
    this.logoUrl,
    this.faqEn = const [],
    this.faqAr = const [],
    this.termsUrl,
    this.privacyUrl,
    this.whatsappNumber,
    this.contactEmail,
  });

  AppSettings copyWith({
    String? brandPrimaryColorHex,
    String? logoUrl,
    List<FaqEntry>? faqEn,
    List<FaqEntry>? faqAr,
    String? termsUrl,
    String? privacyUrl,
    String? whatsappNumber,
    String? contactEmail,
  }) {
    return AppSettings(
      brandPrimaryColorHex: brandPrimaryColorHex ?? this.brandPrimaryColorHex,
      logoUrl: logoUrl ?? this.logoUrl,
      faqEn: faqEn ?? this.faqEn,
      faqAr: faqAr ?? this.faqAr,
      termsUrl: termsUrl ?? this.termsUrl,
      privacyUrl: privacyUrl ?? this.privacyUrl,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      contactEmail: contactEmail ?? this.contactEmail,
    );
  }

  Map<String, dynamic> toMap() => {
        'brandPrimaryColorHex': brandPrimaryColorHex,
        'logoUrl': logoUrl,
        'faqEn': faqEn.map((f) => f.toMap()).toList(),
        'faqAr': faqAr.map((f) => f.toMap()).toList(),
        'termsUrl': termsUrl,
        'privacyUrl': privacyUrl,
        'whatsappNumber': whatsappNumber,
        'contactEmail': contactEmail,
      };

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
        brandPrimaryColorHex: map['brandPrimaryColorHex'] as String? ?? '#0EA5A4',
        logoUrl: map['logoUrl'] as String?,
        faqEn: ((map['faqEn'] as List?) ?? [])
            .map((f) => FaqEntry.fromMap(Map<String, dynamic>.from(f as Map)))
            .toList(),
        faqAr: ((map['faqAr'] as List?) ?? [])
            .map((f) => FaqEntry.fromMap(Map<String, dynamic>.from(f as Map)))
            .toList(),
        termsUrl: map['termsUrl'] as String?,
        privacyUrl: map['privacyUrl'] as String?,
        whatsappNumber: map['whatsappNumber'] as String?,
        contactEmail: map['contactEmail'] as String?,
      );
}
