with open('lib/main.dart', 'r') as f:
    content = f.read()

import_lines = "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:silenti/infraestructure/di/injection.dart';\n"
if "package:flutter_riverpod/flutter_riverpod.dart" not in content:
    content = import_lines + content

content = content.replace("  runApp(const MyApp());", "  configureDependencies();\n  runApp(\n    const ProviderScope(\n      child: MyApp(),\n    ),\n  );")

with open('lib/main.dart', 'w') as f:
    f.write(content)
