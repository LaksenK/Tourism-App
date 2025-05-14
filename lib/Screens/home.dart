import 'package:flutter/material.dart';
import 'package:tourism_app/Screens/eventsSelection.dart';
import 'package:tourism_app/Screens/guides.dart';
import 'package:tourism_app/Screens/itenary.dart';
import 'package:tourism_app/Screens/registerGuide.dart';
import 'package:tourism_app/Screens/sosPage.dart';
import 'package:tourism_app/components/navbar.dart';

// import other pages as needed

class Home extends StatelessWidget {
  Home({super.key});

  final List<Map<String, dynamic>> services = [
    {
      'title': 'Find a Exicting Tour',
      'icon': Icons.search,
      'color': Colors.pinkAccent.shade100,
      'page': const GuidesPage(),
    },
    {
      'title': 'Register as Guide',
      'icon': Icons.app_registration,
      'color': Colors.greenAccent.shade100,
      'page': RegisterGuidePage(), // Replace with actual page later
    },
    {
      'title': 'Make your Trip',
      'icon': Icons.event,
      'color': Colors.orange.shade200,
      'page':  ItineraryGenerator(), // Replace with real page if different
    },
    {
      'title': 'Blogs',
      'icon': Icons.article_outlined,
      'color': Colors.purple.shade200,
      'page': null, // Replace with blog page
    },
    {
      'title': 'Emergency Contact',
      'icon': Icons.local_phone_outlined,
      'color': Colors.blue.shade100,
      'page': const SosPage(), // This opens the SOS logic directly
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: NavBar(),
      ),
      body: ListView.builder(
        itemCount: services.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final service = services[index];
          return GestureDetector(
            onTap: () {
              if (service['page'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => service['page']),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Coming soon!")),
                );
              }
            },
            child: Card(
              color: service['color'],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(service['icon'], color: Colors.black),
                title: Text(
                  service['title'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}
