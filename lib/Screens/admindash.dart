// Admin Dashboard with guide request approval functionality
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/components/navbar.dart';

class AdminDash extends StatefulWidget {
  const AdminDash({super.key});

  @override
  AdminDashState createState() => AdminDashState();
}

class AdminDashState extends State<AdminDash> {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Pending Guide Requests",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('guide_requests').where('status', isEqualTo: 'pending').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var requests = snapshot.data!.docs;

                  if (requests.isEmpty) {
                    return const Center(child: Text("No pending guide requests."));
                  }

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      var data = requests[index].data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Name: ${data['name']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text("Email: ${data['email']}"),
                              Text("NIC: ${data['nic']}"),
                              Text("Language: ${data['language']}"),
                              Text("Member #: ${data['memberNumber']}"),
                              Text("Issue: ${data['issueDate']} | Expiry: ${data['expiryDate']}"),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _approveGuide(data),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    child: const Text("Accept"),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () => _rejectGuide(data['userID']),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    child: const Text("Reject"),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
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

  Future<void> _approveGuide(Map<String, dynamic> data) async {
    final uid = data['userID'];
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'role': 'guide',
      });

      await FirebaseFirestore.instance.collection('guide_requests').doc(uid).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Guide approved successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> _rejectGuide(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('guide_requests').doc(uid).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Guide request rejected.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }
}
