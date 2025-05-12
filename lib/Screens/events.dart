import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/components/navbar.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({Key? key}) : super(key: key);

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _organizerController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  Future<void> _submitEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('events').add({
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'location': _locationController.text.trim(),
          'date': _dateController.text.trim(),
          'organizer': _organizerController.text.trim(),
          'imageUrl': _imageUrlController.text.trim(),
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Event submitted successfully!")),
        );

        _titleController.clear();
        _descriptionController.clear();
        _locationController.clear();
        _dateController.clear();
        _organizerController.clear();
        _imageUrlController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to submit event: $e")),
        );
      }
    }
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
_buildTextField(_titleController, "Event Title", key: const Key('titleField')),
_buildTextField(_descriptionController, "Description", maxLines: 3, key: const Key('descriptionField')),
_buildTextField(_locationController, "Location", key: const Key('locationField')),
_buildTextField(_dateController, "Date (e.g. 2024-05-01)", key: const Key('dateField')),
_buildTextField(_organizerController, "Organizer Name", key: const Key('organizerField')),
_buildTextField(_imageUrlController, "Image URL", key: const Key('imageField')),


              const SizedBox(height: 20),
              ElevatedButton(
                key: const Key('submitEventBtn'),
                onPressed: _submitEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Submit Event", style: TextStyle(fontSize: 18)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
    {int maxLines = 1, Key? key}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      key: key,
      controller: controller,
      maxLines: maxLines,
      validator: (value) => value == null || value.isEmpty ? "Required" : null,
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
