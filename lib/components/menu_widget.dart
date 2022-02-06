import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:menu/model/menu.dart';

class MenuWidget extends StatelessWidget {
  const MenuWidget({Key? key, required this.menu, required this.handleOrder})
      : super(key: key);
  final Menu menu;
  final Function handleOrder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => handleOrder(menu, context),
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 212, 212, 212),
          borderRadius: BorderRadius.all(
            Radius.circular(6),
          ),
        ),
        height: 120,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              menu.name,
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 8),
            Text(
              menu.description,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            _getType(menu.type)
          ],
        ),
      ),
    );
  }

  Widget _getType(String? type) {
    switch (type) {
      case 'vegetarian':
        return Expanded(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Transform.rotate(
              child: const FaIcon(
                FontAwesomeIcons.seedling,
                color: Colors.green,
                size: 64,
              ),
              angle: -.3,
            ),
          ),
        );
      case 'vegan':
        return Expanded(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Transform.rotate(
              child: const FaIcon(
                FontAwesomeIcons.leaf,
                color: Colors.green,
                size: 64,
              ),
              angle: -.3,
            ),
          ),
        );
      case 'halal':
        return Expanded(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Transform.rotate(
              child: FaIcon(
                FontAwesomeIcons.drumstickBite,
                color: Colors.red[600],
                size: 64,
              ),
              angle: -.3,
            ),
          ),
        );
      default:
        return Container();
    }
  }
}
