import 'package:flutter/material.dart';
import 'package:tourism_app/Screens/guides.dart';
import 'package:tourism_app/components/navbar.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: NavBar(),
    ),
    body: Column(
      children: [
        ElevatedButton(onPressed: (){Navigator.push(context,MaterialPageRoute(builder: (context)=>GuidesPage()) );}, child: Text('Find a Guide'))
      ],
    ),
    
  );
  }
}