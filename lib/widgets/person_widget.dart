import 'package:flutter/material.dart';
import 'package:myfinance_app/utils/keys.dart';
import 'package:myfinance_app/utils/models.dart';
import 'package:myfinance_app/utils/static.dart';

import 'card_widget.dart';

class PersonWidget extends StatelessWidget {

  final Person person;

  const PersonWidget({Key key, this.person}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final amount = person.amount;

    return CardWidget(
      id: person.name,
      title: person.name,
      amount: amount,
      subInfo: person.categories.map((category) {
        final amount = category.getBillForPerson(person.name);
        return SubInfo(category.name, amount);
      }).toList(),
      onTap: () => null,
      onLongPress: () => null,
    );
  }
}
