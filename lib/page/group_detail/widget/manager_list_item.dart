import 'package:flutter/material.dart';

class ManagerListItem extends StatelessWidget {
  final String managerEmail;
  const ManagerListItem({super.key, required this.managerEmail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          const Icon(Icons.military_tech),
          Text(
            managerEmail,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
