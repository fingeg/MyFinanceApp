import 'package:flutter/material.dart';
import 'package:myfinance_app/widgets/delete_confirmation_dialog.dart';

/// A delete button with a delete confirmation dialog
class DeleteButton extends StatelessWidget {
  /// The on delete function is called when a user pressed the delete button
  /// and confirmed the deletion
  final void Function() onDelete;
  final String text;
  final String confirmationText;

  const DeleteButton({Key key, this.onDelete, this.text, this.confirmationText})
      : super(key: key);

  void _onDelete(BuildContext context) async {
    final confirmation = await showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: text,
        question: confirmationText,
      ),
    );

    if (confirmation ?? false) {
      onDelete();
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FlatButton(
            textColor: Colors.red,
            visualDensity: VisualDensity(
              vertical: -2,
              horizontal: 2,
            ),
            padding: EdgeInsets.all(0),
            onPressed: () => _onDelete(context),
            child: Text(text),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.red, width: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      );
}
