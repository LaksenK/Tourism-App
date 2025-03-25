// Updated GuidesPage with working 'Post a Tour' form and dynamic view toggle

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tourism_app/components/navbar.dart';
import 'package:url_launcher/url_launcher.dart';

class GuidesPage extends StatefulWidget {
  const GuidesPage({super.key});

  @override
  GuidesPageState createState() => GuidesPageState();
}

class GuidesPageState extends State<GuidesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedView = 'find';
  String? selectedProvince = "All";
  String? selectedPriceRange = "All";
  String? userRole;
  String? currentUserEmail;

  final List<String> provinces = [
    "All", "Central", "Eastern", "North Central", "Northern", "North Western",
    "Sabaragamuwa", "Southern", "Uva", "Western"
  ];

  final Map<String, RangeValues> priceRanges = {
    "All": const RangeValues(0, 1000),
    "0-25": RangeValues(0, 25),
    "25-50": RangeValues(25, 50),
    "50-100": RangeValues(50, 100),
    "100-200": RangeValues(100, 200),
  };

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController nicController = TextEditingController();
  final TextEditingController languageController = TextEditingController();
  final TextEditingController memberNumberController = TextEditingController();
  final TextEditingController issueDateController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();

  // Post tour form controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contact1Controller = TextEditingController();
  final TextEditingController contact2Controller = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController bannerController = TextEditingController();

  List<String> selectedProvinces = [];

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final data = userDoc.data();
      if (data != null) {
        setState(() {
          userRole = data['role'] ?? 'tourist';
          currentUserEmail = data['email'];
          if (userRole == 'guide') {
            firstNameController.text = data['firstName'] ?? '';
            lastNameController.text = data['lastName'] ?? '';
            emailController.text = data['email'] ?? '';
          }
        });
      }
    }
  }

  Future<void> _submitGuideRequest() async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (nameController.text.isEmpty ||
        addressController.text.isEmpty ||
        nicController.text.isEmpty ||
        languageController.text.isEmpty ||
        memberNumberController.text.isEmpty ||
        issueDateController.text.isEmpty ||
        expiryDateController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill out all fields.")),
      );
      return;
    }

    await _firestore.collection('guide_requests').doc(user.uid).set({
      'userID': user.uid,
      'email': user.email,
      'name': nameController.text.trim(),
      'address': addressController.text.trim(),
      'nic': nicController.text.trim(),
      'language': languageController.text.trim(),
      'memberNumber': memberNumberController.text.trim(),
      'issueDate': issueDateController.text.trim(),
      'expiryDate': expiryDateController.text.trim(),
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Guide request submitted.")),
    );

    setState(() {
      selectedView = 'find';
    });
  }

  Future<void> _postTour() async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        contact1Controller.text.isEmpty ||
        contact2Controller.text.isEmpty ||
        selectedProvinces.isEmpty ||
        priceController.text.isEmpty ||
        titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        bannerController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill out all fields to post the tour.")),
      );
      return;
    }

    await _firestore.collection('guides').add({
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'email': emailController.text.trim(),
      'contact1': contact1Controller.text.trim(),
      'contact2': contact2Controller.text.trim(),
      'provinces': selectedProvinces,
      'price': double.parse(priceController.text.trim()),
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'bannerImage': bannerController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tour posted successfully!")),
    );

    setState(() {
      selectedView = 'find';
      contact1Controller.clear();
      contact2Controller.clear();
      priceController.clear();
      titleController.clear();
      descriptionController.clear();
      bannerController.clear();
      selectedProvinces.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: NavBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (userRole != 'guide')
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => selectedView = 'find'),
                    child: const Text("Find a Guide"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => setState(() => selectedView = 'register'),
                    child: const Text("Register as a Guide"),
                  ),
                ],
              ),
            if (userRole == 'guide')
              ElevatedButton(
                onPressed: () => setState(() => selectedView = 'post'),
                child: const Text("Post a Tour"),
              ),
            const SizedBox(height: 20),
            Expanded(
              child: selectedView == 'register'
                  ? _buildGuideRegistrationForm()
                  : selectedView == 'post'
                      ? _buildPostTourForm()
                      : _buildGuideFinder(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostTourForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSriLankaPhoneField(contact1Controller, "Contact Number 1"),
_buildSriLankaPhoneField(contact2Controller, "Contact Number 2"),

          const SizedBox(height: 10),
          const Text("Provinces (Select all that apply)"),
          Wrap(
            children: provinces.skip(1).map((province) {
              return CheckboxListTile(
                title: Text(province),
                value: selectedProvinces.contains(province),
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      selectedProvinces.add(province);
                    } else {
                      selectedProvinces.remove(province);
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            }).toList(),
          ),
          _buildTextField(priceController, "Price per person", isNumeric: true),
          _buildTextField(titleController, "Title"),
          _buildTextField(bannerController, "Banner Image Link"),
          _buildTextField(descriptionController, "Description", isMultiline: true),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _postTour,
            child: const Text("Post Tour"),
          )
        ],
      ),
    );
  }

  Widget _buildGuideFinder() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedProvince,
              items: provinces.map((String province) {
                return DropdownMenuItem<String>(
                  value: province,
                  child: Text(province),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedProvince = value;
                });
              },
            ),
            const SizedBox(width: 20),
            DropdownButton<String>(
              value: selectedPriceRange,
              items: priceRanges.keys.map((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(key),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPriceRange = value;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('guides').limit(15).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              var guides = snapshot.data!.docs;
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
              return ListView.builder(
  itemCount: guides.length,
  itemBuilder: (context, index) {
    var guideDoc = guides[index];
    var guideData = guideDoc.data() as Map<String, dynamic>;
    return _buildGuideCard(guideData, docId: guideDoc.id); // ✅ pass docId
  },
);
            },
          ),
        ),
      ],
    );
  }
Widget _buildGuideCard(Map<String, dynamic> guide, {String? docId}) {
  return Stack(
    children: [
      GestureDetector(
        onTap: () => _showGuidePopup(context, guide),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: CachedNetworkImage(
                  imageUrl: guide['bannerImage'],
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
      ),
      if (userRole == 'admin')
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete Tour"),
                  content: const Text("Are you sure you want to delete this tour?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );

              if (shouldDelete == true && docId != null) {
                await FirebaseFirestore.instance.collection('guides').doc(docId).delete();
              }
            },
          ),
        ),
    ],
  );
}

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumeric = false, bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : (isMultiline ? TextInputType.multiline : TextInputType.text),
        maxLines: isMultiline ? 3 : 1,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
Widget _buildSriLankaPhoneField(TextEditingController controller, String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 9, // Only 9 digits after +94
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        prefixText: '+94 ',
        prefixStyle: const TextStyle(color: Colors.black),
        labelText: label,
        counterText: "", // Hides character counter
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

// FIXED: Updated _showGuidePopup to prevent layout crash on tour card click

void _showGuidePopup(BuildContext context, Map<String, dynamic> guide) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 600, minWidth: 300),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: guide['bannerImage'] ?? '',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  guide['title'] ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  guide['description'] ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "Price: \$${guide['price']} per person",
                  style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 30),
                const Text(
                  "Contact Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text("${guide['firstName']} ${guide['lastName']}"),
                Text(guide['email'] ?? ''),
                InkWell(
  onTap: () async {
    final Uri phoneUri = Uri.parse('tel:${guide['contact1']}');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  },
  child: Text(
    "📞 ${guide['contact1']}",
    style: TextStyle(color: Colors.green, decoration: TextDecoration.underline),
  ),
),
const SizedBox(height: 5),
InkWell(
  onTap: () async {
    final Uri phoneUri = Uri.parse('tel:${guide['contact2']}');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  },
  child: Text(
    "📞 ${guide['contact2']}",
    style: TextStyle(color: Colors.green, decoration: TextDecoration.underline),
  ),
),
const SizedBox(height: 5),
InkWell(
  onTap: () async {
    final Uri emailUri = Uri.parse('mailto:${guide['email']}');
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  },
  child: Text(
    guide['email'],
    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
  ),
),
const SizedBox(height: 5),
InkWell(
  onTap: () async {
    // Replace + and leading 0 if necessary
    final String phone = guide['contact1']
        .replaceAll('+94', '94') // keep only country code
        .replaceAll(' ', ''); // clean spaces just in case

    final Uri whatsappUri = Uri.parse('https://wa.me/$phone');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    }
  },
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.message_outlined, color: Colors.green),
      SizedBox(width: 6),
      Text(
        guide['contact1'], // Display normally with +94
        style: TextStyle(color: Colors.green),
      ),
    ],
  ),
),


                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}


  Widget _buildGuideRegistrationForm() {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(nameController, "Full Name"),
        _buildTextField(addressController, "Address"),
        _buildTextField(nicController, "NIC"),
        _buildTextField(languageController, "Language"),
        _buildTextField(memberNumberController, "Member Number"),
        _buildTextField(issueDateController, "Issue Date"),
        _buildTextField(expiryDateController, "Expiry Date"),
        const SizedBox(height: 10),
        Center(
          child: ElevatedButton(
            onPressed: _submitGuideRequest,
            child: const Text("Submit Guide Request"),
          ),
        )
      ],
    ),
  );
}

}
