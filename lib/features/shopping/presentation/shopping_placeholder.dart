import 'package:flutter/material.dart';

import '../../../shared/widgets/module_placeholder.dart';

class ShoppingPlaceholder extends StatelessWidget {
  const ShoppingPlaceholder({this.desktop = false, super.key});

  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return ModulePlaceholder(
      desktop: desktop,
      title: 'Shopping',
      subtitle: 'The everyday essentials',
      headline: 'Remember the little things.',
      description:
          'A thoughtful place for what you need on your next trip. '
          'Your everyday lists will live here.',
      icon: Icons.shopping_bag_outlined,
      color: Color(0xFF9A6930),
      previewLabels: ['Shopping lists', 'Essentials'],
    );
  }
}
