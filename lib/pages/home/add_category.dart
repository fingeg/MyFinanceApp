import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myfinance_app/utils/localizations.dart';

class AddCategory extends StatefulWidget {
  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          MyFinanceLocalizations.of(context).newCategory,
          style: TextStyle(
            fontWeight: FontWeight.w100,
            fontSize: 25,
          ),
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: MyFinanceLocalizations.of(context).name,
                  hintText: MyFinanceLocalizations.of(context).categoryName,
                  hintStyle: TextStyle(
                    color:
                        Theme.of(context).textTheme.headline1.color.withAlpha(50),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white,
                    width: 0.2,
                  ),
                ),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                MyFinanceLocalizations.of(context).sharedUser,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
