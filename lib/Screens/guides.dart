import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tourism_app/components/navbar.dart';

class GuidesPage extends StatefulWidget {
  const GuidesPage({super.key});

  @override
  _GuidesPageState createState() => _GuidesPageState();
}

class _GuidesPageState extends State<GuidesPage> {
  String? selectedProvince = "All"; // Default to 'All'
  String? selectedPriceRange = "All"; // Default to 'All'

  final List<String> provinces = [
    "All", "Central", "Eastern", "North Central", "Northern", "North Western",
    "Sabaragamuwa", "Southern", "Uva", "Western"
  ];

  final Map<String, RangeValues> priceRanges = {
    "All": const RangeValues(0, 1000), // All price ranges
    "0-25": RangeValues(0, 25),
    "25-50": RangeValues(25, 50),
    "50-100": RangeValues(50, 100),
    "100-200": RangeValues(100, 200),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: const NavBar(), // Include navbar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filter Options
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Province Dropdown
                DropdownButton<String>(
                  hint: const Text("Select Province"),
                  value: selectedProvince,
                  items: provinces.map((String province) {
                    return DropdownMenuItem<String>(
                      value: province,
                      child: Text(province),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedProvince = value;
                    });
                  },
                ),
                const SizedBox(width: 20),

                // Price Range Dropdown
                DropdownButton<String>(
                  hint: const Text("Select Price Range"),
                  value: selectedPriceRange,
                  items: priceRanges.keys.map((String key) {
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Text(key),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedPriceRange = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Display Guide Cards
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('guides').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var guides = snapshot.data!.docs;

                  // Apply filters
                  guides = guides.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    bool provinceMatch = selectedProvince == "All" ||
                        (data['provinces'] as List<dynamic>).contains(selectedProvince);
                    bool priceMatch = selectedPriceRange == "All" ||
                        (data['price'] as num) >= priceRanges[selectedPriceRange]!.start &&
                        (data['price'] as num) <= priceRanges[selectedPriceRange]!.end;
                    return provinceMatch && priceMatch;
                  }).toList();

                  if (guides.isEmpty) {
                    return const Center(child: Text("No guides found for the selected filters"));
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400, // Ensures centered layout
                      mainAxisExtent: 250,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: guides.length,
                    itemBuilder: (context, index) {
                      var guide = guides[index].data() as Map<String, dynamic>;
                      return _buildGuideCard(guide, context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Guide Card Widget
  Widget _buildGuideCard(Map<String, dynamic> guide, BuildContext context) {
    return GestureDetector(
      onTap: () => _showGuidePopup(context, guide),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                guide['bannerImage'],
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    guide['title'],
                    style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "\$${guide['price']} per person",
                    style: const TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Popup Dialog for Guide Details
  void _showGuidePopup(BuildContext context, Map<String, dynamic> guide) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      guide['bannerImage'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    guide['title'],
                    style: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    guide['description'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Price: \$${guide['price']} per person",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 15),

                  // Contact Details
                  const Divider(),
                  const Text("Contact Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    "${guide['firstName']} ${guide['lastName']}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(guide['email']),
                  Text("📞 ${guide['contact1']}"),
                  Text("📞 ${guide['contact2']}"),
                  const SizedBox(height: 15),

                  // Close Button
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Close", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
