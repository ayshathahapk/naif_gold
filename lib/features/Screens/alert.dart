import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';


class Ratealert extends StatefulWidget {
  const Ratealert({super.key});

  @override
  State<Ratealert> createState() => _RatealertState();
}

class _RatealertState extends State<Ratealert> {
  double _progress=0;
  final uri = Uri.parse("https://aurifyae.github.io/naifgold-app/ratealert");
  // WebViewController _controller=WebViewController(onPermissionRequest: );
  late InAppWebViewController inAppWebViewController;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri.uri(uri),
              ),
              onWebViewCreated: (controller) {
                inAppWebViewController = controller;
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
