import '../models/models.dart';

abstract class BannerRepository {
  Future<List<PromoBanner>> getActiveBanners();

  /// Real-time variant of [getActiveBanners] — emits a new list whenever the
  /// underlying banner data changes, so the home carousel stays in sync
  /// without requiring a manual refresh. Same filtering/ordering as
  /// [getActiveBanners].
  Stream<List<PromoBanner>> watchActiveBanners();
}
