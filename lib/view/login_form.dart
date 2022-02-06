import 'package:flutter/material.dart';
import 'package:menu/main.dart';

import '../model/user.dart';
import 'home_screen.dart';

class LoginForm extends StatefulWidget {
  final PageController controller;

  const LoginForm(this.controller, {Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String lastName = '';
  String password = '';
  bool failed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Einloggen', style: Theme.of(context).textTheme.headline3),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  helperText: 'Vorname',
                  hintText: 'Max',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte gib hier deinen Vornamen ein.';
                  }
                  if (failed) {
                    return 'Passwort oder Benutzername falsch';
                  }
                  return null;
                },
                onSaved: (value) => name = value ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  helperText: 'Nachname',
                  hintText: 'Mustermann',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte gib hier deinen Nachnamen ein.';
                  }
                  if (failed) {
                    return 'Passwort oder Benutzername falsch';
                  }
                  return null;
                },
                onSaved: (value) => lastName = value ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  helperText: 'Passwort',
                ),
                obscureText: true,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte gib hier dein Passwort ein.';
                  }
                  if (failed) {
                    return 'Passwort oder Benutzername falsch';
                  }
                  return null;
                },
                onSaved: (value) => password = value ?? '',
              ),
              ElevatedButton(
                onPressed: () async {
                  failed = false;
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Verarbeite Daten')),
                    );

                    _formKey.currentState!.save();

                    User user;
                    try {
                      user = await dbController
                          .getUserData(name, lastName, password, force: true);
                    } catch (e) {
                      failed = true;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                      _formKey.currentState!.validate();
                      return;
                    }

                    await storage.write(key: 'user_name', value: name);
                    await storage.write(key: 'user_last_name', value: lastName);

                    if (!user.onboard) {
                      widget.controller.jumpToPage(1);
                    } else {
                      await storage.write(
                          key: 'user_password', value: password);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(user: user),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Einloggen'),
              ),
            ],
          ),
        )
      ],
    );
  }
}
