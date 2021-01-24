import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:line_icons/line_icons.dart';
import 'package:myfinance_app/api/categories.dart';
import 'package:myfinance_app/pages/category/category_dialog.dart';
import 'package:myfinance_app/pages/category/payment_dialog.dart';
import 'package:myfinance_app/utils/events.dart';
import 'package:myfinance_app/utils/keys.dart';
import 'package:myfinance_app/utils/localizations.dart';
import 'package:myfinance_app/utils/models.dart';
import 'package:myfinance_app/utils/static.dart';
import 'package:myfinance_app/widgets/custom_table.dart';

class CategoryPage extends StatefulWidget {
  final Category category;

  const CategoryPage({@required this.category, Key key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends Interactor<CategoryPage> {
  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<LoadingStatusChangedEvent>((event) {
        final newCategory = CategoriesHandler.loadedCategories
            .where((c) => c.id == category.id);
        if (newCategory.length == 1) {
          if (event.key == Keys.categories)
            setState(() => category = newCategory.single);
        } else {
          Navigator.pop(context);
        }
      });

  bool get _isLoading => Static.loading.isLoading([Keys.categories]);
  Category category;
  bool showPayed = false;

  @override
  void initState() {
    category = widget.category;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final amount = category.amount;
    final payers = category
        .getAllPayers()
        .map((p) => _TableRow<String>(p, category.getAmountForPerson(p), p))
        .toList();

    final payments = category.sortedPayments
        .where((p) => showPayed || !p.payed)
        .map((p) => _TableRow<Payment>(p.name, p.amount, p, p.payed))
        .toList();

    final payedPaymentsCount =
        category.sortedPayments.where((p) => p.payed).length;

    final pendingInvoices = category.splits
        .map((p) => _TableRow<String>(p.username, amount * p.share, p.username))
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
          tag: 'title',
          child: Text(
            category.name,
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
          preferredSize: Size.fromHeight(43),
          child: Column(
            children: [
              AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: _isLoading ? 1 : 0,
                child: SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 15),
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context)
                          .textTheme
                          .headline1
                          .color
                          .withAlpha(50),
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
                        message: category.description,
                        child: Text(
                          category.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                    ),
                    if (category.permission != Permission.read)
                      IconButton(
                        icon: Icon(LineIcons.plus),
                        color: Theme.of(context).textTheme.subtitle1.color,
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) =>
                              PaymentDialog(category: category),
                        ),
                      ),
                    if (category.permission != Permission.read)
                      IconButton(
                        icon: Icon(LineIcons.pencil),
                        color: Theme.of(context).textTheme.subtitle1.color,
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) =>
                              CategoryDialog(category: category),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          EventBus.of(context).publish(UpdateDataEvent());
          await Future.delayed(Duration(milliseconds: 500));
        },
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            if (category.isSplit)
              CardTable<String>(
                header: MyFinanceLocalizations.of(context).pendingInvoices,
                rows: pendingInvoices,
                onTap: (row) => null,
              ),
            Hero(
              tag: category.id,
              child: CardTable<String>(
                header: MyFinanceLocalizations.of(context).payers,
                rows: payers,
                onTap: (row) => null,
              ),
            ),
            CardTable<Payment>(
              header: MyFinanceLocalizations.of(context).payments,
              rows: payments,
              onTap: (row) => showDialog(
                context: context,
                builder: (context) => PaymentDialog(
                  category: category,
                  payment: row.metadata,
                ),
              ),
            ),
            if (payedPaymentsCount > 0)
              Card(
                color: Theme.of(context).primaryColor,
                child: InkWell(
                  onTap: () => setState(() => showPayed = !showPayed),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 10),
                    child: Text((!showPayed
                            ? MyFinanceLocalizations.of(context).showPayed
                            : MyFinanceLocalizations.of(context).hidePayed)
                        .replaceAll('N', payedPaymentsCount.toString())),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CardTable<T> extends StatelessWidget {
  final String header;
  final List<_TableRow<T>> rows;
  final void Function(CustomTableRow<T> row) onTap;

  const CardTable({Key key, this.header, this.rows, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: CustomTable<T>(
            columnsAligns: [TextAlign.start, TextAlign.end],
            columnsWidths: [7, 4],
            onTap: onTap,
            header: CustomTableRow(
              columns: [
                header,
                MyFinanceLocalizations.of(context).amount,
              ],
            ),
            rows: rows
                .map((row) => CustomTableRow<T>(
              columns: [
                        row.name,
                        '${row.amount < 0 ? '-' : '+'} ${row.amount.toStringAsFixed(2).replaceAll('-', '')}€',
                      ],
                      metadata: row.metadata,
                      grey: row.grey,
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _TableRow<T> {
  final String name;
  final double amount;
  final bool grey;
  final T metadata;

  _TableRow(this.name, this.amount, [this.metadata, this.grey = false]);
}
