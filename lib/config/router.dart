import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tourism_app/Screens/home.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const Home()),
     ],
);
