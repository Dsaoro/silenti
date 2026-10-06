import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:silenti/application/budgets/get_expenses_categories_use_case.dart';
import 'package:silenti/core/models/scheduled_expense.dart';

// ignore: must_be_immutable
class ScheduledExpenseForm extends StatefulWidget {
  Function onSave;
  final ScheduledExpense expense;
  String buttonText;
  ScheduledExpenseForm({
    super.key,
    required this.onSave,
    required this.expense,
    required this.buttonText,
  });

  @override
  State<ScheduledExpenseForm> createState() => _ScheduledExpenseFormState();
}

class _ScheduledExpenseFormState extends State<ScheduledExpenseForm> {
  late String _name;
  late int _categoryId;
  late int _dueDay;
  late int _reminderDaysBefore;
  final Map<int, String> _categories = {0: "Seleccionar..."};

  @override
  void initState() {
    super.initState();
    _name = widget.expense.name;
    _categoryId = widget.expense.categoryId;
    _dueDay = widget.expense.dueDay;
    _reminderDaysBefore = widget.expense.reminderDaysBefore;
    _getCategories();
  }

  _getCategories() async {
    var response = await GetExpensesCategoriesUseCase().execute();
    if (response.status) {
      setState(() {
        for (var category in response.model!) {
          _categories[category.id] = category.name;
        }
      });
    } else {
      if (kDebugMode) {
        print(response.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.8,
      child: ListView(
        children: [
          Text(
            "Gasto periódico",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          TextFormField(
            initialValue: _name,
            decoration: InputDecoration(labelText: "Nombre"),
            onChanged: (value) => _name = value,
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _categoryId == 0 ? null : _categoryId,
            decoration: InputDecoration(labelText: "Categoría"),
            items: _categories.entries
                .where((entry) => entry.key != 0)
                .map((entry) =>
                    DropdownMenuItem(value: entry.key, child: Text(entry.value)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _categoryId = value ?? 0;
              });
            },
          ),
          SizedBox(height: 8),
          TextFormField(
            initialValue: _dueDay.toString(),
            decoration: InputDecoration(
                labelText: "Día de vencimiento del mes (1-31)"),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final parsed = int.tryParse(value);
              if (parsed != null && parsed >= 1 && parsed <= 31) {
                _dueDay = parsed;
              }
            },
          ),
          SizedBox(height: 8),
          TextFormField(
            initialValue: _reminderDaysBefore.toString(),
            decoration: InputDecoration(labelText: "Avisar con cuántos días de anticipación"),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final parsed = int.tryParse(value);
              if (parsed != null && parsed >= 0) {
                _reminderDaysBefore = parsed;
              }
            },
          ),
          SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.secondary),
                foregroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.onSurface),
              ),
              onPressed: () {
                if (_name.isEmpty || _categoryId == 0) return;
                widget.onSave(ScheduledExpense(
                  id: widget.expense.id,
                  categoryId: _categoryId,
                  name: _name,
                  dueDay: _dueDay,
                  reminderDaysBefore: _reminderDaysBefore,
                  active: widget.expense.active,
                ));
              },
              child: Text(widget.buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
