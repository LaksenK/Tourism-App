import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tourism_app/Screens/eventsSelection.dart';
import 'package:tourism_app/Screens/itenary.dart';
import 'package:tourism_app/Screens/login.dart';
import 'package:tourism_app/Screens/sosPage.dart';
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
              }  else if (value == 'itenary_genarator') {
                Navigator.push(context, MaterialPageRoute(builder: (_) =>   ItineraryGenerator())); // Navigate to Cultural Events
              } else if (value == 'emergency_contacts') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SosPage())); // Navigate to Emergency Contacts
              }else if (value == 'profile') {
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
                value: 'itenary_genarator',
                child: ListTile(leading: Icon(Icons.calendar_today), title: Text('Itenary Genarator')),
              ),
              const PopupMenuItem<String>(
                value: 'emergency_contacts',
                child: ListTile(leading: Icon(Icons.phone), title: Text('Emergency Contacts')),
              ),
              const PopupMenuItem<String>(
                value: 'profile',
                child: ListTile(leading: Icon(Icons.person_outline), title: Text('Profile')),
              ),
            ],
          ),

          // 🧭 Logo
          Image.network(
         'data:image/png;base64,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',
            width: 120,
            height: 50,
            fit: BoxFit.cover,
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
