class Clinic {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final String? website;
  final double? rating;
  final int? reviewCount;
  final String? imagePath;
  final double? distanceFromUser;
  final List<String>? services;
  final bool isOpen;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.website,
    this.rating,
    this.reviewCount,
    this.imagePath,
    this.distanceFromUser,
    this.services,
    this.isOpen = true,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['place_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['vicinity'] ?? json['formatted_address'] ?? '',
      latitude: json['geometry']?['location']?['lat']?.toDouble() ?? 0.0,
      longitude: json['geometry']?['location']?['lng']?.toDouble() ?? 0.0,
      phoneNumber: json['formatted_phone_number'],
      website: json['website'],
      rating: json['rating']?.toDouble(),
      reviewCount: json['user_ratings_total'],
      services: json['types']?.cast<String>(),
      isOpen: json['opening_hours']?['open_now'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'website': website,
      'rating': rating,
      'reviewCount': reviewCount,
      'imagePath': imagePath,
      'distanceFromUser': distanceFromUser,
      'services': services,
      'isOpen': isOpen,
    };
  }

  Clinic copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    String? website,
    double? rating,
    int? reviewCount,
    String? imagePath,
    double? distanceFromUser,
    List<String>? services,
    bool? isOpen,
  }) {
    return Clinic(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imagePath: imagePath ?? this.imagePath,
      distanceFromUser: distanceFromUser ?? this.distanceFromUser,
      services: services ?? this.services,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}
