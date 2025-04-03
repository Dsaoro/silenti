import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/generated/l10n.dart';
import 'package:silenti/presentation/components/silenti_text_field.dart';

// ignore: must_be_immutable
class SilentiDatatable extends StatefulWidget {
  List<DataColumn> columns;
  List<DataRow> rows;
  SilentiDatatable({super.key, required this.columns, required this.rows});
  @override
  State<StatefulWidget> createState() => _SilentiDatatableState();
}

class _SilentiDatatableState extends State<SilentiDatatable> {
  List<DataRow> rows = [];
  int currentPage = 0;
  int lastPage = 0;
  int itemsPerPage = 10;
  String filter = "";
  double iconNavigationSize = 16;
  List<DataRow> _getPageRows() {
    if (rows.length < itemsPerPage) {
      return rows;
    }
    currentPage = currentPage > lastPage ? lastPage : currentPage;
    return rows.sublist(currentPage * itemsPerPage);
  }

  _buildRows() {
    int index = rows.length + 1;
    for (var element in widget.rows) {
      rows.add(
        DataRow(
          color: index % 2 == 0
              ? WidgetStateProperty.resolveWith((states) {
                  return Theme.of(context).colorScheme.primary;
                })
              : null,
          cells: element.cells,
        ),
      );
    }
  }

  @override
  void initState() {
    _buildRows();
    lastPage = (rows.length / itemsPerPage).ceil();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      padding: EdgeInsets.all(4),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(),
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  child: Text("${S.current.itemsPerPage} :"),
                ),
                SizedBox(
                  width: 8,
                ),
                SizedBox(
                  width: 25,
                  child: SilentiTextField(
                    input: itemsPerPage.toString(),
                    onChange: (value) {
                      itemsPerPage = int.parse(value);
                    },
                    hintText: itemsPerPage.toString(),
                    keyboardType: TextInputType.number,
                  ),
                )
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.topLeft,
            child: DataTable(
              sortColumnIndex: 0,
              columnSpacing: 5,
              border: TableBorder.all(color: SilentiColors.gray),
              headingRowColor: WidgetStateColor.resolveWith(
                (states) => SilentiColors.secondary,
              ),
              headingTextStyle: TextStyle(
                color: SilentiColors.dark,
                fontSize: 16,
              ),
              headingRowHeight: 28,
              dataRowMaxHeight: 26,
              dataRowMinHeight: 26,
              dataTextStyle: TextStyle(
                color: SilentiColors.dark,
                fontSize: 14,
              ),
              columns: widget.columns,
              rows: _getPageRows(),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.keyboard_double_arrow_left,
                    size: iconNavigationSize,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.keyboard_arrow_left,
                    size: iconNavigationSize,
                  ),
                ),
                SizedBox(
                  width: iconNavigationSize,
                  child: Text(
                    (currentPage + 1).toString(),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.keyboard_arrow_right,
                    size: iconNavigationSize,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.keyboard_double_arrow_right,
                    size: iconNavigationSize,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
