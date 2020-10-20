import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final dynamic id;
  final String title;
  final double amount;
  final List<SubInfo> subInfo;
  final void Function() onTap;

  const CardWidget({
    @required this.subInfo,
    @required this.title,
    this.id,
    this.onTap,
    this.amount,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 10, bottom: 5, right: 10),
      child: Card(
        color: Theme.of(context).primaryColor,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.all(Radius.circular(3)),
          child: Container(
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                    color: Colors.white,
                    width: 0.2,
                  ))),
                  alignment: Alignment.centerLeft,
                  child: _PaymentRow(
                    title: title,
                    amount: amount,
                    heroKey: id,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    children: subInfo
                        .map((subInfo) => _PaymentRow(
                              title: subInfo.text,
                              amount: subInfo.amount,
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final dynamic heroKey;
  final String title;
  final double amount;

  const _PaymentRow({Key key, this.title, this.amount, this.heroKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final amountWidget = _Text(
        text:
            '${amount < 0 ? '-' : '+'} ${amount.toStringAsFixed(2).replaceAll('-', '')}€');
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: heroKey != null
              ? Hero(
                  tag: Key('$heroKey-title'),
                  child: _Text(text: title),
                )
              : _Text(text: title),
        ),
        heroKey != null
            ? Hero(
                tag: Key('$heroKey-amount'),
                child: amountWidget,
              )
            : amountWidget,
      ],
    );
  }
}

class _Text extends StatelessWidget {
  final String text;

  const _Text({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w100,
      ),
    );
  }
}

class SubInfo {
  final String text;
  final double amount;

  SubInfo(this.text, this.amount);
}
