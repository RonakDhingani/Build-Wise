import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final int projectId;
  const SettingsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Settings — Phase 2')),
    );
  }
}
