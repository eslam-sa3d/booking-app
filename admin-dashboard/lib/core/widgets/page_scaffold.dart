import 'package:flutter/material.dart';

import '../theme/breakpoints.dart';

/// Consistent page header + scrollable, padded body used by every admin
/// dashboard screen (the sidebar itself lives in AppShell).
class AdminPageScaffold extends StatelessWidget {
  const AdminPageScaffold({super.key, required this.title, required this.body, this.actions});

  final String title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28, vertical: isMobile ? 14 : 20),
          decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
          child: isMobile && actions != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: actions!),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                    if (actions != null) ...actions!,
                  ],
                ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 28),
            child: body,
          ),
        ),
      ],
    );
  }
}
