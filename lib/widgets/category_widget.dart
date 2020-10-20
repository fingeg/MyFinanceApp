import 'package:flutter/material.dart';
import 'package:myfinance_app/pages/category/category_page.dart';
import 'package:myfinance_app/utils/models.dart';
import 'package:myfinance_app/widgets/card_widget.dart';

class CategoryWidget extends StatelessWidget {
  final Category category;

  const CategoryWidget({@required this.category, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final amount = category.amount;

    return CardWidget(
      id: category.id,
      title: category.name,
      amount: amount,
      subInfo: category.getAllPayers().map((payer) {
        final amount = category.getAmountForPerson(payer);
        return SubInfo(payer, amount);
      }).toList(),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CategoryPage(category: category))),
    );
  }
}
