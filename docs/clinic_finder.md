# Clinic Finder Feature

## Overview
The Clinic Finder feature helps users locate nearby dental clinics using their device's location and the Google Places API. It displays a list and map of clinics, sorted by distance, with details such as address, contact info, and services.

## How It Works
1. The app requests location permission and fetches the user's current coordinates.
2. It queries the Google Places API for nearby clinics (type: dentist, keyword: dental clinic).
3. Results are parsed and displayed in the UI, with distance calculated from the user's location.
4. Users can view clinic details, call, visit the website, or get directions.

## API Usage
- **Google Places API**: Used for searching and retrieving clinic details.
- **API Key**: Must be set in your environment variables/configuration.
- **Quota**: Be aware of Google Places API usage limits and pricing.

## Customization
- Adjust search radius in `clinic_service.dart` (default: 25km)
- Change displayed fields or add filters as needed
- Replace mock data with real API results for production

## Security Note
Never commit your real API key to version control. Use environment variables or secure storage.

---

For implementation details, see `lib/services/clinic_service.dart` and related UI screens. 