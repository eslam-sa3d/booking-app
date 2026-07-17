/// Route paths restricted to `admin`, excluded from `staff` — per the build
/// spec's explicit example: "requests + calendar, not payments/reports or
/// staff accounts". App Content & Settings is grouped in with them since it
/// controls branding/legal content and (via /staff) account privileges,
/// both admin-level concerns; everything else is staff+admin.
const adminOnlyPaths = {'/payments', '/payment-methods', '/reports', '/settings', '/staff'};

bool isPathAdminOnly(String path) => adminOnlyPaths.any((p) => path.startsWith(p));
