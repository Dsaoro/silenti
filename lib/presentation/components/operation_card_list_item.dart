import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/utils/currency_formater.dart';

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

  Text _getAmount(BuildContext context) {
    String result = "";
    result = operation.amount.toString();
    if (operation.type == Operation.expense) {
      return Text(
        "-\$${CurrencyFormater.convert(operation.amount)}",
        style: TextStyle(
          color: SilentiColors.warning,
          fontWeight: FontWeight.w500,
        ),
      );
    } else if (operation.type == Operation.income) {
      return Text(
        // "\$ ${operation.amount.toStringAsPrecision(7)}",
        "\$${CurrencyFormater.convert(operation.amount)}",
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1, horizontal: 2),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getShowableDate(operation.date),
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _getDescription(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _getAmount(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
