import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:menu/main.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter/material.dart';

import '../model/menu.dart';

class ScannerView extends StatelessWidget {
  const ScannerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      return const QRViewExample();
    } else {
      return const Center(
        child: Text('Diese Funktion ist nur in der mobilen Version verfügbar.'),
      );
    }
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  _QRViewExampleState createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  String? userID;
  String? orderID;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? FutureBuilder<Menu>(
                      future: dbController.getMenuOfId(orderID!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data!.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    )
                  : const Text('Scanne eine Marke'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (result?.code != scanData.code) {
        HapticFeedback.vibrate();
        Map json;
        try {
          json = jsonDecode(scanData.code!);
        } catch (e) {
          return;
        }
        setState(() {
          result = scanData;
          orderID = json['orderId'];
          userID = json['userId'];
        });
        await dbController.removeOrderOfUser(json['userId']);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
