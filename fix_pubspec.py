with open('pubspec.yaml', 'r') as f:
    content = f.read()

deps = """
  flutter_riverpod: ^2.5.1
  get_it: ^7.7.0
  injectable: ^2.4.1
"""

dev_deps = """
  build_runner: ^2.4.9
  injectable_generator: ^2.4.1
"""

if 'flutter_riverpod' not in content:
    content = content.replace("  awesome_snackbar_content: ^0.1.5", "  awesome_snackbar_content: ^0.1.5" + deps)
    content = content.replace("  flutter_lints: ^5.0.0", "  flutter_lints: ^5.0.0" + dev_deps)
    with open('pubspec.yaml', 'w') as f:
        f.write(content)
