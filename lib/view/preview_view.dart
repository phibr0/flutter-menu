import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:menu/components/profile_icon_widget.dart';
import 'package:menu/main.dart';
import 'package:menu/util.dart';

import '../components/loader_widget.dart';
import '../controller/database_controller.dart';

class PreviewView extends StatelessWidget {
  PreviewView({Key? key}) : super(key: key);
  final controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vorschau',
                style: Theme.of(context).textTheme.headline3,
              ),
              const ProfileIcon(),
            ],
          ),
          const SizedBox(height: 24),
          FutureBuilder<List<PreviewItem>>(
            future: dbController.menuOfWeek(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return Scrollbar(
                  controller: controller,
                  child: SingleChildScrollView(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        for (var item in snapshot.data!)
                          DataColumn(
                            tooltip: DateFormat.yMEd().format(item.date),
                            label: Text(
                              DateFormat("EEEE").format(item.date),
                            ),
                          ),
                      ],
                      rows: _computeRows(snapshot.data!, context),
                    ),
                  ),
                );
              } else {
                return Loader(
                  height: 250,
                  width: MediaQuery.of(context).size.width,
                );
              }
            },
          )
        ],
      ),
    );
  }

  List<DataRow> _computeRows(List<PreviewItem> list, BuildContext context) {
    List<DataRow> rows = [];
    int maxDepth = 0;

    for (var element in list) {
      if (element.menus.length > maxDepth) {
        maxDepth = element.menus.length;
      }
    }

    for (int i = 0; i < maxDepth; i++) {
      rows.add(
        DataRow(
          cells: [
            for (var item in list)
              if (i < item.menus.length)
                DataCell(
                  Hero(
                    tag: item.menus[i].name,
                    child: Text(item.menus[i].name),
                  ),
                  onTap: () => showModalBottomSheet(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    context: context,
                    builder: (context) {
                      final menu = item.menus[i];
                      return Container(
                        height: 250,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Hero(
                                  tag: menu.name,
                                  child: Text(
                                    menu.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                ),
                                if (menu.type != null)
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: typeToColor(menu.type!),
                                    ),
                                    child: Text(
                                      menu.type!.toUpperCase(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(menu.description)
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                DataCell.empty
          ],
        ),
      );
    }

    return rows;
  }
}
