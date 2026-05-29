import re

with open('lib/main.dart', 'r') as f:
    content = f.read()

if "import 'package:flutter_riverpod/flutter_riverpod.dart';" not in content:
    content = "import 'package:flutter_riverpod/flutter_riverpod.dart';\n" + content

if "import 'package:silenti/infraestructure/di/injection.dart';" not in content:
    content = "import 'package:silenti/infraestructure/di/injection.dart';\n" + content

content = content.replace("runApp(const MyApp());", "configureDependencies();\n  runApp(\n    const ProviderScope(\n      child: MyApp(),\n    ),\n  );")

with open('lib/main.dart', 'w') as f:
    f.write(content)
