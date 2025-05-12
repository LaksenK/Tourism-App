import 'package:flutter/material.dart';
import 'package:tourism_app/Screens/login.dart';
import 'package:tourism_app/components/sos.dart';
 // Make sure this page exists

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔳 Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQCmdZy7i30h7n6b7GRNA5vJV_hdQGwUyu8_g&s',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🕶️ Overlay for readability
          Container(
            color: Colors.black.withOpacity(0.5),
          ),

          // 🧭 Main content
          SafeArea(
            child: Stack(
              children: [
                // 📌 Centered Title + Description
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      // 🏷️ Title
                      Text(
                        'Wondora',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 20),

                      // 📖 Description
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          'Discover trusted travel guides, emergency help, and local gems — all in one place. Welcome to your travel companion.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 🚀 Get Started + Emergency buttons at the bottom
                Positioned(
                  bottom: 100,
                  left: 32,
                  right: 32,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Login()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(130, 83, 255, 64),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 40,
                  left: 32,
                  right: 32,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Sos()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Having an Emergency?',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
