import 'package:flutter/material.dart';
import 'package:menu/main.dart';
import 'package:menu/model/user.dart';
import 'package:menu/view/preview_view.dart';
import 'package:menu/view/scanner_view.dart';

import 'dashboard_view.dart';
import 'order_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var viewIdx = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildView(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Bestellen',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Vorschau',
          ),
          if (widget.user.userType == 'cook')
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
          if (widget.user.userType == 'cook')
            const BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: 'Scanner',
            ),
        ],
        currentIndex: viewIdx,
        onTap: (idx) => setState(() => viewIdx = idx),
      ),
    );
  }

  _buildView() {
    switch (viewIdx) {
      case 0:
        return const OrderView();
      case 1:
        return PreviewView();
      case 2:
        return const DashboardView();
      case 3:
        return const ScannerView();
      default:
        return Container();
    }
  }
}
