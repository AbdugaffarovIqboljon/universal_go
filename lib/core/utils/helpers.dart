// Utility helper functions
import 'package:universal_go/core/utils/lat_lng.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class Helpers {
  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} UZS';
  }
  
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }
  
  static String formatPhoneNumber(String phoneNumber) {
    // Format phone number for display
    if (phoneNumber.length == 12 && phoneNumber.startsWith('998')) {
      return '+${phoneNumber.substring(0, 3)} ${phoneNumber.substring(3, 6)} ${phoneNumber.substring(6, 8)} ${phoneNumber.substring(8)}';
    }
    return phoneNumber;
  }

  // Conversions between Google LatLng and Yandex Point
  static Point latLngToPoint(LatLng latLng) {
    return Point(latitude: latLng.latitude, longitude: latLng.longitude);
  }

  static LatLng pointToLatLng(Point point) {
    return LatLng(point.latitude, point.longitude);
  }
}
