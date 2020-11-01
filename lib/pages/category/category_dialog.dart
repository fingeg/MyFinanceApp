import 'package:flutter/material.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:myfinance_app/api/categories.dart';
import 'package:myfinance_app/utils/encryption/encryption.dart';
import 'package:myfinance_app/utils/events.dart';
import 'package:myfinance_app/utils/localizations.dart';
import 'package:myfinance_app/utils/models.dart';
import 'package:myfinance_app/utils/network.dart';
import 'package:myfinance_app/widgets/delete_button.dart';
import 'package:myfinance_app/widgets/delete_confirmation_dialog.dart';

class CategoryDialog extends StatefulWidget {
  final Category category;

  const CategoryDialog({Key key, this.category}) : super(key: key);

  @override
  _CategoryDialogState createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _descriptionFocus = FocusNode();

  bool _loading = false;
  String _errorMsg = '';

  @override
  void initState() {
    if (widget.category != null) {
      _nameController.text = widget.category.name;
      _descriptionController.text = widget.category.description;
    }

    super.initState();
  }

  Future<void> _submit() async {
    if (_formKey.currentState.validate()) {
      setState(() => _loading = true);

      final eventBus = EventBus.of(context);
      final category = Category(
        widget.category?.id,
        _nameController.text,
        _descriptionController.text,
        widget.category?.permission ?? Permission.owner,
        [],
        [],
        widget.category?.encryptionKey ?? createCryptoRandomString(),
      );

      final handler = CategoriesHandler();
      final res = await handler.setCategory(category);

      if (mounted) {
        setState(() => _loading = false);
      }

      handleStatusCode(res.statusCode, eventBus);
    }
  }

  Future<void> delete() async {
    setState(() => _loading = true);

    final eventBus = EventBus.of(context);
    final handler = CategoriesHandler();
    final res = await handler.deleteCategory(widget.category);

    if (mounted) {
      setState(() => _loading = false);
    }

    handleStatusCode(res.statusCode, eventBus);
  }

  void handleStatusCode(StatusCode statusCode, EventBus eventBus) {
    if (statusCode == StatusCode.success && mounted) {
      eventBus.publish(UpdateDataEvent());
      Navigator.of(context).pop();
    } else if (statusCode == StatusCode.unauthorized) {
      Navigator.of(context).popAndPushNamed('/login');
    } else if (statusCode == StatusCode.offline) {
      _errorMsg = MyFinanceLocalizations.of(context).offlineMsg;
    } else if (statusCode == StatusCode.forbidden) {
      _errorMsg = MyFinanceLocalizations.of(context).ownerRightsRequired;
    } else {
      _errorMsg = MyFinanceLocalizations.of(context).failed;
    }
    if (mounted) setState(() => null);
  }

  @override
  Widget build(BuildContext context) => SimpleDialog(
        title: Text(widget.category == null
            ? MyFinanceLocalizations.of(context).newCategory
            : MyFinanceLocalizations.of(context).editCategory),
        contentPadding: EdgeInsets.all(20),
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            child: !_loading
                ? Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_errorMsg.isNotEmpty)
                          Text(
                            _errorMsg,
                            style: TextStyle(color: Colors.red),
                          ),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: MyFinanceLocalizations.of(context).name,
                          ),
                          onEditingComplete: _descriptionFocus.nextFocus,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (String value) {
                            if (value.isEmpty) {
                              return MyFinanceLocalizations.of(context)
                                  .nameCondition;
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText:
                                MyFinanceLocalizations.of(context).description,
                          ),
                          focusNode: _descriptionFocus,
                        ),
                        if (widget.category != null)
                          DeleteButton(
                            text: MyFinanceLocalizations.of(context)
                                .deleteCategory,
                            confirmationText: MyFinanceLocalizations.of(context)
                                .deleteCategoryConfirmation,
                            onDelete: delete,
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: OutlineButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(
                                      MyFinanceLocalizations.of(context).back),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              OutlineButton(
                                onPressed: _submit,
                                child: Text(widget.category == null
                                    ? MyFinanceLocalizations.of(context).add
                                    : MyFinanceLocalizations.of(context)
                                        .update),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                : SpinKitFadingCircle(
                    itemBuilder: (context, index) => DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                    ),
                  ),
          )
        ],
      );
}
