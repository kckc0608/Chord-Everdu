import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String data;
  const SectionTitle(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(data, style: Theme.of(context).textTheme.displayLarge),
    );
  }
}
