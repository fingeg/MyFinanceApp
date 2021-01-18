import 'package:flutter/material.dart';
import 'package:myfinance_app/api/categories.dart';
import 'package:myfinance_app/utils/keys.dart';
import 'package:myfinance_app/utils/localizations.dart';
import 'package:myfinance_app/utils/static.dart';
import 'package:myfinance_app/utils/utils.dart';

const NEW_NAME_PLACEHOLDER = '-';
const ME_PLACEHOLDER = 'me';

class _SelectedName {
  final bool isValid;
  final String selectedName;

  _SelectedName(this.selectedName, this.isValid);
}

class NameSelectionFeedback {
  _SelectedName Function() feedbackFunction;

  _SelectedName getSelectedName() => feedbackFunction != null
      ? feedbackFunction()
      : _SelectedName(null, false);
}

class NameSelection extends StatefulWidget {
  final String currentName;
  final List<String> namesToIgnore;
  final FocusNode nextFocus;
  final NameSelectionFeedback selectedNameFeedback;

  const NameSelection({
    this.currentName,
    this.namesToIgnore = const [],
    this.nextFocus,
    this.selectedNameFeedback,
    Key key,
  }) : super(key: key);

  @override
  _NameSelectionState createState() => _NameSelectionState();
}

class _NameSelectionState extends State<NameSelection> {
  final _nameController = TextEditingController();

  String name;
  String username;
  List<String> names;

  @override
  void initState() {
    widget.selectedNameFeedback.feedbackFunction = getSelectedName;
    loadNames();
    super.initState();
  }

  _SelectedName getSelectedName() => name == NEW_NAME_PLACEHOLDER
      ? _SelectedName(
          _nameController.text.trim(),
          isNameValid(_nameController.text) == null,
        )
      : _SelectedName(name.replaceAll(ME_PLACEHOLDER, username), true);

  Future<void> loadNames() async {
    final username = nameCaseCorrection(
      await Static.storage.getSensitiveString(Keys.username),
    );
    final names = getListOfNames(username);

    // Remove users who already are part of the split
    widget.namesToIgnore.forEach((user) {
      user = nameCaseCorrection(user);
      names.remove(user);
      if (user == username) {
        names.remove(ME_PLACEHOLDER);
      }
    });

    String currentName = widget.currentName;
    if (currentName != null) {
      // If the current name is the username, select the ME_PLACEHOLDER
      if (currentName.toLowerCase() == username.toLowerCase()) {
        currentName = null;
      } else {
        currentName = getPersonDisplayName(currentName);
        if (!names.contains(currentName)) {
          if (names.length > 2) {
            names.insert(2, currentName);
          } else {
            names.add(currentName);
          }
        }
      }
    }

    setState(() {
      this.name = currentName == null
          ? names.length > 1
              ? names[1]
              : names.first
          : getPersonDisplayName(currentName);
      this.names = names;
      this.username = username;
    });
  }

  List<String> getListOfNames(String username) {
    final _username = nameCaseCorrection(username);
    final names = [
      NEW_NAME_PLACEHOLDER,
      ME_PLACEHOLDER,
      ...CategoriesHandler.getUsedNames(),
    ];

    names.remove(_username);

    return names;
  }

  String getPersonDisplayName(String name) => name
      .replaceAll(
        NEW_NAME_PLACEHOLDER,
        MyFinanceLocalizations.of(context).addNewPayer,
      )
      .replaceAll(
        ME_PLACEHOLDER,
        MyFinanceLocalizations.of(context).me,
      );

  @override
  Widget build(BuildContext context) => Column(
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
          if (name == NEW_NAME_PLACEHOLDER)
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: MyFinanceLocalizations.of(context).nameOrUsername,
              ),
              onEditingComplete: widget.nextFocus?.nextFocus,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: isNameValid,
            ),
        ],
      );

  String isNameValid(String name) {
    name = name.trim();

    if (name.isEmpty) {
      return MyFinanceLocalizations.of(context).nameCondition;
    }
    if (widget.namesToIgnore
        .map((u) => u.toLowerCase())
        .contains(name.toLowerCase())) {
      return MyFinanceLocalizations.of(context).splitNameCondition;
    }
    if (names.map((u) => u.toLowerCase()).contains(name.toLowerCase()) ||
        name.toLowerCase() == username.toLowerCase()) {
      return MyFinanceLocalizations.of(context).singleNameCondition;
    }
    return null;
  }
}
