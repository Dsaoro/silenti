import re

with open('lib/presentation/budget_page.dart', 'r') as f:
    content = f.read()

if "import 'package:flutter_riverpod/flutter_riverpod.dart';" not in content:
    content = "import 'package:flutter_riverpod/flutter_riverpod.dart';\n" + content
    content = "import 'package:silenti/presentation/state/budgets_provider.dart';\n" + content
    content = "import 'package:silenti/application/shared/providers.dart';\n" + content

content = content.replace("class BudgetPage extends StatefulWidget", "class BudgetPage extends ConsumerStatefulWidget")
content = content.replace("State<BudgetPage> createState() => _BudgetPageState();", "ConsumerState<BudgetPage> createState() => _BudgetPageState();")
content = content.replace("class _BudgetPageState extends State<BudgetPage>", "class _BudgetPageState extends ConsumerState<BudgetPage>")

# Use Cases manual substitution:
content = re.sub(r'GetExpensesCategoriesUseCase\(\)\.execute\(\)', r'ref.read(getExpensesCategoriesUseCaseProvider).execute()', content)
content = re.sub(r'DeleteBudgetCategoryUseCase\(\)\.execute\((.*?)\)', r'ref.read(deleteBudgetCategoryUseCaseProvider).execute(\1)', content)
content = re.sub(r'GetIncomeTypesUseCase\(\)\.execute\(\)', r'ref.read(getIncomeTypesUseCaseProvider).execute()', content)


with open('lib/presentation/budget_page.dart', 'w') as f:
    f.write(content)
