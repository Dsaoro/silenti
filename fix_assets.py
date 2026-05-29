import re

with open('lib/presentation/assets_page.dart', 'r') as f:
    content = f.read()

if "import 'package:flutter_riverpod/flutter_riverpod.dart';" not in content:
    content = "import 'package:flutter_riverpod/flutter_riverpod.dart';\n" + content
    content = "import 'package:silenti/presentation/state/financial_assets_provider.dart';\n" + content

content = content.replace("class AssetsPage extends StatefulWidget", "class AssetsPage extends ConsumerStatefulWidget")
content = content.replace("State<AssetsPage> createState() => _AssetsPageState();", "ConsumerState<AssetsPage> createState() => _AssetsPageState();")
content = content.replace("class _AssetsPageState extends State<AssetsPage>", "class _AssetsPageState extends ConsumerState<AssetsPage>")

# In _AssetsPageState:
# Need to replace the fetching logic with ref.watch
# The original might be calling a use case directly to get assets.
# Replace the build method to use `ref.watch(financialAssetsProvider).when(...)` if applicable.

# Let's see how much we can automatically replace.
# If there's an initState calling the use case, we might need to remove it.
content = re.sub(r'GetFinancialAssetsUseCase\(\)\.execute\(\)', r'ref.read(getAssetsUseCaseProvider).execute()', content)
content = re.sub(r'GetFinancialAssetsBalanceUseCase\(\)\.execute\(\)', r'ref.read(getAssetsBalanceUseCaseProvider).execute()', content)

with open('lib/presentation/assets_page.dart', 'w') as f:
    f.write(content)
