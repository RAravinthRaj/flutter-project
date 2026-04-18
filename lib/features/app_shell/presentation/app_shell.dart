import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/gradient_scaffold.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  static const _tabs = [
    ('/home', 'Dump', Icons.edit_note_rounded),
    ('/categories', 'Browse', Icons.dashboard_customize_outlined),
    ('/insights', 'Insights', Icons.insights_rounded),
    ('/profile', 'Profile', Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _tabs.indexWhere(
      (tab) => location.startsWith(tab.$1),
    );
    final currentIndex = selectedIndex == -1 ? 0 : selectedIndex;

    return GradientScaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          context.go(_tabs[index].$1);
        },
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(icon: Icon(tab.$3), label: tab.$2),
        ],
      ),
    );
  }
}
