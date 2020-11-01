import 'package:flutter/material.dart';
import 'package:myfinance_app/utils/localizations.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String question;

  const DeleteConfirmationDialog({Key key, this.title, this.question})
      : super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(question),
        actions: [
          OutlineButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MyFinanceLocalizations.of(context).no),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          OutlineButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(MyFinanceLocalizations.of(context).yes),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      );
}
