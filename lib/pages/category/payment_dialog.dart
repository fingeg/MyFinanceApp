import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:myfinance_app/api/payments.dart';
import 'package:myfinance_app/utils/events.dart';
import 'package:myfinance_app/utils/localizations.dart';
import 'package:myfinance_app/utils/models.dart';
import 'package:myfinance_app/utils/network.dart';
import 'package:myfinance_app/widgets/delete_button.dart';
import 'package:myfinance_app/widgets/name_selection.dart';

class PaymentDialog extends StatefulWidget {
  final Category category;

  /// If set, the payment will be edited, otherwise created
  final Payment payment;

  const PaymentDialog({Key key, this.category, this.payment}) : super(key: key);

  @override
  _PaymentDialogState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  final _descriptionFocus = FocusNode();
  final _amountFocus = FocusNode();

  final _nameSelectionFeedback = NameSelectionFeedback();
  String _oldPayer;
  Date _date = Date.now();
  bool isExpense = true;
  bool payed = false;

  bool _loading = false;
  String _errorMsg = '';

  @override
  void initState() {
    if (widget.payment != null) {
      _nameController.text = widget.payment.name;
      _descriptionController.text = widget.payment.description;
      _amountController.text =
          _CurrencyInputFormatter.toAmountString(widget.payment.amount);

      _date = widget.payment.date;
      print(_date);
      _oldPayer = widget.payment.payer;
      isExpense = widget.payment.amount < 0;
      payed = widget.payment.payed;
    }
    super.initState();
  }

  Future<void> _submit() async {
    if (_formKey.currentState.validate()) {
      setState(() => _loading = true);
      print(_date);
      final payment = Payment(
        widget.payment?.id,
        _nameController.text,
        _descriptionController.text,
        widget.category.id,
        _CurrencyInputFormatter.parseInput(_amountController.text) *
            (isExpense ? -1 : 1),
        _date,
        _nameSelectionFeedback.getSelectedName().selectedName,
        payed,
        DateTime.now(),
      );

      final handler = PaymentHandler();
      final eventBus = EventBus.of(context);
      final res = await handler.setPayment(
          payment, widget.category.encryptionKey, eventBus);

      if (mounted) {
        setState(() => _loading = false);
      }

      if (res.statusCode == StatusCode.success && mounted) {
        eventBus.publish(UpdateDataEvent());
        Navigator.of(context).pop();
      } else if (res.statusCode == StatusCode.unauthorized) {
        Navigator.of(context).popAndPushNamed('/login');
      } else if (res.statusCode == StatusCode.offline) {
        _errorMsg = MyFinanceLocalizations.of(context).offlineMsg;
      } else if (res.statusCode == StatusCode.forbidden) {
        _errorMsg = MyFinanceLocalizations.of(context).writeRightsRequired;
      } else {
        _errorMsg = MyFinanceLocalizations.of(context).failed;
      }
      if (mounted) setState(() => null);
    }
  }

  Future<void> delete() async {
    setState(() => _loading = true);

    final eventBus = EventBus.of(context);
    final handler = PaymentHandler();
    final res = await handler.deletePayment(widget.payment);

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
      _errorMsg = MyFinanceLocalizations.of(context).writeRightsRequired;
    } else {
      _errorMsg = MyFinanceLocalizations.of(context).failed;
    }
    if (mounted) setState(() => null);
  }

  @override
  Widget build(BuildContext context) => SimpleDialog(
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.payment == null
                    ? MyFinanceLocalizations.of(context).addPayment
                    : MyFinanceLocalizations.of(context).editPayment,
              ),
            ),
            Checkbox(
              value: payed,
              onChanged: (value) => setState(() => payed = value),
            )
          ],
        ),
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
                          onEditingComplete: _amountFocus.nextFocus,
                        ),
                        TextFormField(
                          controller: _amountController,
                          decoration: InputDecoration(
                            labelText:
                                MyFinanceLocalizations.of(context).amount,
                          ),
                          keyboardType: TextInputType.number,
                          focusNode: _amountFocus,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9]|,|\.')),
                            _CurrencyInputFormatter(),
                          ],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (!_CurrencyInputFormatter.isValidAmount(value)) {
                              return MyFinanceLocalizations.of(context)
                                  .amountCondition;
                            }
                            return null;
                          },
                          onEditingComplete: _amountFocus.unfocus,
                        ),
                        Theme(
                          data: Theme.of(context).copyWith(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Radio(
                                value: true,
                                groupValue: isExpense,
                                onChanged: (value) =>
                                    setState(() => isExpense = value),
                              ),
                              InkWell(
                                onTap: () => setState(() => isExpense = true),
                                child: Text(
                                    MyFinanceLocalizations.of(context).expense),
                              ),
                              Container(
                                width: 20,
                              ),
                              Radio(
                                value: false,
                                groupValue: isExpense,
                                onChanged: (value) =>
                                    setState(() => isExpense = value),
                              ),
                              InkWell(
                                onTap: () => setState(() => isExpense = false),
                                child: Text(
                                    MyFinanceLocalizations.of(context).revenue),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 20),
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () => showDatePicker(
                                        context: context,
                                        locale: Locale('de'),
                                        initialDate: _date.toDateTime(),
                                        firstDate: DateTime(_date.year - 20),
                                        lastDate: DateTime(_date.year + 20))
                                    .then((date) => setState(() {
                                          if (date != null) {
                                            date =
                                                date.add(date.timeZoneOffset);
                                            _date = Date(
                                              date.year,
                                              date.month,
                                              date.day,
                                            );
                                          }
                                        })),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            MyFinanceLocalizations.of(context)
                                                .date,
                                            textAlign: TextAlign.start,
                                          ),
                                          Text(
                                              '${_date.day.toString().padLeft(2, '0')}.${_date.month.toString().padLeft(2, '0')}.${_date.year}'),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.edit)
                                  ],
                                ),
                              ),
                              Container(height: 20),
                              Text(
                                MyFinanceLocalizations.of(context).payer,
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                        NameSelection(
                          currentName: _oldPayer,
                          selectedNameFeedback: _nameSelectionFeedback,
                        ),
                        if (widget.payment != null)
                          DeleteButton(
                            text: MyFinanceLocalizations.of(context)
                                .deletePayment,
                            confirmationText: MyFinanceLocalizations.of(context)
                                .deletePaymentConfirmation,
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
                                ),
                              ),
                              OutlineButton(
                                onPressed: _submit,
                                child: Text(widget.payment == null
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

/// Live formatting of currency inputs
class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(',', '.').replaceAll('€', '');

    final fragments = text.split('.');
    if (fragments.length > 2) {
      text = '${fragments[0]},${fragments[1]}';
    }
    if (fragments.length > 1 && fragments[1].length > 2) {
      text = text.substring(0, text.length - (fragments[1].length - 2));
    }

    if (!text.endsWith('€')) {
      text += '€';
    }

    TextSelection selection = newValue.selection;
    if (newValue.selection.start > text.length - 1) {
      selection =
          TextSelection.fromPosition(TextPosition(offset: text.length - 1));
    }

    return TextEditingValue(
      text: text,
      selection: selection,
      composing: newValue.composing,
    );
  }

  static String toAmountString(double amount) =>
      '${amount.abs().toStringAsFixed(2)}€';

  static double parseInput(String input) {
    if (isValidAmount(input)) {
      String text = input.replaceAll(',', '.').replaceAll('€', '');
      return double.parse(text);
    }

    return null;
  }

  static bool isValidAmount(String input) {
    String text = input.replaceAll(',', '.').replaceAll('€', '');
    if (text.isEmpty) {
      return false;
    }

    try {
      if (double.parse(text) > 0) {
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }
}
