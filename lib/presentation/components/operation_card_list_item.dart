import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/core/enums/silenti_styles.dart';
import 'package:silenti/core/models/operation.dart';

class OperationCardListItem extends StatelessWidget {
  const OperationCardListItem({
    super.key,
    required this.operation,
    required this.isLoading,
  });

  final bool isLoading;
  final Operation operation;
  String _getShowableDate(DateTime date) {
    String fecha = date.toIso8601String();
    return fecha.split("T")[0];
  }

  String _getDescription() {
    String result = "";
    result = operation.description;
    return result;
  }

  Text _getAmount() {
    String result = "";
    result = operation.amount.toString();
    if (operation.type == Operation.expense) {
      return Text(
        "-\$ ${operation.amount.toStringAsPrecision(7)}",
        style: TextStyle(
          color: SilentiColors.warning,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (operation.type == Operation.income) {
      return Text(
        "\$ ${operation.amount.toStringAsPrecision(7)}",
        style: TextStyle(
          color: SilentiColors.ok,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    return Text(result);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color.fromARGB(40, 242, 242, 242),
          borderRadius: BorderRadius.circular(
            4,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Container(
                  alignment: Alignment.centerLeft,
                  height: 28,
                  child: Text(
                    _getShowableDate(operation.date),
                    style: SilentiStyles.subtitleTextStyle,
                  )),
              const SizedBox(height: 2),
              Container(
                alignment: Alignment.centerLeft,
                height: 16,
                child: Text(
                  _getDescription(),
                  style: TextStyle(
                    color: SilentiColors.gray,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                alignment: Alignment.centerRight,
                height: 16,
                child: _getAmount(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildImage() {
  //   return AspectRatio(
  //     aspectRatio: 1,
  //     child: Container(
  //       width: 64,
  //       decoration: BoxDecoration(
  //         color: Colors.black,
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       child: Icon(Icons.attach_money_rounded),
  //       // child: ClipRRect(
  //       //   borderRadius: BorderRadius.circular(8),
  //       //   child: _buildText(),
  //       // ),
  //     ),
  //   );
  // }

  // Widget _buildText(context) {
  //   if (!isLoading) {
  //     return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           width: MediaQuery.of(context).size.width * 0.5,
  //           height: 24,
  //           decoration: BoxDecoration(
  //             color: Colors.black,
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Text(
  //             title,
  //             style: SilentiStyles.titleTextStyle,
  //           ),
  //         ),
  //         const SizedBox(height: 6),
  //         Container(
  //           width: MediaQuery.of(context).size.width * 0.5,
  //           height: 34,
  //           decoration: BoxDecoration(
  //             color: Colors.black,
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Text(
  //             content,
  //             style: SilentiStyles.titleTextStyle,
  //           ),
  //         ),
  //       ],
  //     );
  //   } else {
  //     return Padding(
  //       padding: EdgeInsets.symmetric(horizontal: 8),
  //       child: Text(content, style: TextStyle(color: Colors.white)),
  //     );
  //   }
  // }
}
