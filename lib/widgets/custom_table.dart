import 'package:flutter/material.dart';

class CustomTable<T> extends StatelessWidget {
  final CustomTableRow<void> header;
  final List<CustomTableRow<T>> rows;
  final List<int> columnsWidths;
  final List<TextAlign> columnsAligns;
  final void Function(CustomTableRow<T>) onTap;

  const CustomTable(
      {@required this.rows,
      this.header,
      this.onTap,
      this.columnsWidths,
      this.columnsAligns,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        // First row is the header
        if (header != null)
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).textTheme.headline1.color,
                  width: 0.3,
                ),
              ),
            ),
            child: Row(
              children: List.generate(
                header.columns.length,
                (columnIndex) => Expanded(
                  flex: columnsWidths[columnIndex],
                  child: Container(
                    decoration: columnIndex > 0
                        ? BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color:
                                    Theme.of(context).textTheme.headline1.color,
                                width: 0.3,
                              ),
                            ),
                          )
                        : null,
                    child: Text(
                      header.columns[columnIndex],
                      textAlign: columnsAligns[columnIndex],
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ...rows.map((row) {
          var textColor = Theme.of(context).textTheme.subtitle1.color;
          if (row.grey) {
            textColor = textColor.withAlpha(60);
          }
          return InkWell(
            onTap: () => onTap(row),
            highlightColor: Colors.black12,
            child: Row(
              children: List.generate(
                row.columns.length,
                (columnIndex) => Expanded(
                  flex: columnsWidths[columnIndex],
                  child: Container(
                    padding:
                        EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 0),
                        decoration: columnIndex > 0
                            ? BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color:
                              Theme.of(context).textTheme.headline1.color,
                              width: 0.3,
                            ),
                          ),
                        )
                            : null,
                        child: Text(
                          row.columns[columnIndex],
                          textAlign: columnsAligns[columnIndex],
                          style: TextStyle(
                            fontWeight: FontWeight.w100,
                        fontSize: 20,
                        color: textColor,
                      ),
                        ),
                      ),
                    ),
              ),
            ),
          );
        }).toList(),
      ]),
    );
  }
}

class CustomTableRow<T> {
  final List<String> columns;
  final T metadata;
  final bool grey;

  CustomTableRow({@required this.columns, this.metadata, this.grey = false});
}
