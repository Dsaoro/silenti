import re

with open('lib/presentation/security/login_page.dart', 'r') as f:
    content = f.read()

if "import 'package:flutter_riverpod/flutter_riverpod.dart';" not in content:
    content = "import 'package:flutter_riverpod/flutter_riverpod.dart';\n" + content
    content = "import 'package:silenti/application/shared/providers.dart';\n" + content

content = content.replace("class LoginPage extends StatefulWidget", "class LoginPage extends ConsumerStatefulWidget")
content = content.replace("State<LoginPage> createState() => _LoginPageState();", "ConsumerState<LoginPage> createState() => _LoginPageState();")
content = content.replace("class _LoginPageState extends State<LoginPage>", "class _LoginPageState extends ConsumerState<LoginPage>")

content = re.sub(r'AuthUseCase\(\)\.getLocalUser\(\)', r'ref.read(authUseCaseProvider).getLocalUser()', content)
content = re.sub(r'AuthUseCase\(\)\.login\((.*?)\)', r'ref.read(authUseCaseProvider).login(\1)', content)

with open('lib/presentation/security/login_page.dart', 'w') as f:
    f.write(content)
