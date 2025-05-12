import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/Screens/itenaryCard.dart';

class Itenary extends StatefulWidget {
  const Itenary({super.key});

  @override
  State<Itenary> createState() => _ItenaryState();
}

class _ItenaryState extends State<Itenary> {
  String? _destination = 'Kandy';
  String? _interest = 'Cultural';
  int _duration = 4;
  DateTime? _startDate;

  // Dropdown options for destination, interest, etc.
  final List<String> destinations = ['Kandy', 'Galle', 'Jaffna', 'Ella'];
  final List<String> interests = ['Cultural', 'Wildlife', 'Adventure', 'All'];

  // Method to handle date selection
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now();
    DateTime lastDate = DateTime.now().add(Duration(days: 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  // Generate itinerary based on the user inputs and navigate to ItenaryCard page
  Future<void> _generateItinerary() async {
    String userId = "user123"; // Placeholder for logged-in user ID

    // Save user inputs to Firebase
    await FirebaseFirestore.instance
        .collection('user_itineraries')
        .doc(userId)
        .set({
          'destination': _destination,
          'interest': _interest,
          'duration': _duration,
          'startDate': _startDate?.toIso8601String() ?? 'Unknown Start Date',
        });

    // Navigate to the ItineraryCard page with the selected details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItenaryCard(
          destination: _destination!,
          interest: _interest!,
          duration: _duration,
          startDate: _startDate?.toIso8601String() ?? 'Unknown Start Date',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Itinerary Generator"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Itinerary Generator',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Start Point Dropdown
            Text('Start Point', style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: _destination,
              onChanged: (String? newValue) {
                setState(() {
                  _destination = newValue!;
                });
              },
              items: destinations
                  .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  })
                  .toList(),
            ),
            SizedBox(height: 20),
            // Start Date
            Text('Start Date', style: TextStyle(fontSize: 16)),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: _startDate == null
                        ? 'Select Date'
                        : '${_startDate!.year}-${_startDate!.month}-${_startDate!.day}',
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Interest Dropdown
            Text('Interest', style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: _interest,
              onChanged: (String? newValue) {
                setState(() {
                  _interest = newValue!;
                });
              },
              items: interests
                  .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  })
                  .toList(),
            ),
            SizedBox(height: 20),
            // Duration Slider
            Text('Duration (Days):', style: TextStyle(fontSize: 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (_duration > 1) {
                      setState(() {
                        _duration--;
                      });
                    }
                  },
                  icon: Icon(Icons.remove),
                ),
                Text('$_duration'),
                IconButton(
                  onPressed: () {
                    if (_duration < 4) {
                      setState(() {
                        _duration++;
                      });
                    }
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Generate Itinerary Button
            ElevatedButton(
              onPressed: () {
                if (_destination == null || _interest == null || _startDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select all required fields")),
                  );
                  return;
                }
                _generateItinerary();
              },
              child: const Text('Generate Itinerary'),
            ),
          ],
        ),
      ),
    );
  }
}