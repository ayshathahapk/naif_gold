// import 'package:flutter/material.dart';
//
// class Call extends StatefulWidget {
//   const Call({super.key});
//
//   @override
//   State<Call> createState() => _CallState();
// }
//
// class _CallState extends State<Call> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: Container(
//           child: Row(
//             children: [
//               Text("97142225540",style: TextStyle(
//                 color: Colors.grey
//               ),),
//             ],
//           ),
//         ),
//       ),
//     );
//
//   }
// }
//
//
//


import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  double _progress=0;
  final uri = Uri.parse("https://aurifyae.github.io/naifgold-app/aboutus");
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

