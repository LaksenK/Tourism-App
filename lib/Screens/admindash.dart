import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/components/navbar.dart';

class AdminDash extends StatefulWidget {
  const AdminDash({super.key});

  @override
  _AdminDashState createState() => _AdminDashState();
}

class _AdminDashState extends State<AdminDash> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contact1Controller = TextEditingController();
  final TextEditingController contact2Controller = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController bannerController = TextEditingController(); // Title Banner (Image Link)

  bool isLoading = false; // To track submission state

  // Sri Lankan provinces
  final List<String> provinces = [
    "Central", "Eastern", "North Central", "Northern", "North Western",
    "Sabaragamuwa", "Southern", "Uva", "Western"
  ];
  List<String> selectedProvinces = [];

  // Function to add guide to Firestore
  Future<void> addGuide() async {
    if (_validateFields()) {
      setState(() {
        isLoading = true;
      });

      try {
        await FirebaseFirestore.instance.collection('guides').add({
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

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Guide added successfully!")),
        );

        // Clear fields
        _clearFields();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Validate required fields
  bool _validateFields() {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields must be completed!")),
      );
      return false;
    }
    return true;
  }

  // Clear all fields after submission
  void _clearFields() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    contact1Controller.clear();
    contact2Controller.clear();
    priceController.clear();
    titleController.clear();
    descriptionController.clear();
    bannerController.clear();
    setState(() {
      selectedProvinces = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(70),
  child: const NavBar(),
),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Add a Travel Guide",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // Contact Details Section
              const Text("Contact Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              _buildTextField(firstNameController, "First Name"),
              _buildTextField(lastNameController, "Last Name"),
              _buildTextField(emailController, "Email"),
              _buildTextField(contact1Controller, "Contact Number 1"),
              _buildTextField(contact2Controller, "Contact Number 2"),

              const SizedBox(height: 20),

              // Travel Details Section
              const Text("Travel Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Multi-select checkboxes for Provinces
              const Text("Provinces (Select all that apply)"),
              Wrap(
                children: provinces.map((province) {
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
              _buildTextField(bannerController, "Title Banner (Image URL)"),
              _buildTextField(descriptionController, "Description", isMultiline: true),

              const SizedBox(height: 20),

              // Add Guide Button
              Center(
                child: ElevatedButton(
                  onPressed: isLoading ? null : addGuide,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Add Guide",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom TextField Widget
  Widget _buildTextField(TextEditingController controller, String label, {bool isNumeric = false, bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : (isMultiline ? TextInputType.multiline : TextInputType.text),
        maxLines: isMultiline ? 3 : 1,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
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
}
