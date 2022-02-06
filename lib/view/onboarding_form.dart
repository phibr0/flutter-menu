import 'package:flutter/material.dart';
import 'package:menu/main.dart';

import '../controller/database_controller.dart';
import 'home_screen.dart';

class OnboardingForm extends StatefulWidget {
  final PageController controller;

  const OnboardingForm(this.controller, {Key? key}) : super(key: key);

  @override
  _OnboardingFormState createState() => _OnboardingFormState();
}

class _OnboardingFormState extends State<OnboardingForm> {
  String email = '';
  String password = '';
  String? preference;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Profil vervollständigen',
            style: Theme.of(context).textTheme.headline3),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  helperText: 'E-Mail',
                  hintText: 'du@provider.de',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte gib hier deine E-Mail Adresse ein.';
                  }
                  if (RegExp(r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$')
                          .firstMatch(value) ==
                      null) {
                    return 'Bitte überprüfe deine E-Mail Adresse.';
                  }
                  return null;
                },
                onSaved: (value) => email = value ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  helperText: 'Neues Passwort',
                  hintText: '_sicheres[Passwort.892',
                ),
                obscureText: true,
                autocorrect: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte gib hier ein neues Passwort ein.';
                  }
                  return null;
                },
                onSaved: (value) => password = value ?? '',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(
                    value: null,
                    child: Text('Keine Vorliebe'),
                  ),
                  DropdownMenuItem(
                    value: 'vegetarian',
                    child: Text('Vegetarisch'),
                  ),
                  DropdownMenuItem(
                    value: 'vegan',
                    child: Text('Vegan'),
                  ),
                  DropdownMenuItem(
                    value: 'halal',
                    child: Text('Halal'),
                  ),
                ],
                onChanged: (String? value) => preference = value,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Verarbeite Daten')),
                    );

                    _formKey.currentState!.save();
                    await dbController.onboardUser(preference, email, password);
                    await storage.write(key: 'user_password', value: password);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomeScreen(user: user!)),
                    );
                  }
                },
                child: const Text('Einloggen'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
