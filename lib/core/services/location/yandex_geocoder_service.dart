import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yandex_mapkit/yandex_mapkit.dart';

class YandexGeocoderService {
  static const String _apiKey = String.fromEnvironment('YANDEX_API_KEY');
  static const String _geocoderUrl = 'https://geocode-maps.yandex.ru/1.x/';

  /// Reverse geocode: Convert coordinates to address
  static Future<String> getAddressFromCoordinates(Point point) async {
    try {
      final uri = Uri.parse(_geocoderUrl).replace(queryParameters: {
        'apikey': _apiKey,
        'geocode': '${point.longitude},${point.latitude}',
        'format': 'json',
        'results': '1',
        'kind': 'house', // Prefer house-level precision
        'lang': 'en_US',
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final featureMember =
            data['response']['GeoObjectCollection']['featureMember'] as List;

        if (featureMember.isNotEmpty) {
          final geoObject = featureMember[0]['GeoObject'];
          final metaData = geoObject['metaDataProperty']['GeocoderMetaData'];

          // Get formatted address
          final address = metaData['Address']['formatted'] as String;

          // Try to get precise address components
          final components = metaData['Address']['Components'] as List;
          final street = _getComponent(components, 'street');
          final house = _getComponent(components, 'house');
          final district = _getComponent(components, 'district');

          // Build precise address
          if (street != null && house != null) {
            return '$street, $house${district != null ? ', $district' : ''}';
          } else if (street != null) {
            return '$street${district != null ? ', $district' : ''}';
          }

          return address;
        }
      }
    } catch (e) {
      print('Geocoding error: $e');
    }

    // Fallback to coordinates if everything fails
    return '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
  }

  /// Forward geocode: Search for places
  static Future<List<SearchSuggestion>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final uri = Uri.parse(_geocoderUrl).replace(queryParameters: {
        'apikey': _apiKey,
        'geocode': query,
        'format': 'json',
        'results': '10',
        'lang': 'en_US',
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final featureMembers =
            data['response']['GeoObjectCollection']['featureMember'] as List;

        return featureMembers.map((member) {
          final geoObject = member['GeoObject'];
          final point = geoObject['Point']['pos'].split(' ');
          final longitude = double.parse(point[0]);
          final latitude = double.parse(point[1]);

          final metaData = geoObject['metaDataProperty']['GeocoderMetaData'];
          final address = metaData['Address']['formatted'] as String;
          final kind = metaData['kind'] as String;

          // Extract components for better display
          final components = metaData['Address']['Components'] as List;
          final street = _getComponent(components, 'street');
          final house = _getComponent(components, 'house');
          final district = _getComponent(components, 'district');
          final locality = _getComponent(components, 'locality');

          String displayAddress = address;
          if (street != null && house != null) {
            displayAddress = '$street, $house';
            if (locality != null) displayAddress += ', $locality';
          } else if (street != null) {
            displayAddress = street;
            if (locality != null) displayAddress += ', $locality';
          }

          return SearchSuggestion(
            title: displayAddress,
            subtitle: _buildSubtitle(kind, district, locality),
            point: Point(latitude: latitude, longitude: longitude),
            kind: kind,
          );
        }).toList();
      }
    } catch (e) {
      print('Search error: $e');
    }

    return [];
  }

  static String? _getComponent(List components, String kind) {
    try {
      final component = components.firstWhere(
        (c) => c['kind'] == kind,
        orElse: () => null,
      );
      return component?['name'] as String?;
    } catch (e) {
      return null;
    }
  }

  static String _buildSubtitle(
      String kind, String? district, String? locality) {
    final parts = <String>[];

    if (kind == 'house') {
      parts.add('Building');
    } else if (kind == 'street') {
      parts.add('Street');
    } else if (kind == 'district') {
      parts.add('District');
    } else if (kind == 'locality') {
      parts.add('City');
    }

    if (district != null) parts.add(district);
    if (locality != null && locality != district) parts.add(locality);

    return parts.isNotEmpty ? parts.join(' • ') : 'Location';
  }
}

class SearchSuggestion {
  final String title;
  final String subtitle;
  final Point point;
  final String kind;

  const SearchSuggestion({
    required this.title,
    required this.subtitle,
    required this.point,
    required this.kind,
  });
}
