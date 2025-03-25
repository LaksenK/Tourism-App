import 'package:flutter/material.dart';
import 'package:tourism_app/Screens/guides.dart';
import 'package:tourism_app/components/navbar.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: NavBar(),
      ),
      body: Stack(
        children: [
          // Full-width background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://media.istockphoto.com/id/2147497907/photo/young-woman-traveler-relaxing-and-enjoying-the-tropical-sea-while-traveling-for-summer.jpg?s=612x612&w=0&k=20&c=iY2aqFsXX9Hzq_KwAZhy3ug74z0y7KHxUc_msPHyKzU=', // Replace with your own image if needed
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dark overlay (optional for contrast)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.5),
          ),

          // Centered content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "YOUR JOURNEY STARTS\n WITH THE RIGHT GUIDE",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(
                      fontSize: MediaQuery.of(context).size.width < 600 ? 28 : 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GuidesPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      backgroundColor: const Color.fromARGB(182, 174, 210, 200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "FIND A GUIDE",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
