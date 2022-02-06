import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../model/menu.dart';
import '../util.dart';
import 'loader_widget.dart';

class UserStatistics extends StatelessWidget {
  const UserStatistics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: (() {
        return Future.value(null);
      }),
      child: ListView(
        children: [
          FutureBuilder<Map<String, int>>(
              future: dbController.getOrderStats(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: _computeOrders(snapshot.data!),
                      ),
                    ),
                  );
                } else {
                  return const Loader(height: 150);
                }
              }),
          const SizedBox(height: 12),
          FutureBuilder<List<int>>(
            future: dbController.getPreferenceStats(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 400,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 212, 212, 212),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: PieChart(
                      PieChartData(
                        sections: _computeSeries(snapshot.data!),
                      ),
                    ),
                  ),
                );
              } else {
                return const Loader(height: 400);
              }
            },
          ),
          FutureBuilder<List<Menu>>(
            future: dbController.listAllMenus(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 212, 212, 212),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DataTable(
                      columns: const [
                        DataColumn(
                          label: Text('Gericht'),
                        ),
                        DataColumn(
                          label: Text('Sterne'),
                        ),
                      ],
                      rows: [
                        for (var menu in snapshot.data!)
                          DataRow(cells: [
                            DataCell(Text(menu.name)),
                            DataCell(Row(
                              children: [
                                for (int i = 0; i < menu.rating.round(); i++)
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  )
                              ],
                            ))
                          ])
                      ],
                    ),
                  ),
                );
              } else {
                return const Loader(height: 400);
              }
            },
          )
        ],
      ),
    );
  }

  List<Widget> _computeOrders(Map<String, int> data) {
    List<Widget> widgets = [];
    for (var key in data.keys) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            height: 150,
            width: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 212, 212, 212),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  key,
                  textAlign: TextAlign.center,
                ),
                Text(
                  data[key].toString(),
                  style: const TextStyle(
                    fontSize: 36,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  List<PieChartSectionData> _computeSeries(List<int> data) {
    List<PieChartSectionData> widgets = [];
    for (var i = 0; i < data.length; i++) {
      widgets.add(
        PieChartSectionData(
          value: data[i].toDouble(),
          color: idxToColor(i),
          title: _idxToLabel(i),
        ),
      );
    }
    return widgets;
  }

  String _idxToLabel(int idx) {
    switch (idx) {
      case 0:
        return 'Keine Preferenz';
      case 1:
        return 'Halal';
      case 2:
        return 'Vegetarisch';
      case 3:
        return 'Vegan';
      default:
        return '';
    }
  }
}
