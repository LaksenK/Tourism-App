import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tourism_app/components/navbar.dart';
import 'package:geolocator/geolocator.dart';

class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> {
  bool _showPoliceContacts = false;
  bool _showHospitalContacts = false;
  bool _showEmbassyContacts = false;
  List<String> locations = ["Colombo", "Kandy", "Galle"];
  String selectedLocation = "Colombo";

  final Map<String, List<Map<String, String>>> policeContacts = {
    "Colombo": [
      {"name": "Colombo Police", "number": "+94112345678"}
    ],
    "Kandy": [
      {"name": "Kandy Police", "number": "+94812345678"}
    ],
    "Galle": [
      {"name": "Galle Police", "number": "+94912345678"}
    ],
  };

  final Map<String, List<Map<String, String>>> hospitalContacts = {
    "Colombo": [
      {"name": "National Hospital Colombo", "number": "+94112692300"}
    ],
    "Kandy": [
      {"name": "Kandy General Hospital", "number": "+94812234567"}
    ],
    "Galle": [
      {"name": "Karapitiya Teaching Hospital", "number": "+94912223610"}
    ],
  };

  final Map<String, List<Map<String, String>>> embassyContacts = {
    "Colombo": [
      {"name": "U.S. Embassy Colombo", "number": "+94112495600"},
      {"name": "British High Commission", "number": "+94112526251"},
      {"name": "Indian High Commission", "number": "+94112420456"},
      {"name": "Chinese Embassy Colombo", "number": "+94112677708"},
    ],
    "Kandy": [],
    "Galle": [],
  };

  @override
  void initState() {
    super.initState();
    _updateLocation();
  }

  Future<void> _updateLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled.")),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied.")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Location permissions are permanently denied.")),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // You can add reverse geocoding here to update selectedLocation based on lat/lng
    print("Current Position: ${position.latitude}, ${position.longitude}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: NavBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: SizedBox(
                width: 200, // Adjust width as needed
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedLocation,
                  items: locations.map((String location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedLocation = newValue!;
                    });
                  },
                ),
              ),
            ),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.local_police, color: Colors.black),
                label: const Text("Police Stations"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _showPoliceContacts = !_showPoliceContacts;
                  });
                },
              ),
            ),
            if (_showPoliceContacts)
              ...(policeContacts[selectedLocation] ?? [])
                  .map((contact) => ListTile(
                        leading: const Icon(Icons.phone),
                        title: Text(contact["name"]!),
                        subtitle: Text(contact["number"]!),
                        onTap: () async {
                          final Uri phoneUri =
                              Uri(scheme: 'tel', path: contact["number"]);
                          if (await canLaunchUrl(phoneUri)) {
                            await launchUrl(phoneUri);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Could not launch the dialer")),
                            );
                          }
                        },
                      )),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.local_hospital, color: Colors.black),
                label: const Text("Hospitals"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _showHospitalContacts = !_showHospitalContacts;
                  });
                },
              ),
            ),
            if (_showHospitalContacts)
              ...(hospitalContacts[selectedLocation] ?? [])
                  .map((contact) => ListTile(
                        leading: const Icon(Icons.phone),
                        title: Text(contact["name"]!),
                        subtitle: Text(contact["number"]!),
                        onTap: () async {
                          final Uri phoneUri =
                              Uri(scheme: 'tel', path: contact["number"]);
                          if (await canLaunchUrl(phoneUri)) {
                            await launchUrl(phoneUri);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Could not launch the dialer")),
                            );
                          }
                        },
                      )),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.emoji_flags, color: Colors.black),
                label: const Text("Embassies"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _showEmbassyContacts = !_showEmbassyContacts;
                  });
                },
              ),
            ),
            if (_showEmbassyContacts)
              ...(embassyContacts[selectedLocation] ?? [])
                  .map((contact) => ListTile(
                        leading: const Icon(Icons.phone),
                        title: Text(contact["name"]!),
                        subtitle: Text(contact["number"]!),
                        onTap: () async {
                          final Uri phoneUri =
                              Uri(scheme: 'tel', path: contact["number"]);
                          if (await canLaunchUrl(phoneUri)) {
                            await launchUrl(phoneUri);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Could not launch the dialer")),
                            );
                          }
                        },
                      )),
          ],
        ),
      ),
    );
  }
}