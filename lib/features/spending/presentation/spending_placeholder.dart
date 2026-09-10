import 'package:flutter/material.dart';

import '../../../shared/widgets/module_placeholder.dart';

class SpendingPlaceholder extends StatelessWidget {
  const SpendingPlaceholder({this.desktop = false, super.key});

  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return ModulePlaceholder(
      desktop: desktop,
      title: 'Spending',
      subtitle: 'Perspective on the everyday',
      headline: 'A clearer view of your spending.',
      description:
          'Give everyday expenses a place of their own. '
          'A simple overview is coming to this space.',
      icon: Icons.account_balance_wallet_outlined,
      color: Color(0xFF4779A1),
      previewLabels: ['Expenses', 'Overview'],
    );
  }
}
