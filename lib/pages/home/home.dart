import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myfinance_app/api/categories.dart';
import 'package:myfinance_app/pages/category/category_dialog.dart';
import 'package:myfinance_app/utils/events.dart';
import 'package:myfinance_app/utils/keys.dart';
import 'package:myfinance_app/utils/localizations.dart';
import 'package:myfinance_app/utils/models.dart';
import 'package:myfinance_app/utils/network.dart';
import 'package:myfinance_app/utils/static.dart';
import 'package:myfinance_app/widgets/category_widget.dart';
import 'package:myfinance_app/widgets/person_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends Interactor<HomePage> {
  final storage = FlutterSecureStorage();
  final _categoryHandler = CategoriesHandler();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Category> categories;
  List<Person> persons;

  @override
  Subscription subscribeEvents(EventBus eventBus) =>
      eventBus.respond<LoadingStatusChangedEvent>((event) {
        if (event.key == Keys.categories) setState(() => null);
      }).respond<UpdateDataEvent>((event) => loadData());

  bool get _isLoading => Static.loading.isLoading([Keys.categories]);

  Future<void> loadData() async {
    // Check if logged in
    if (await Static.storage.getSensitiveString(Keys.sessionProof) == null) {
      if (mounted) {
        setState(() => null);
      }
      return;
    }

    final _categories = await _categoryHandler.loadOfflineCategories();
    sortCategories();
    final _persons = CategoriesHandler.loadedPersons;
    if (mounted)
      setState(() {
        categories = _categories;
        persons = _persons;
      });

    print('Download categories');
    final res = await _categoryHandler
        .loadCategories(EventBusWidget.of(context).eventBus);

    if (res.statusCode == StatusCode.success) {
      final _persons = CategoriesHandler.loadedPersons;
      sortCategories();
      // Only if the widget is still in use
      if (mounted)
        setState(() {
          categories = res.data;
          persons = _persons;
        });
    } else if (res.statusCode == StatusCode.offline) {
      if (mounted)
        _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(MyFinanceLocalizations.of(context).offlineMsg)));
    } else if (res.statusCode == StatusCode.unauthorized) {
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      if (mounted)
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text(MyFinanceLocalizations.of(context).failed)));
    }
  }

  void sortCategories() {
    categories?.sort((c1, c2) => c2.lastEdited.compareTo(c1.lastEdited));
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Check if logged in
    storage.read(key: Keys.sessionProof).then((value) {
      if (value == null) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Hero(
            tag: 'title',
            child: Text(
              MyFinanceLocalizations.of(context).title,
              style: Theme.of(context).textTheme.headline1,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => CategoryDialog(),
              ),
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => Navigator.of(context).pushNamed('/settings'),
            ),
          ],
          bottom: PreferredSize(
            // The 46: text tab height + 2: tab indicator height + 3: loading indicator height
            preferredSize: Size.fromHeight(46.0 + 2.0 + 3.0),
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
                TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.list_alt_rounded)),
                    Tab(icon: Icon(Icons.group)),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: List.generate(
            2,
            (index) => RefreshIndicator(
              onRefresh: () async {
                loadData();
                await Future.delayed(Duration(milliseconds: 500));
              },
              child: ListView(
                children: [
                  if (((index == 0 ? categories : persons) ?? []).isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.info_outline),
                            Text(
                              index == 0
                                  ? MyFinanceLocalizations.of(context)
                                      .noCategories
                                  : MyFinanceLocalizations.of(context)
                                      .noPersons,
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (index == 0)
                    ...categories
                        .map((category) => CategoryWidget(category: category))
                        .toList()
                  else if (index == 1)
                    ...persons
                        .map((person) => PersonWidget(person: person))
                        .toList()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
