import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:myfinance_app/api/categories.dart';
import 'package:myfinance_app/utils/events.dart';
import 'package:myfinance_app/utils/keys.dart';
import 'package:myfinance_app/utils/models.dart';
import 'package:myfinance_app/utils/static.dart';
import 'package:myfinance_app/widgets/category_widget.dart';

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
          children: categories,
        ),
      ),
    );
  }
}
