import 'package:flutter/material.dart';
import 'package:myfinance_app/utils/localizations.dart';
import 'package:myfinance_app/utils/models.dart';

class CategoryPage extends StatefulWidget {
  final Category category;

  const CategoryPage({@required this.category, Key key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    final amount = widget.category.amount;
    final payers = widget.category
        .getAllPayers()
        .map((p) => _TableRow(p, widget.category.getAmountForPerson(p)))
        .toList();

    final payments = widget.category.payments
        .where((p) => !p.payed)
        .map((p) => _TableRow(p.name, p.amount))
        .toList();

    final pendingInvoices = widget.category.splits
        .map((p) => _TableRow(p.username, amount * p.share))
        .toList();

    if (payers.isEmpty) {
      payers.add(_TableRow('-', 0));
    }
    if (payments.isEmpty) {
      payments.add(_TableRow('-', 0));
    }
    if (pendingInvoices.isEmpty) {
      pendingInvoices.add(_TableRow('-', 0));
    }

    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: '${widget.category.id}-title',
          child: Text(
            widget.category.name,
            style: TextStyle(
              fontWeight: FontWeight.w100,
              fontSize: 25,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Center(
              child: Text(
                '${amount < 0 ? '-' : '+'} ${amount.toStringAsFixed(2).replaceAll('-', '')}€',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              if (widget.category.isSplit)
                CardTable(
                  header: MyFinanceLocalizations.of(context).pendingInvoices,
                  rows: payers,
                ),
              CardTable(
                header: MyFinanceLocalizations.of(context).payers,
                rows: payers,
              ),
              CardTable(
                header: MyFinanceLocalizations.of(context).payments,
                rows: payments,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardTable extends StatelessWidget {
  final String header;
  final List<_TableRow> rows;

  const CardTable({Key key, this.header, this.rows}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Table(
            columnWidths: {0: FlexColumnWidth(1), 1: FixedColumnWidth(100)},
            border: TableBorder(
              verticalInside: BorderSide(
                color: Theme.of(context).textTheme.headline1.color,
                width: 0.3,
              ),
            ),
            children: [
              TableRow(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).textTheme.headline1.color,
                      width: 0.3,
                    ),
                  ),
                ),
                children: [
                  Text(
                    header,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                  Text(
                    MyFinanceLocalizations.of(context).amount,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ],
              ),
              ...rows
                  .map(
                    (row) => TableRow(
                      children: [
                        Text(
                          row.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                        Text(
                          '${row.amount < 0 ? '-' : '+'} ${row.amount.toStringAsFixed(2).replaceAll('-', '')}€',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableRow {
  final String name;
  final double amount;

  _TableRow(this.name, this.amount);
}
