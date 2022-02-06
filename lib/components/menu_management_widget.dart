import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu/main.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../controller/database_controller.dart';
import '../model/menu.dart';
import '../util.dart';
import 'loader_widget.dart';

class MenuManagement extends StatefulWidget {
  const MenuManagement({Key? key}) : super(key: key);

  @override
  State<MenuManagement> createState() => _MenuManagementState();
}

class _MenuManagementState extends State<MenuManagement> {
  final controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Mensa Management",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              OutlinedButton(
                onPressed: () async {
                  var name = "";
                  var description = "";
                  String? type;
                  var add = false;
                  await showDialog(
                    context: context,
                    builder: (context) => SimpleDialog(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: StatefulBuilder(
                            builder: (context, setState) {
                              return Column(
                                children: [
                                  TextField(
                                    onChanged: (value) => name = value,
                                    decoration: const InputDecoration(
                                      label: Text("Name"),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextField(
                                    onChanged: (value) => description = value,
                                    decoration: const InputDecoration(
                                      label: Text("Beschreibung"),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  DropdownButton<String>(
                                    value: type,
                                    items: const <DropdownMenuItem<String>>[
                                      DropdownMenuItem<String>(
                                        child: Text("/"),
                                        value: null,
                                      ),
                                      DropdownMenuItem<String>(
                                        child: Text("Vegetarisch"),
                                        value: "vegetarian",
                                      ),
                                      DropdownMenuItem<String>(
                                        child: Text("Vegan"),
                                        value: "vegan",
                                      ),
                                      DropdownMenuItem<String>(
                                        child: Text("Halal"),
                                        value: "halal",
                                      ),
                                    ],
                                    onChanged: (value) =>
                                        setState(() => type = value!),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                add = true;
                                Navigator.pop(context);
                              },
                              child: const Text('Hinzufügen'),
                            ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Abbrechen'),
                            ),
                            const SizedBox(width: 24),
                          ],
                        ),
                      ],
                    ),
                  );
                  if (add) {
                    await dbController.addMenu(name, description, type);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gericht hinzugefügt.'),
                      ),
                    );
                    setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gericht nicht hinzugefügt.'),
                      ),
                    );
                  }
                },
                child: const Text('Gericht hinzufügen'),
              ),
            ],
          ),
        ),
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

    for (int i = 0; i < maxDepth + 1; i++) {
      rows.add(
        DataRow(
          cells: [
            for (var item in list)
              if (i < item.menus.length)
                DataCell(
                  Text(item.menus[i].name),
                  onTap: () async {
                    await dbController.removeMenuOfPreview(
                        item.date, item.menus[i].id);
                    setState(() {});
                  },
                )
              else if (i == item.menus.length)
                DataCell(
                  const Center(
                    child: Icon(Icons.add),
                  ),
                  onTap: (() async {
                    var menu = "";
                    var searchStr = "";
                    await showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StatefulBuilder(
                            builder: (context, setState) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Welches Gericht soll am ${DateFormat.yMMMEd().format(item.date)} angeboten werden?',
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  decoration: const InputDecoration(
                                    label: Text('Suche'),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) =>
                                      setState(() => searchStr = value),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 220,
                                  child: FutureBuilder<List<Menu>>(
                                    future: dbController.listAllMenus(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        var data = snapshot.data!
                                            .where(
                                              (e) =>
                                                  e.name.toLowerCase().contains(
                                                        searchStr.toLowerCase(),
                                                      ),
                                            )
                                            .toList();
                                        return ListView.builder(
                                          itemCount: data.length,
                                          itemBuilder: (context, idx) {
                                            return ListTile(
                                              title: Text(
                                                data[idx].name,
                                              ),
                                              subtitle: Text(
                                                data[idx].description,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              trailing: Text(
                                                data[idx]
                                                    .rating
                                                    .round()
                                                    .toString(),
                                              ),
                                              onTap: () {
                                                menu = data[idx].id;
                                                Navigator.of(context).pop();
                                              },
                                            );
                                          },
                                        );
                                      }
                                      return const Loader(height: 250);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Abbrechen'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                    if (menu.isEmpty) {
                      return;
                    }
                    await dbController.addMenuToPreview(item.date, menu);
                    setState(() {});
                  }),
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
