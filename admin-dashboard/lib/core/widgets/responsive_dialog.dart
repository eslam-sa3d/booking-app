import 'package:flutter/material.dart';

import '../theme/breakpoints.dart';

/// Drop-in replacement for the `AlertDialog(title:, content:, actions:)`
/// shape used by every create/edit form dialog in the admin dashboard.
/// Desktop/tablet keeps today's capped-width dialog look unchanged; mobile
/// renders as a full-screen [Dialog.fullscreen] instead, since these are
/// multi-field forms that would be too cramped in a bottom sheet or a
/// narrow dialog.
///
/// [content] must own its own scrolling (wrap its form `Column` in a
/// [SingleChildScrollView] itself) — this shell does not add one, since
/// nesting a second [SingleChildScrollView] around a child that already
/// scrolls hits Flutter's "unbounded height" viewport error.
class ResponsiveDialogShell extends StatelessWidget {
  const ResponsiveDialogShell({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.desktopWidth = 480,
    this.desktopHeight,
  });

  final String title;
  final Widget content;
  final List<Widget> actions;
  final double desktopWidth;

  /// Only applied on the desktop path — some dialogs (e.g. one with an
  /// internal scrollable list) need a bounded height there. Mobile's
  /// [Dialog.fullscreen] body already has full available height, so this
  /// is never needed on that path.
  final double? desktopHeight;

  @override
  Widget build(BuildContext context) {
    if (!context.isMobile) {
      return AlertDialog(
        title: Text(title),
        content: SizedBox(width: desktopWidth, height: desktopHeight, child: content),
        actions: actions,
      );
    }

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Padding(padding: const EdgeInsets.all(16), child: content),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
          ),
        ),
      ),
    );
  }
}
