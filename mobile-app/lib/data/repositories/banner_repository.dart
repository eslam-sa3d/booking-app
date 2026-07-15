import '../models/models.dart';

abstract class BannerRepository {
  Future<List<PromoBanner>> getActiveBanners();
}
