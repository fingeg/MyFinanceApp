import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:myfinance_app/api/categories.dart';
import 'package:myfinance_app/api/payments.dart';
import 'package:myfinance_app/utils/events.dart';
import 'package:myfinance_app/utils/keys.dart';
import 'package:myfinance_app/utils/localizations.dart';
import 'package:myfinance_app/utils/models.dart';
import 'package:myfinance_app/utils/network.dart';
import 'package:myfinance_app/utils/static.dart';
import 'package:myfinance_app/widgets/category_widget.dart';
import 'package:myfinance_app/widgets/delete_confirmation_dialog.dart';

class PersonPage extends StatefulWidget {
  final Person person;

  const PersonPage({@required this.person, Key key}) : super(key: key);

  @override
  _PersonPageState createState() => _PersonPageState();
}

class _PersonPageState extends Interactor<PersonPage> {
  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<LoadingStatusChangedEvent>((event) {
        final newPerson =
            CategoriesHandler.loadedPersons.where((p) => p.name == person.name);
        if (newPerson.length == 1) {
          if (event.key == Keys.categories)
            setState(() => person = newPerson.single);
        } else {
          Navigator.pop(context);
        }
      });

  bool get _isLoading => Static.loading.isLoading([Keys.categories]);
  Person person;

  void markAllAsPaid(BuildContext context) async {
    bool confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: MyFinanceLocalizations.of(context).markPayedConfirmationTitle,
        question: MyFinanceLocalizations.of(context).markPayedConfirmationText,
      ),
    );

    if (confirm) {
      final handler = PaymentHandler();
      final categories =
          person.categories.map((category) => category.id).toList();
      final res = await handler.markAsPayed(categories, eventBus);
      handleStatusCode(res.statusCode, eventBus);
    }
  }

  void handleStatusCode(StatusCode statusCode, EventBus eventBus) {
    if (statusCode == StatusCode.success && mounted) {
      eventBus.publish(UpdateDataEvent());
      Navigator.of(context).pop();
    } else if (statusCode == StatusCode.unauthorized) {
      Navigator.of(context).popAndPushNamed('/login');
    } else if (statusCode == StatusCode.offline) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(MyFinanceLocalizations.of(context).offlineMsg),
      ));
    } else if (statusCode == StatusCode.forbidden) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(MyFinanceLocalizations.of(context).writeRightsRequired),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(MyFinanceLocalizations.of(context).failed),
      ));
    }
    if (mounted) setState(() => null);
  }

  @override
  void initState() {
    person = widget.person;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final amount = person.amount;

    final categories =
        person.categories.map((c) => CategoryWidget(category: c)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'title',
          child: Text(
            person.name,
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
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          EventBus.of(context).publish(UpdateDataEvent());
          await Future.delayed(Duration(milliseconds: 500));
        },
        child: ListView(
          children: [
            if (amount != 0)
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Card(
                  color: Theme.of(context).primaryColor,
                  child: InkWell(
                    onTap: () => markAllAsPaid(context),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 10),
                      child: Text(MyFinanceLocalizations.of(context).markPayed),
                    ),
                  ),
                ),
              ),
            ...categories,
          ],
        ),
      ),
    );
  }
}
