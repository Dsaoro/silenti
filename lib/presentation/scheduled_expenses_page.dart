import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:silenti/application/scheduled_expenses/add_scheduled_expense_use_case.dart';
import 'package:silenti/application/scheduled_expenses/delete_scheduled_expense_use_case.dart';
import 'package:silenti/application/scheduled_expenses/get_scheduled_expenses_use_case.dart';
import 'package:silenti/core/models/scheduled_expense.dart';
import 'package:silenti/presentation/forms/scheduled_expense_form.dart';

/// PRD.md H3.1–H3.4: a chronological timeline of upcoming periodic
/// expenses, with push reminders (WORK_PLAN.md 2.3). Registering the real
/// transaction when one of these comes due is still manual — this page is
/// visibility only, it never creates an Operation.
class ScheduledExpensesPage extends StatefulWidget {
  const ScheduledExpensesPage({super.key});

  @override
  State<ScheduledExpensesPage> createState() => _ScheduledExpensesPageState();
}

class _ScheduledExpensesPageState extends State<ScheduledExpensesPage> {
  bool _isLoading = true;
  List<ScheduledExpense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    var response = await GetScheduledExpensesUseCase().execute();
    setState(() {
      _expenses = response.status ? response.model! : [];
      _isLoading = false;
    });
  }

  _add(ScheduledExpense expense) async {
    var response = await AddScheduledExpenseUseCase().execute(expense);
    if (response.status) {
      await _load();
    } else if (kDebugMode) {
      print(response.message);
    }
  }

  _delete(ScheduledExpense expense) async {
    var response = await DeleteScheduledExpenseUseCase().execute(expense.id);
    if (response.status) {
      await _load();
    } else if (kDebugMode) {
      print(response.message);
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Scaffold(
          appBar: AppBar(title: const Text("Nuevo gasto periódico")),
          body: Container(
            padding: const EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width,
            child: ScheduledExpenseForm(
              onSave: (value) {
                if (value is ScheduledExpense) {
                  _add(value);
                }
                Navigator.pop(context);
              },
              expense: ScheduledExpense(
                id: 0,
                categoryId: 0,
                name: "",
                dueDay: 1,
                reminderDaysBefore: 3,
              ),
              buttonText: "Guardar",
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Gastos periódicos")),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: _expenses.isEmpty
          ? const Center(child: Text("No hay gastos periódicos programados."))
          : ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final expense = _expenses[index];
                final due = expense.nextDueDate();
                final daysUntilDue = due
                    .difference(DateTime(
                        DateTime.now().year, DateTime.now().month, DateTime.now().day))
                    .inDays;
                return ListTile(
                  leading: const Icon(Icons.event_repeat),
                  title: Text(expense.name),
                  subtitle: Text(
                      "Vence el ${due.day}/${due.month}/${due.year} · en $daysUntilDue día(s) · aviso ${expense.reminderDaysBefore} día(s) antes"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(expense),
                  ),
                );
              },
            ),
    );
  }
}
