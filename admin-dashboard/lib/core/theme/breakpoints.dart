import 'package:flutter/material.dart';

/// Layout width thresholds for the admin dashboard. Below [mobile], the app
/// switches to a Drawer-based nav and full-screen dialogs; from [mobile] up
/// to [desktop] the existing sidebar/two-pane layouts stay but their fixed
/// pixel widths flex instead of overflowing; at [desktop] and above nothing
/// changes from the original fixed-desktop layout.
class Breakpoints {
  Breakpoints._();

  static const double mobile = 700;
  static const double desktop = 1100;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isMobile => screenWidth < Breakpoints.mobile;
}
