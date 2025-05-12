import 'package:flutter/material.dart';
import 'package:tourism_app/components/navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventSection extends StatefulWidget {
  const EventSection({super.key});

  @override
  State<EventSection> createState() => _EventSectionState();
}

class _EventSectionState extends State<EventSection> {
  List<Map<String, dynamic>> events = [];
  int? selectedIndex;
  bool isLoading = true;
  bool isAdmin = false;  // To track if the user is an admin

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    fetchEvents();
  }

  // Check if the logged-in user is an admin
  Future<void> _checkAdminStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        isAdmin = data['role'] == 'admin';  // Check if the role is admin
      });
    }
  }

  // Fetch events from Firestore
  Future<void> fetchEvents() async {
    final snapshot = await FirebaseFirestore.instance.collection('events').get();
    final data = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    setState(() {
      events = data;
      isLoading = false;
    });
  }

  // Delete event from Firestore
  Future<void> deleteEvent(String title) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('title', isEqualTo: title)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    fetchEvents(); // Refresh after delete
  }

  // Reset selection after navigating back
  void resetSelection() {
    setState(() {
      selectedIndex = null;
    });
    fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: NavBar(),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final isSelected = selectedIndex == index;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.deepPurple,
                                  child: Text(
                                    event['title']?.substring(0, 1) ?? '',
                                    style:
                                        const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    event['title'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                // Show the delete button only if the user is an admin
                                if (isAdmin)
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      deleteEvent(event['title']);
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (event['imageUrl'] != null &&
                                event['imageUrl'].isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  event['imageUrl'],
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(height: 12),
                            if (isSelected) ...[
                              const Text(
                                "Description:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(event['description'] ?? ''),
                              const SizedBox(height: 8),
                              Text(
                                "Location:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(event['location'] ?? ''),
                              const SizedBox(height: 8),
                              Text(
                                "Date:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(event['date'] ?? ''),
                              const SizedBox(height: 8),
                              Text(
                                "Organizer:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(event['organizer'] ?? ''),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text("Back"),
                                  onPressed: resetSelection,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ] else
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event['title'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedIndex = index;
                                        });
                                      },
                                      child: const Text("Read More"),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
