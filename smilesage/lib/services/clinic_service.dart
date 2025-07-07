import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/clinic.dart';
import 'location_service.dart';

class ClinicService {
  // Replace with your actual Google Places API key
  static const String _apiKey = 'AIzaSyAAZIGTY9QdGeZB_N4oyqzjrcazCJ_IrmQ';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  static Future<List<Clinic>> getNearbyClinics({
    double? latitude,
    double? longitude,
    int radius = 5000, // 5km radius
  }) async {
    try {
      // If no coordinates provided, get current location
      if (latitude == null || longitude == null) {
        final position = await LocationService.getCurrentLocation();
        if (position == null) {
          throw Exception('Unable to get current location');
        }
        latitude = position.latitude;
        longitude = position.longitude;
      }

      final url = Uri.parse('$_baseUrl/nearbysearch/json?'
          'location=$latitude,$longitude'
          '&radius=$radius'
          '&type=dentist'
          '&keyword=dental%20clinic'
          '&key=$_apiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          List<dynamic> results = data['results'];
          List<Clinic> clinics = [];

          for (var result in results) {
            final clinic = Clinic.fromJson(result);

            // Calculate distance from user
            final distance = await LocationService.getDistanceFromUser(
              clinic.latitude,
              clinic.longitude,
              null, // Will get current position inside the method
            );

            clinics.add(clinic.copyWith(distanceFromUser: distance));
          }

          // Sort by distance
          clinics.sort((a, b) => (a.distanceFromUser ?? double.infinity)
              .compareTo(b.distanceFromUser ?? double.infinity));

          return clinics;
        } else {
          throw Exception('Places API error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching nearby clinics: $e');
      // Return mock data for development/testing
      return _getMockClinics();
    }
  }

  static Future<Clinic?> getClinicDetails(String placeId) async {
    try {
      final url = Uri.parse('$_baseUrl/details/json?'
          'place_id=$placeId'
          '&fields=name,formatted_address,geometry,formatted_phone_number,website,rating,user_ratings_total,opening_hours,types'
          '&key=$_apiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          return Clinic.fromJson(data['result']);
        }
      }

      return null;
    } catch (e) {
      print('Error fetching clinic details: $e');
      return null;
    }
  }

  // Mock data for development/testing when API is not available
  static List<Clinic> _getMockClinics() {
    return [
      Clinic(
        id: '1',
        name: 'Bright Smiles Dental',
        address: '123 Main St, San Francisco, CA 94105',
        latitude: 37.7749,
        longitude: -122.4194,
        phoneNumber: '+1 (415) 555-0123',
        website: 'https://brightsmiles.com',
        rating: 4.8,
        reviewCount: 127,
        imagePath: 'assets/images/clinic1.png',
        distanceFromUser: 0.5,
        services: ['General Dentistry', 'Orthodontics', 'Cosmetic Dentistry'],
        isOpen: true,
      ),
      Clinic(
        id: '2',
        name: 'Golden Gate Dental Care',
        address: '456 Oak Ave, San Francisco, CA 94118',
        latitude: 37.7849,
        longitude: -122.4094,
        phoneNumber: '+1 (415) 555-0456',
        website: 'https://goldengatedental.com',
        rating: 4.6,
        reviewCount: 89,
        imagePath: 'assets/images/clinic2.png',
        distanceFromUser: 1.2,
        services: ['General Dentistry', 'Pediatric Dentistry'],
        isOpen: true,
      ),
      Clinic(
        id: '3',
        name: 'Presidio Dental Group',
        address: '789 Pine St, San Francisco, CA 94115',
        latitude: 37.7649,
        longitude: -122.4294,
        phoneNumber: '+1 (415) 555-0789',
        website: 'https://presidiodental.com',
        rating: 4.9,
        reviewCount: 203,
        imagePath: 'assets/images/clinic3.png',
        distanceFromUser: 2.1,
        services: [
          'General Dentistry',
          'Orthodontics',
          'Endodontics',
          'Periodontics'
        ],
        isOpen: false,
      ),
    ];
  }
}
