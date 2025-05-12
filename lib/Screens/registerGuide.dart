import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterGuidePage extends StatefulWidget {
  const RegisterGuidePage({Key? key}) : super(key: key);

  @override
  _RegisterGuidePageState createState() => _RegisterGuidePageState();
}

class _RegisterGuidePageState extends State<RegisterGuidePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController nicController = TextEditingController();
  final TextEditingController languageController = TextEditingController();
  final TextEditingController memberNumberController = TextEditingController();
  final TextEditingController issueDateController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Guide request submitted.")),
    );

    // Optionally clear fields
    nameController.clear();
    addressController.clear();
    nicController.clear();
    languageController.clear();
    memberNumberController.clear();
    issueDateController.clear();
    expiryDateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register as Guide")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitGuideRequest,
                child: const Text("Submit Guide Request"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
