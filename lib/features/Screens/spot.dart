// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
//
// class Spot extends StatefulWidget {
//   const Spot({super.key});
//
//   @override
//   State<Spot> createState() => _SpotState();
// }
//
// class _SpotState extends State<Spot> {
//   double _progress=0;
//   final uri = Uri.parse("https://aurifyae.github.io/naifgold-app/");
//   late InAppWebViewController inAppWebViewController;
//
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Scaffold(
//           body: Stack(children: [
//             InAppWebView(
//               initialUrlRequest: URLRequest(
//                 url: WebUri.uri(uri),
//               ),
//               onWebViewCreated: (controller) {
//                 inAppWebViewController = controller;
//               },
//               onProgressChanged: (controller, progress) {
//                 _progress=progress/100;
//               },
//             ),
//             _progress<1?Container(child: LinearProgressIndicator(),):SizedBox()
//           ],),
//         )
//
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Spot extends StatefulWidget {
  const Spot({Key? key}) : super(key: key);

  @override
  State<Spot> createState() => _SpotState();
}

class _SpotState extends State<Spot> {
  double _progress = 0;
  final uri = Uri.parse("https://aurifyae.github.io/naifgold-app/");
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

