import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../shared/widgets/index.dart';

/// Generic in-app browser for the BuildWise website pages (Privacy Policy,
/// Terms & Conditions, Contact Support). Requires internet — these pages are
/// hosted online, unlike the rest of the offline-first app.
class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          // Hand off non-web schemes (mailto:, tel:, etc.) to the OS — the
          // WebView can't load them and would otherwise report a load error.
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            final scheme = uri?.scheme ?? '';
            if (scheme != 'http' && scheme != 'https') {
              if (uri != null) {
                launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _loading = true;
                _error = false;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            // Ignore sub-resource failures; only flag main-page load errors.
            if ((error.isForMainFrame ?? true) && mounted) {
              setState(() {
                _loading = false;
                _error = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _reload() {
    setState(() {
      _loading = true;
      _error = false;
    });
    _controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(title: widget.title),
      body: Stack(
        children: [
          if (!_error) WebViewWidget(controller: _controller),
          if (_error)
            AppErrorState(
              message: 'Could not load the page. Check your internet '
                  'connection and try again.',
              onRetry: _reload,
            ),
          if (_loading && !_error) const AppLoadingWidget(),
        ],
      ),
    );
  }
}
