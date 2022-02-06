import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:menu/components/user_management_widget.dart';
import 'package:menu/components/user_statistics_widget.dart';
import 'package:menu/util.dart';
import '../components/menu_management_widget.dart';
import '../components/profile_icon_widget.dart';
import '../main.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headline3,
                ),
                const ProfileIcon(),
              ],
            ),
          ),
          const TabBar(
            tabs: [
              Tab(
                  icon: Icon(
                Icons.calculate_outlined,
                color: Colors.blue,
              )),
              Tab(
                  icon: Icon(
                Icons.fastfood_outlined,
                color: Colors.blue,
              )),
              Tab(
                  icon: Icon(
                Icons.contact_page_outlined,
                color: Colors.blue,
              )),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                UserStatistics(),
                MenuManagement(),
                UserManagement(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
