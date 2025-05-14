import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItenaryCard extends StatefulWidget {
  final String destination;
  final String interest;
  final int duration;
  final String startDate;

  ItenaryCard({
    super.key,
    required this.destination,
    required this.interest,
    required this.duration,
    required this.startDate,
  });

  @override
  State<ItenaryCard> createState() => _ItenaryCardState();
}

class _ItenaryCardState extends State<ItenaryCard> {
  List<Map<String, dynamic>> itineraryData = [];
  bool isLoading = true;
  late PageController _pageController;
  int _currentPage = 0;

  Future<void> _loadItineraryData() async {
    try {
      print("Fetching itinerary for ${widget.destination}/${widget.interest}");
      for (int i = 1; i <= widget.duration; i++) {
        print("Fetching Day $i...");
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('itinerary_data')
            .doc(widget.destination)
            .collection(widget.interest)
            .doc('Day$i')
            .get();

        if (doc.exists && doc.data() != null && (doc.data() as Map<String, dynamic>).isNotEmpty) {
          print("Day $i data found: ${doc.data()}");
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String imgUrl = data['ImgUrl'] ?? "https://via.placeholder.com/200";
          print("Image URL for Day $i: $imgUrl");
          itineraryData.add({
            "day": 'Day $i',
            "imgUrl": imgUrl,
            "mainAttraction": data['Main Attraction'] ?? "No Attraction",
            "description": data['Small Description'] ?? "No description available",
            "activities": data['Activities'] ?? ["No activities available"],
          });
        } else {
          print("Day $i has no data, using placeholder");
          itineraryData.add({
            "day": 'Day $i',
            "imgUrl": "https://via.placeholder.com/200",
            "mainAttraction": "Not Available",
            "description": "Itinerary data not available for this day.",
            "activities": ["No activities planned."],
          });
        }
      }
      print("Itinerary data loaded: $itineraryData");
    } catch (e) {
      print("Error loading itinerary data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load itinerary: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadItineraryData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_currentPage < itineraryData.length - 1) {
      setState(() {
        _currentPage++;
      });
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Itinerary"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : itineraryData.isEmpty
                ? const Center(child: Text("No itinerary data available"))
                : Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemCount: itineraryData.length,
                          itemBuilder: (context, index) {
                            final data = itineraryData[index];
                            print("Rendering day: ${data['day']}");
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['day'].toUpperCase(),
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      data['mainAttraction'].toUpperCase(),
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        data['imgUrl'] ?? "https://via.placeholder.com/200",
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return const Center(child: CircularProgressIndicator());
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          print("Error loading image for ${data['day']}: $error (Stack: $stackTrace)");
                                          return Image.network(
                                            "https://via.placeholder.com/200",
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(Icons.broken_image, size: 50);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      data['description'],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Text(
                                          "🚶 ",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const Text(
                                          'Activities:',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    for (var activity in (data['activities'] as List<dynamic>))
                                      Text(
                                        '- $activity',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Navigation arrows below the card
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              onPressed: _previousPage,
                            ),
                            const SizedBox(width: 20), // Space between arrows
                            IconButton(
                              icon: Icon(Icons.arrow_forward_ios),
                              onPressed: _nextPage,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}