import 'package:flutter/material.dart';
import 'package:menu/main.dart';

import '../model/user.dart';
import 'loader_widget.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({Key? key}) : super(key: key);

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  late ScrollController controller;
  var sortAfter = "name";

  @override
  void initState() {
    controller = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Text(
                "Nutzer Management",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              OutlinedButton(
                onPressed: () async {
                  var name = "";
                  var lastName = "";
                  var password = "";
                  String type = "student";
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
                                      label: Text("Vorname"),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextField(
                                    onChanged: (value) => lastName = value,
                                    decoration: const InputDecoration(
                                      label: Text("Nachname"),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextField(
                                    obscureText: true,
                                    onChanged: (value) => password = value,
                                    decoration: const InputDecoration(
                                      label: Text("Vorläufiges Passwort"),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  DropdownButton<String>(
                                    value: type,
                                    items: const <DropdownMenuItem<String>>[
                                      DropdownMenuItem<String>(
                                        child: Text("Schüler"),
                                        value: "student",
                                      ),
                                      DropdownMenuItem<String>(
                                        child: Text("Lehrer"),
                                        value: "teacher",
                                      ),
                                      DropdownMenuItem<String>(
                                        child: Text("Admin/Koch"),
                                        value: "cook",
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
                    await dbController.addUser(name, lastName, type, password);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nutzer hinzugefügt.'),
                      ),
                    );
                    setState(() {});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nutzer nicht hinzugefügt.'),
                      ),
                    );
                  }
                },
                child: const Text('Nutzer hinzufügen'),
              ),
            ],
          ),
        ),
        FutureBuilder<List<User>>(
          future: dbController.getAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Scrollbar(
                controller: controller,
                child: SingleChildScrollView(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: _generateColumns(),
                    rows: _generateRows(snapshot.data!, context),
                  ),
                ),
              );
            } else {
              return Loader(
                height: 500,
                width: MediaQuery.of(context).size.width,
              );
            }
          },
        ),
      ],
    );
  }

  List<DataRow> _generateRows(List<User> users, context) {
    if (sortAfter == "name") {
      users.sort((a, b) => a.name.compareTo(b.name));
    } else if (sortAfter == "lastName") {
      users.sort((a, b) => a.lastName.compareTo(b.lastName));
    }

    List<DataRow> rows = [];
    for (var user in users) {
      rows.add(
        DataRow(
          cells: [
            DataCell(Text(user.name)),
            DataCell(Text(user.lastName)),
            DataCell(Text(user.email ?? "")),
            DataCell(Icon(user.onboard ? Icons.done : Icons.close)),
            DataCell(Text(user.tokens.toString())),
            DataCell(Text(user.userType ?? "")),
            DataCell(Text(user.preference ?? "Keine")),
            DataCell(
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Ändere Passwort von Nutzer: ${user.name} ${user.lastName}'),
                        ),
                      );
                      var newPassword = "";
                      await showDialog(
                        context: context,
                        builder: (context) => SimpleDialog(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                obscureText: true,
                                onChanged: (value) => newPassword = value,
                                decoration: const InputDecoration(
                                  label: Text("Neues Passwort"),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Weiter'),
                                ),
                                const SizedBox(width: 12),
                                TextButton(
                                  onPressed: () {
                                    newPassword = "";
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
                      if (newPassword.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Passwort nicht geändert.'),
                          ),
                        );
                        return;
                      }
                      await dbController.resetPassword(
                          user.name, user.lastName, newPassword);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Passwort geändert.'),
                        ),
                      );
                    },
                    child: const Text('Passwort ändern'),
                  ),
                  const SizedBox(width: 4),
                  OutlinedButton(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Lösche Nutzer: ${user.name} ${user.lastName}'),
                        ),
                      );
                      await dbController.deleteUser(user.name, user.lastName);
                      setState(() {});
                    },
                    child: const Text('Löschen'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return rows;
  }

  List<DataColumn> _generateColumns() {
    return [
      DataColumn(
        label: Row(
          children: [
            const Text('Vorname'),
            if (sortAfter == "name") const Icon(Icons.arrow_downward),
          ],
        ),
        onSort: (columnIndex, ascending) {
          setState(() {
            sortAfter = "name";
          });
        },
      ),
      DataColumn(
        label: Row(
          children: [
            const Text('Nachname'),
            if (sortAfter == "lastName") const Icon(Icons.arrow_downward),
          ],
        ),
        onSort: (columnIndex, ascending) {
          setState(() {
            sortAfter = "lastName";
          });
        },
      ),
      const DataColumn(
        label: Text('E-Mail'),
      ),
      const DataColumn(
        label: Text('Vollständig'),
      ),
      const DataColumn(
        label: Text('Marken'),
        numeric: true,
      ),
      const DataColumn(
        label: Text('Typ'),
      ),
      const DataColumn(
        label: Text('Vorliebe'),
      ),
      const DataColumn(
        label: Text('Aktionen'),
      ),
    ];
  }
}
