import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:menu/components/menu_widget.dart';
import 'package:menu/components/profile_icon_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../components/loader_widget.dart';
import '../controller/database_controller.dart';
import '../main.dart';
import '../model/menu.dart';
import '../util.dart';

class OrderView extends StatefulWidget {
  const OrderView({Key? key}) : super(key: key);

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  var currentRating = 3;
  var rated = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menu',
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  const ProfileIcon(),
                ],
              ),
              const SizedBox(height: 24),
              if (user!.order != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(42),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 212, 212, 212),
                      ),
                      child: FutureBuilder<Menu>(
                        future: dbController.getMenuOfId(user!.order!),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  snapshot.data!.name,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  width: double.infinity,
                                  height: 24,
                                ),
                                QrImage(
                                  data: const JsonEncoder().convert({
                                    'userId': user!.id,
                                    'orderId': snapshot.data!.id
                                  }),
                                ),
                                const SizedBox(
                                  height: 24,
                                ),
                                if (!rated)
                                  OutlinedButton(
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (context) => SimpleDialog(
                                        title: const Center(
                                          child: Text(
                                              'Wie hat es dir geschmeckt?'),
                                        ),
                                        children: [
                                          Center(
                                            child: RatingBar.builder(
                                              initialRating:
                                                  currentRating.toDouble(),
                                              minRating: 1,
                                              direction: Axis.horizontal,
                                              itemCount: 5,
                                              itemPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              itemBuilder: (context, _) =>
                                                  const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              onRatingUpdate: (rating) {
                                                currentRating = rating.toInt();
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () async {
                                                  setState(() => rated = true);
                                                  Navigator.pop(context);
                                                  await dbController.rateMenu(
                                                      snapshot.data!.id,
                                                      currentRating);
                                                },
                                                child: const Text('Bewerten'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Abbrechen'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    child: const Text('Jetzt bewerten'),
                                  )
                              ],
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              if (user!.order == null)
                FutureBuilder<List<Menu>>(
                  future: dbController.menuOf(),
                  builder: (_, snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: ((_, index) => MenuWidget(
                                menu: snapshot.data![index],
                                handleOrder: _handleOrder,
                              )),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        Loader(
                          height: 125,
                          width: MediaQuery.of(context).size.width,
                        ),
                        Loader(
                          height: 125,
                          width: MediaQuery.of(context).size.width,
                        ),
                        Loader(
                          height: 125,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
          const Align(
            child: TokenCounter(),
            alignment: Alignment.bottomCenter,
          ),
        ],
      ),
    );
  }

  _handleOrder(Menu menu, BuildContext context) {
    if (user!.tokens != null && user!.tokens! < 1) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Du hast keine Marken mehr!'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: Text('${menu.name} bestellen?'),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                  'Bist du dir sicher, dass du ${menu.name} bestellen willst? '),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _getWarning(menu.type),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    dbController.order(menu.id);
                    setState(() {});
                  },
                  child: const Text('Ja'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Nein'),
                ),
                const SizedBox(width: 24),
              ],
            )
          ],
        ),
      );
    }
  }

  Widget _getWarning(String? type) {
    if (user!.preference == null) {
      return Container();
    }
    if (user!.preference == "halal" && type == null) {
      return Text(
        'Dieses Gericht könnte Schweinefleisch enthalten.',
        style: TextStyle(
          color: Colors.red[900],
        ),
      );
    }
    if ((user!.preference == "vegetarian" && type == null) ||
        (user!.preference == "vegetarian" && type == 'halal')) {
      return Text(
        'Dieses Gericht könnte Fleisch enthalten.',
        style: TextStyle(
          color: Colors.red[900],
        ),
      );
    }
    if ((user!.preference == "vegan" && type == null) ||
        (user!.preference == "vegan" && type == 'halal') ||
        (user!.preference == "vegan" && type == 'vegetarian')) {
      return Text(
        'Dieses Gericht könnte Tierprodukte enthalten.',
        style: TextStyle(
          color: Colors.red[900],
        ),
      );
    }
    return Container();
  }
}

class TokenCounter extends StatefulWidget {
  const TokenCounter({Key? key}) : super(key: key);

  @override
  TokenCounterState createState() => TokenCounterState();
}

class TokenCounterState extends State<TokenCounter> {
  double pos = 100;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => setState((() => pos = 0)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      transform: Matrix4.translationValues(0, pos, 0),
      child: Text('${user!.tokens.toString()} Marken verbleibend'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 212, 212, 212),
        borderRadius: BorderRadius.all(
          Radius.circular(100),
        ),
      ),
    );
  }
}

class OrderId {
  final String userId;
  final String orderId;

  const OrderId({required this.userId, required this.orderId});
}
