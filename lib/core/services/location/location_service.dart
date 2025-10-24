import 'package:universal_go/core/utils/lat_lng.dart';

abstract class LocationService {
  Future<LatLng> getCurrentLocation();
  Future<void> openMapAt(LatLng position);
}
