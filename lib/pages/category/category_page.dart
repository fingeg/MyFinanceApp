import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:myfinance_app/pages/category/add_payment_dialog.dart';
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
        .map((p) => _TableRow(p.name, p.amount, p.description))
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
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Center(
              child: Text(
                '${amount < 0 ? '-' : '+'} ${amount.toStringAsFixed(2).replaceAll('-', '')}€',
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Container(
            padding: const EdgeInsets.only(left: 15),
            height: 40,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color:
                      Theme.of(context).textTheme.headline1.color.withAlpha(50),
                  width: 0.2,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Tooltip(
                    message: widget.category.description,
                    child: Text(
                      widget.category.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(LineIcons.plus),
                  color: Theme.of(context).textTheme.subtitle1.color,
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) =>
                        AddPaymentDialog(category: widget.category),
                  ),
                ),
                IconButton(
                  icon: Icon(LineIcons.pencil),
                  color: Theme.of(context).textTheme.subtitle1.color,
                  onPressed: () => null,
                ),
              ],
            ),
          ),
        ),
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
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Text(
                    MyFinanceLocalizations.of(context).amount,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
              ...rows
                  .map(
                    (row) => TableRow(
                      children: [
                        row.description != null
                            ? Tooltip(
                                message: row.description ?? '',
                                child: Text(
                                  row.name,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              )
                            : Text(
                                row.name,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                        Text(
                          '${row.amount < 0 ? '-' : '+'} ${row.amount.toStringAsFixed(2).replaceAll('-', '')}€',
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.bodyText1,
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
  final String description;

  _TableRow(this.name, this.amount, [this.description]);
}
