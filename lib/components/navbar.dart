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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🍔 Left-side Hamburger Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onSelected: (value) {
              if (value == 'home') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => Home()));
              } else if (value == 'guides') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GuidesPage()));
              } else if (value == 'profile') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'home',
                child: ListTile(leading: Icon(Icons.home), title: Text('Home')),
              ),
              const PopupMenuItem<String>(
                value: 'guides',
                child: ListTile(leading: Icon(Icons.map), title: Text('Guides')),
              ),
              const PopupMenuItem<String>(
                value: 'profile',
                child: ListTile(leading: Icon(Icons.person_outline), title: Text('Profile')),
              ),
            ],
          ),

          // 🧭 Centered Wandora Title
          Text(
            'Wondora',
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

          // 👤 Username + Logout
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
