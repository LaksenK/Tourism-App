import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/Screens/login.dart';
import 'package:tourism_app/Screens/userProfile.dart';
import 'package:tourism_app/Screens/home.dart';
import 'package:tourism_app/Screens/guides.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String firstName = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchUserFirstName();
  }

  Future<void> fetchUserFirstName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          firstName = userDoc['firstName'] ?? "User";
        });
      }
    }
  }

  void logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Nav links with icons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.black87),
                tooltip: 'Home',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const Home()));
                },
              ),
              IconButton(
                icon: const Icon(Icons.map, color: Colors.black87),
                tooltip: 'Guides',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const GuidesPage()));
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.black87),
                tooltip: 'Profile',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                },
              ),
            ],
          ),

          Expanded(
            child: Center(
              child: Text(
                'WonDora',
                style: GoogleFonts.lora(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.black.withOpacity(0.4),
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // User name and actions
          Row(
            children: [
              Text(
                firstName,
                style: GoogleFonts.lora(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                onPressed: logout,
                tooltip: 'Logout',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
