import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// The admin dashboard's Firebase Hosting URL (admin-dashboard/firebase.json).
// Update this if a custom domain is ever configured for the dashboard.
const String kAdminDashboardUrl = 'https://booking-app-36b8e.web.app';
final Uri _kAllowedHost = Uri.parse(kAdminDashboardUrl);

/// Keeps the app locked to the admin dashboard's own host. Anything else
/// (e.g. an external link inside the dashboard) is rejected rather than
/// turning this into a general-purpose browser.
bool isAllowedNavigation(String url) {
  final uri = Uri.tryParse(url);
  return uri != null && uri.host == _kAllowedHost.host;
}

void main() {
  runApp(const BookingAdminApp());
}

class BookingAdminApp extends StatelessWidget {
  const BookingAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Booking Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AdminWebViewScreen(),
    );
  }
}

class AdminWebViewScreen extends StatefulWidget {
  const AdminWebViewScreen({super.key});

  @override
  State<AdminWebViewScreen> createState() => _AdminWebViewScreenState();
}

class _AdminWebViewScreenState extends State<AdminWebViewScreen> {
  late final WebViewController _controller;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  bool _isOffline = false;
  bool _isLoading = true;
  double _loadProgress = 0;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _controller = _buildController();
    _connectivitySub =
        _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
    _connectivity.checkConnectivity().then(_handleConnectivityChange);
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  WebViewController _buildController() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setOnConsoleMessage((message) {
        // ignore: avoid_print
        print('[webview console] ${message.level}: ${message.message}');
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() => _loadProgress = progress / 100);
          },
          onPageStarted: (_) {
            setState(() {
              _isLoading = true;
              _loadError = null;
            });
          },
          onPageFinished: (_) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            // Ignore sub-resource errors (fonts, analytics, etc.) and only
            // surface a retry screen when the main frame itself fails to load.
            if (error.isForMainFrame ?? true) {
              setState(() {
                _isLoading = false;
                _loadError = error.description;
              });
            }
          },
          onNavigationRequest: (request) {
            if (isAllowedNavigation(request.url)) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(kAdminDashboardUrl));
    return controller;
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final offline =
        results.isEmpty || results.every((r) => r == ConnectivityResult.none);
    if (offline == _isOffline) return;
    setState(() => _isOffline = offline);
    if (!offline) {
      _controller.reload();
    }
  }

  Future<bool> _handleBackNavigation() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handleBackNavigation();
        if (!context.mounted || !shouldPop) return;
        Navigator.of(context).maybePop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Booking Admin'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () => _controller.reload(),
            ),
          ],
          bottom: _isLoading
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: LinearProgressIndicator(value: _loadProgress),
                )
              : null,
        ),
        body: _isOffline
            ? _OfflineView(
                onRetry: () => _connectivity
                    .checkConnectivity()
                    .then(_handleConnectivityChange),
              )
            : _loadError != null
                ? _ErrorView(
                    message: _loadError!,
                    onRetry: () => _controller.reload(),
                  )
                : WebViewWidget(controller: _controller),
      ),
    );
  }
}

class _OfflineView extends StatelessWidget {
  const _OfflineView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No internet connection'),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "Couldn't load the dashboard.\n$message",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
