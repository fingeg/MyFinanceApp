import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:myfinance_app/api/categories.dart';
import 'package:myfinance_app/utils/keys.dart';
import 'package:myfinance_app/utils/localizations.dart';
import 'package:myfinance_app/utils/models.dart';
import 'package:myfinance_app/utils/static.dart';
import 'package:myfinance_app/utils/utils.dart';

const _newName = '-';
const _me = 'me';

class AddSplitDialog extends StatefulWidget {
  final Split split;
  final List<String> currentUsers;
  final double currentPercentage;

  const AddSplitDialog(
      {Key key, this.split, this.currentPercentage, this.currentUsers})
      : super(key: key);

  @override
  _AddSplitDialogState createState() => _AddSplitDialogState();
}

class _AddSplitDialogState extends State<AddSplitDialog> {
  final _form = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shareController = TextEditingController();

  final _shareFocus = FocusNode();

  String username;
  String name;
  List<String> names;
  int maxPercentage;

  @override
  void initState() {
    // Load names (This task can need a while and should not stop the view,
    // so this will be done asynchronous
    final currentUsers = widget.currentUsers;
    (() async {
      final username = nameCaseCorrection(
        await Static.storage.getSensitiveString(Keys.username),
      );
      final names = [
        _newName,
        _me,
        ...CategoriesHandler.getUsedNames(),
      ];

      names.remove(username);

      // Remove users who already are part of the split
      currentUsers.forEach((user) {
        user = nameCaseCorrection(user);
        names.remove(user);
        if (user == username) {
          names.remove(_me);
        }
      });

      if (widget.split != null) {
        final currentName = getPersonDisplayName(widget.split.username);
        if (!names.contains(currentName)) {
          if (names.length > 2) {
            names.insert(2, currentName);
          } else {
            names.add(currentName);
          }
        }
      }

      setState(() {
        this.name = widget.split == null
            ? names.length > 1
                ? names[1]
                : names.first
            : getPersonDisplayName(widget.split.username);
        this.names = names;
        this.username = username;
      });
    })();

    maxPercentage = ((1 - widget.currentPercentage) * 100).round().toInt();
    if (widget.split != null) {
      _shareController.text = (widget.split.share * 100).toInt().toString();
    } else {
      _shareController.text = maxPercentage.toString();
    }

    super.initState();
  }

  String getPersonDisplayName(String name) => name
      .replaceAll(
        _newName,
        MyFinanceLocalizations.of(context).addNewPayer,
      )
      .replaceAll(
        _me,
        MyFinanceLocalizations.of(context).me,
      );

  void _submit() {
    if (_form.currentState.validate()) {
      final split = Split(
        name == _newName
            ? _nameController.text
            : name.replaceAll(_me, username),
        int.parse(_shareController.text) / 100,
        false,
        DateTime.now(),
      );
      Navigator.of(context).pop(split);
    }
  }

  @override
  Widget build(BuildContext context) => SimpleDialog(
        title: Text(MyFinanceLocalizations.of(context).addPayer),
        contentPadding: EdgeInsets.all(20),
        children: [
          Form(
            key: _form,
            child: Column(
              children: [
                if (name != null)
                  DropdownButtonFormField<String>(
                    onChanged: (value) => setState(() => name = value),
                    value: name,
                    items: [
                      ...names
                          .map(
                            (name) => DropdownMenuItem<String>(
                              value: name,
                              child: Text(getPersonDisplayName(name)),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                if (name == _newName)
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText:
                          MyFinanceLocalizations.of(context).nameOrUsername,
                    ),
                    onEditingComplete: _shareFocus.nextFocus,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (String value) {
                      if (value.isEmpty) {
                        return MyFinanceLocalizations.of(context).nameCondition;
                      }
                      if (widget.currentUsers
                          .map((u) => u.toLowerCase())
                          .contains(value.toLowerCase())) {
                        return MyFinanceLocalizations.of(context)
                            .splitNameCondition;
                      }
                      return null;
                    },
                  ),
                TextFormField(
                  controller: _shareController,
                  decoration: InputDecoration(
                    labelText: MyFinanceLocalizations.of(context).share,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                  ],
                  focusNode: _shareFocus,
                  validator: (String value) {
                    final number = int.tryParse(value);
                    if (value.isEmpty ||
                        number == null ||
                        number <= 0 ||
                        number > maxPercentage) {
                      return MyFinanceLocalizations.of(context)
                          .percentCondition
                          .replaceFirst('100', maxPercentage.toString());
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: OutlineButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(MyFinanceLocalizations.of(context).back),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      OutlineButton(
                        onPressed: _submit,
                        child: Text(MyFinanceLocalizations.of(context).update),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
