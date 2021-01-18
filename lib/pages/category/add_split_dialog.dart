import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myfinance_app/utils/localizations.dart';
import 'package:myfinance_app/utils/models.dart';
import 'package:myfinance_app/widgets/name_selection.dart';

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
  final _shareController = TextEditingController();

  final _shareFocus = FocusNode();
  final _selectedNameFeedback = NameSelectionFeedback();

  int maxPercentage;

  @override
  void initState() {
    maxPercentage = ((1 - widget.currentPercentage) * 100).round().toInt();
    if (widget.split != null) {
      _shareController.text = (widget.split.share * 100).toInt().toString();
    } else {
      _shareController.text = maxPercentage.toString();
    }

    super.initState();
  }

  void _submit() {
    final name = _selectedNameFeedback.getSelectedName();
    if (_form.currentState.validate() && name.isValid) {
      final split = Split(
        name.selectedName,
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
                NameSelection(
                  currentName: widget.split?.username,
                  namesToIgnore: widget.currentUsers,
                  selectedNameFeedback: _selectedNameFeedback,
                  nextFocus: _shareFocus,
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
