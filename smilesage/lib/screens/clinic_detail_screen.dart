import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/clinic.dart';
import '../services/location_service.dart';

class ClinicDetailScreen extends StatelessWidget {
  static const routeName = '/clinic-detail';
  final Clinic clinic;

  const ClinicDetailScreen({Key? key, required this.clinic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF7CF4A4);
    const headingText = Color(0xFF0A244E);
    const subtitleText = Color(0xFF7CA78C);
    const backgroundWhite = Colors.white;

    return Scaffold(
      backgroundColor: backgroundWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Clinic Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clinic Image
            if (clinic.imagePath != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  child: Image.asset(
                    clinic.imagePath!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clinic Name
                  Text(
                    clinic.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: headingText,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Rating and Review Count
                  if (clinic.rating != null)
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${clinic.rating}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: headingText,
                          ),
                        ),
                        if (clinic.reviewCount != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${clinic.reviewCount} reviews)',
                            style: const TextStyle(
                              fontSize: 14,
                              color: subtitleText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Distance
                  if (clinic.distanceFromUser != null)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: primaryGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          LocationService.formatDistance(
                              clinic.distanceFromUser),
                          style: const TextStyle(
                            fontSize: 16,
                            color: subtitleText,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.place,
                        color: primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          clinic.address,
                          style: const TextStyle(
                            fontSize: 16,
                            color: subtitleText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Contact Information
                  if (clinic.phoneNumber != null || clinic.website != null) ...[
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: headingText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (clinic.phoneNumber != null)
                      _ContactTile(
                        icon: Icons.phone,
                        title: 'Phone',
                        subtitle: clinic.phoneNumber!,
                        onTap: () => _launchUrl('tel:${clinic.phoneNumber}'),
                      ),
                    if (clinic.website != null)
                      _ContactTile(
                        icon: Icons.language,
                        title: 'Website',
                        subtitle: clinic.website!,
                        onTap: () => _launchUrl(clinic.website!),
                      ),
                    const SizedBox(height: 24),
                  ],

                  // Services
                  if (clinic.services != null &&
                      clinic.services!.isNotEmpty) ...[
                    const Text(
                      'Services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: headingText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: clinic.services!.map((service) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F4EC),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            service,
                            style: const TextStyle(
                              fontSize: 14,
                              color: headingText,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: clinic.isOpen ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: clinic.isOpen ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          clinic.isOpen ? Icons.check_circle : Icons.cancel,
                          color: clinic.isOpen ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          clinic.isOpen ? 'Open Now' : 'Closed',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: clinic.isOpen ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: backgroundWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _launchUrl(
                  'https://maps.google.com/maps?q=${clinic.latitude},${clinic.longitude}',
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Get Directions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement booking functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking feature coming soon!'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Book Appointment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: headingText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF7CF4A4);
    const headingText = Color(0xFF0A244E);
    const subtitleText = Color(0xFF7CA78C);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: primaryGreen,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: headingText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: subtitleText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: subtitleText,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
