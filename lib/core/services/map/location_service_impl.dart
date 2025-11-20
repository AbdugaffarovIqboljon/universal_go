import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:universal_go/core/utils/lat_lng.dart';
import 'package:url_launcher/url_launcher.dart';
import 'location_service.dart';

class LocationServiceImpl implements LocationService {
  Future<bool> _ensurePermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  @override
  Future<LatLng> getCurrentLocation() async {
    final granted = await _ensurePermission();
    if (!granted) {
      throw Exception('Location permission not granted');
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return LatLng(position.latitude, position.longitude);
  }

  @override
  Future<void> openMapAt(LatLng position) async {
    final url = Uri.parse('yandexmaps://maps/?pt=${position.longitude},${position.latitude}&z=16&l=map');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      return;
    }
    final web = Uri.parse('https://yandex.com/maps/?ll=${position.longitude},${position.latitude}&z=16');
    await launchUrl(web, mode: LaunchMode.externalApplication);
  }
}
