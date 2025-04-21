import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class Sos extends StatefulWidget {
  const Sos({super.key});

  @override
  State<Sos> createState() => _SosState();
}

class _SosState extends State<Sos> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSosDialog();
    });
  }

  Future<void> _showSosDialog() async {
    int countdown = 5;
    bool cancelled = false;
    String selectedOption = 'Police';
    late StateSetter localSetState;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Timer.periodic(const Duration(seconds: 1), (timer) async {
          if (cancelled) {
            timer.cancel();
          } else if (countdown > 1) {
            countdown--;
            localSetState(() {});
          } else {
            timer.cancel();
            Navigator.of(context).pop();
            final uri = selectedOption == 'Police'
                ? Uri.parse('tel:119')
                : Uri.parse('tel:1990');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Could not place the call"),
                ),
              );
            }
            Navigator.pop(context); // pop Sos page too
          }
        });

        return StatefulBuilder(
          builder: (context, setState) {
            localSetState = setState;
            return AlertDialog(
              backgroundColor: Colors.red.shade50,
              title: const Text(
                "🚨 Emergency Call",
                style: TextStyle(color: Colors.red),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Select the service you want to call:"),
                  DropdownButton<String>(
                    value: selectedOption,
                    items: ['Police', 'Ambulance'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedOption = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Calling $selectedOption in $countdown seconds...",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    cancelled = true;
                    Navigator.of(context).pop();
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
    );
  }
}
