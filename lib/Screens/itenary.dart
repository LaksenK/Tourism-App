import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ItineraryGenerator extends StatefulWidget {
  @override
  _ItineraryGeneratorState createState() => _ItineraryGeneratorState();
}

class _ItineraryGeneratorState extends State<ItineraryGenerator> {
  String? _startPoint = "Colombo";
  String? _destination;
  DateTime _startDate = DateTime.now();
  String? _interest = "Cultural";
  int _duration = 2;
  String? _groupType = "Solo";

  final List<String> _destinations = ["Kandy", "Galle", "Jaffna"];
  final List<String> _interests = ["Cultural", "Wildlife", "Adventure"];
  final List<String> _groupTypes = ["Solo", "Couple", "Family", "Group"];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _generateItinerary() {
    if (_destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a destination")),
      );
      return;
    }
    print("Generating itinerary with: destination=$_destination, interest=$_interest, duration=$_duration, startDate=${DateFormat('yyyy-MM-dd').format(_startDate)}");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItenaryCard(
          destination: _destination!,
          interest: _interest!,
          duration: _duration,
          startDate: DateFormat('yyyy-MM-dd').format(_startDate),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Itinerary Generator"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Start Point",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _startPoint,
                onChanged: null,
                items: <String>["Colombo"]
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Destination",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _destination,
                onChanged: (String? newValue) {
                  setState(() {
                    _destination = newValue;
                  });
                },
                items: _destinations.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                hint: Text("Select a destination"),
              ),
              SizedBox(height: 16),
              Text(
                "Start Date",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                    controller: TextEditingController(
                      text: DateFormat('yyyy-MM-dd').format(_startDate),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Interest",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _interest,
                onChanged: (String? newValue) {
                  setState(() {
                    _interest = newValue;
                  });
                },
                items: _interests.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Duration (Days):",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: _duration > 1 ? () => setState(() => _duration--) : null,
                  ),
                  Text(_duration.toString()),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => setState(() => _duration++),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                "Group Type",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _groupType,
                onChanged: (String? newValue) {
                  setState(() {
                    _groupType = newValue;
                  });
                },
                items: _groupTypes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
              ),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _generateItinerary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  child: Text("Generate Itinerary"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItenaryCard extends StatefulWidget {
  final String destination;
  final String interest;
  final int duration;
  final String startDate;

  ItenaryCard({
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
  List<Map<String, dynamic>> reorderedItineraryData = [];
  List<Map<String, dynamic>> accommodationData = [];
  bool isItineraryLoading = true;
  bool isAccommodationLoading = true;
  late PageController _itineraryPageController;
  late PageController _accommodationPageController;
  int _currentItineraryPage = 0;
  int _currentAccommodationPage = 0;

  Future<void> _loadItineraryData() async {
    try {
      print("Fetching itinerary for ${widget.destination}/${widget.interest}");
      itineraryData.clear();
      reorderedItineraryData.clear();

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
            "originalDay": 'Day $i',
            "imgUrl": imgUrl,
            "mainAttraction": data['Main Attraction'] ?? "No Attraction",
            "description": data['Small Description'] ?? "No description available",
            "activities": data['Activities'] ?? ["No activities available"],
            "meal": data['Meal'] ?? "No meal specified",
            "mealLink": data['MealLink'] ?? "",
          });
        } else {
          print("Day $i has no data, using placeholder");
          itineraryData.add({
            "originalDay": 'Day $i',
            "imgUrl": "https://via.placeholder.com/200",
            "mainAttraction": "Not Available",
            "description": "Itinerary data not available for this day.",
            "activities": ["No activities planned."],
            "meal": "No meal specified",
            "mealLink": "",
          });
        }
      }
      print("Original itinerary data: $itineraryData");

      if (widget.duration == 1) {
        reorderedItineraryData.add(itineraryData[0]);
      } else if (widget.duration == 2) {
        reorderedItineraryData.add(itineraryData[0]);
        reorderedItineraryData.add(itineraryData[1]);
      } else if (widget.duration == 3) {
        reorderedItineraryData.add(itineraryData[2]);
        reorderedItineraryData.add(itineraryData[0]);
        reorderedItineraryData.add(itineraryData[1]);
      } else if (widget.duration == 4) {
        reorderedItineraryData.add(itineraryData[2]);
        reorderedItineraryData.add(itineraryData[0]);
        reorderedItineraryData.add(itineraryData[1]);
        reorderedItineraryData.add(itineraryData[3]);
      }

      print("Reordered itinerary data:");
      for (int i = 0; i < reorderedItineraryData.length; i++) {
        print("Card ${i + 1} (labeled as DAY ${i + 1}): Original ${reorderedItineraryData[i]['originalDay']}, Main Attraction: ${reorderedItineraryData[i]['mainAttraction']}");
      }
    } catch (e) {
      print("Error loading itinerary data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load itinerary: $e")),
      );
    } finally {
      setState(() {
        isItineraryLoading = false;
      });
    }
  }

  Future<void> _loadAccommodationData() async {
    try {
      print("Fetching accommodation for ${widget.destination}/Accommodation");
      accommodationData.clear();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('itinerary_data')
          .doc(widget.destination)
          .collection('Accommodation')
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("No accommodation documents found for ${widget.destination}");
      }

      for (var doc in querySnapshot.docs) {
        if (doc.exists && doc.data() != null && (doc.data() as Map<String, dynamic>).isNotEmpty) {
          print("Hotel data found: ${doc.data()}");
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String image = data['Image'] ?? "https://via.placeholder.com/200";
          String link = data['Link'] ?? "";
          accommodationData.add({
            "name": data['Name'] ?? "No Name",
            "image": image,
            "link": link,
            "ratings": (data['Ratings'] is num) ? data['Ratings'].toDouble() : 0.0,
            "location": data['Location'] ?? "Unknown",
          });
        } else {
          print("Document ${doc.id} has no valid data");
        }
      }
      print("Accommodation data: $accommodationData");
    } catch (e) {
      print("Error loading accommodation data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load accommodation: $e")),
      );
    } finally {
      setState(() {
        isAccommodationLoading = false;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch $url")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _itineraryPageController = PageController(initialPage: 0);
    _accommodationPageController = PageController(initialPage: 0);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadItineraryData(),
      _loadAccommodationData(),
    ]);
  }

  @override
  void dispose() {
    _itineraryPageController.dispose();
    _accommodationPageController.dispose();
    super.dispose();
  }

  void _previousItineraryPage() {
    if (_currentItineraryPage > 0) {
      setState(() {
        _currentItineraryPage--;
      });
      _itineraryPageController.animateToPage(
        _currentItineraryPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextItineraryPage() {
    if (_currentItineraryPage < reorderedItineraryData.length - 1) {
      setState(() {
        _currentItineraryPage++;
      });
      _itineraryPageController.animateToPage(
        _currentItineraryPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousAccommodationPage() {
    if (_currentAccommodationPage > 0) {
      setState(() {
        _currentAccommodationPage--;
      });
      _accommodationPageController.animateToPage(
        _currentAccommodationPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextAccommodationPage() {
    if (_currentAccommodationPage < accommodationData.length - 1) {
      setState(() {
        _currentAccommodationPage++;
      });
      _accommodationPageController.animateToPage(
        _currentAccommodationPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = isItineraryLoading || isAccommodationLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Itinerary"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Itinerary Section
                    Text(
                      "Itinerary",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 650,
                      child: reorderedItineraryData.isEmpty
                          ? const Center(child: Text("No itinerary data available"))
                          : PageView.builder(
                              controller: _itineraryPageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentItineraryPage = index;
                                });
                              },
                              itemCount: reorderedItineraryData.length,
                              itemBuilder: (context, index) {
                                final data = reorderedItineraryData[index];
                                print("Rendering itinerary card ${index + 1}: Original ${data['originalDay']}, Main Attraction: ${data['mainAttraction']}");
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                          'DAY ${index + 1}'.toUpperCase(),
                                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          '📍 ${data['mainAttraction'].toUpperCase()}',
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 15),
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
                                              print("Error loading image for ${data['originalDay']}: $error (Stack: $stackTrace)");
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
                                        const SizedBox(height: 15),
                                        Text(
                                          data['description'],
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 15),
                                        Row(
                                          children: [
                                            const Text(
                                              '🚶 ',
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
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Text(
                                              '- $activity',
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        const SizedBox(height: 15),
                                        Row(
                                          children: [
                                            const Text(
                                              '🍽️ ',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            const Text(
                                              'Meal Highlight:',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          data['meal'],
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(height: 10),
                                        if (data['mealLink'] != null && data['mealLink'].isNotEmpty)
                                          TextButton(
                                            onPressed: () => _launchURL(data['mealLink']),
                                            child: const Text(
                                              "View More Details ->",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: _previousItineraryPage,
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: Icon(Icons.arrow_forward_ios),
                            onPressed: _nextItineraryPage,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Accommodation Section
                    Text(
                      "Recommended Accommodations",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 400,
                      child: accommodationData.isEmpty
                          ? const Center(child: Text("No accommodation data available"))
                          : PageView.builder(
                              controller: _accommodationPageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentAccommodationPage = index;
                                });
                              },
                              itemCount: accommodationData.length,
                              itemBuilder: (context, index) {
                                final data = accommodationData[index];
                                print("Rendering accommodation card ${index + 1}: Name: ${data['name']}");
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Hotel Image
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                        ),
                                        child: Image.network(
                                          data['image'] ?? "https://via.placeholder.com/200",
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return const Center(child: CircularProgressIndicator());
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            print("Error loading image for ${data['name']}: $error (Stack: $stackTrace)");
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
                                      // Hotel Details
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'HOTEL ${index + 1}'.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              '🏨 ${data['name'].toUpperCase()}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 15),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.location_on,
                                                      size: 16,
                                                      color: Colors.grey,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      data['location'],
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.star,
                                                      size: 16,
                                                      color: Colors.yellow,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      "${data['ratings']}",
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 15),
                                            if (data['link'] != null && data['link'].isNotEmpty)
                                              Center(
                                                child: ElevatedButton(
                                                  onPressed: () => _launchURL(data['link']),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.blue,
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 20,
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    "Book Now",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            onPressed: _previousAccommodationPage,
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: Icon(Icons.arrow_forward_ios),
                            onPressed: _nextAccommodationPage,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}