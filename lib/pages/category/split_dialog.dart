import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:myfinance_app/pages/category/add_split_dialog.dart';
import 'package:myfinance_app/utils/localizations.dart';
import 'package:myfinance_app/utils/models.dart';
import 'package:myfinance_app/utils/utils.dart';

class SplitDialog extends StatefulWidget {
  final List<Split> splits;

  const SplitDialog({Key key, this.splits}) : super(key: key);

  @override
  _SplitDialogState createState() => _SplitDialogState();
}

class _SplitDialogState extends State<SplitDialog> {
  List<bool> selection = [];

  void addSplit({Split cSplit, updateCurrent = false}) async {
    final split = await showDialog<Split>(
      context: context,
      builder: (context) => AddSplitDialog(
        split: cSplit,
        currentUsers: widget.splits
            .map((split) => split.username)
            .where((name) =>
                cSplit == null ||
                name.toLowerCase() != cSplit.username.toLowerCase())
            .toList(),
        currentPercentage: !updateCurrent
            ? [
                0.0,
                ...widget.splits
                    .where((split) =>
                        cSplit == null ||
                        split.username.toLowerCase() !=
                            cSplit.username.toLowerCase())
                    .map((split) => split.share),
              ].reduce((v1, v2) => v1 + v2)
            : 0.5,
      ),
    );

    if (split != null) {
      setState(() {
        if (updateCurrent) {
          final old = widget.splits.single;
          widget.splits.clear();
          widget.splits.add(Split(
            old.username,
            0.5,
            old.isPlatformUser,
            old.lastEdited,
          ));
        }
        widget.splits.add(split);
        if (cSplit != null) {
          widget.splits.remove(cSplit);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    selection = List.generate(widget.splits.length,
        (index) => selection.length > index ? selection[index] : false);
    final currentPercentage = [
      0.0,
      ...widget.splits.map((split) => split.share),
    ].reduce((v1, v2) => v1 + v2);

    return SimpleDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(MyFinanceLocalizations.of(context).payer),
          ),
          if (selection.where((v) => v).length == 1)
            IconButton(
              icon: Icon(LineIcons.pencil),
              onPressed: () =>
                  addSplit(cSplit: widget.splits[selection.indexOf(true)]),
            ),
          if (selection.isNotEmpty && selection.reduce((v1, v2) => v1 || v2))
            IconButton(
              icon: Icon(LineIcons.trash),
              onPressed: () {
                for (var i = selection.length - 1; i >= 0; i--) {
                  if (selection[i]) {
                    widget.splits.removeAt(i);
                  }
                }
                setState(() => null);
              },
            ),
          if (currentPercentage < 1 || widget.splits.length == 1)
            IconButton(
              icon: Icon(LineIcons.plus),
              onPressed: () => addSplit(updateCurrent: currentPercentage >= 1),
            ),
        ],
      ),
      contentPadding: EdgeInsets.all(20),
      children: [
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
            verticalInside: BorderSide(
              color: Theme.of(context).textTheme.bodyText1.color,
              width: 0.3,
            ),
          ),
          columnWidths: {
            0: FixedColumnWidth(20),
            2: FixedColumnWidth(80),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).textTheme.bodyText1.color,
                    width: 0.3,
                  ),
                ),
              ),
              children: [
                Container(),
                Center(child: Text(MyFinanceLocalizations.of(context).splits)),
                Center(
                  child: Text(MyFinanceLocalizations.of(context).share),
                ),
              ],
            ),
            ...widget.splits.map((split) => TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Checkbox(
                        visualDensity: VisualDensity.compact,
                        value: selection[widget.splits.indexOf(split)],
                        onChanged: (value) => setState(() =>
                            selection[widget.splits.indexOf(split)] = value),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Text(split.username),
                    ),
                    Center(
                      child: Text('${(split.share * 100).toInt()}%'),
                    )
                  ],
                )),
            if (widget.splits.isEmpty)
              TableRow(children: [
                Container(),
                Center(child: Text('-')),
                Center(child: Text('-')),
              ]),
          ],
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
                onPressed: () => Navigator.of(context).pop(widget.splits),
                child: Text(MyFinanceLocalizations.of(context).update),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
