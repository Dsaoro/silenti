import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:silenti/application/security/auth_use_case.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/presentation/components/wrap_gradient_backgroud.dart';
import 'package:silenti/presentation/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double columnWidth = 300;
  bool isRegister = false;
  bool hasPassword = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  LinearGradient gradient = LinearGradient(
    stops: [0.1, 0.9],
    colors: [SilentiColors.primary, SilentiColors.dark],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  void _checkUser() async {
    final result = await AuthUseCase().getLocalUser();
    if (result.status) {
      final user = result.model;
      if (user != null) {
        setState(() {
          hasPassword = user.password.isNotEmpty;
          isRegister = !hasPassword;
        });
      }
    }
  }

  Future<void> _handleLogin() async {
    final result = await AuthUseCase().login(_passController.text);
    if (result.status) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(title: "silenti"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("El nombre y correo no pueden estar vacíos"),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (_passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("La contraseña no puede estar vacía"),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (_passController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    final result = await AuthUseCase().registerUser(
      _nameController.text,
      _emailController.text,
      _passController.text,
    );
    if (result.status) {
      _checkUser();
      setState(() {
        isRegister = false;
        hasPassword = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Contraseña establecida correctamente")),
      );
    }
  }

  Widget _login() {
    if (kDebugMode) {
      print("Return login");
    }
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width * 0.8,
      alignment: Alignment.center,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: Theme.of(context).colorScheme.surface.withAlpha(160),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          width: MediaQuery.of(context).size.width * 0.8,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.monetization_on,
                  size: 100, color: Theme.of(context).colorScheme.onSurface),
              SizedBox(height: 32),
              Text(
                "Ingresa tu contraseña",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 16),
              _buildTextField(_passController, "Contraseña", isPassword: true),
              SizedBox(height: 24),
              SizedBox(
                width: columnWidth,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  child: Text('Ingresar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _register() {
    if (kDebugMode) {
      print("Return register");
    }
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width * 0.9,
      alignment: Alignment.center,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: Theme.of(context).colorScheme.surface.withAlpha(160),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width * 0.9,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security,
                  size: 100, color: Theme.of(context).colorScheme.onSurface),
              SizedBox(height: 28),
              Text(
                "Crea una contraseña local",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                "Tus datos se guardarán de forma privada solo en este dispositivo.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              SizedBox(height: 40),
              _buildTextField(_nameController, "Nombre"),
              SizedBox(height: 16),
              _buildTextField(_emailController, "Correo Electrónico"),
              SizedBox(height: 16),
              _buildTextField(_passController, "Contraseña", isPassword: true),
              SizedBox(height: 16),
              _buildTextField(_confirmPassController, "Repetir Contraseña",
                  isPassword: true),
              SizedBox(height: 24),
              SizedBox(
                width: columnWidth,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                  ),
                  onPressed: _handleRegister,
                  child: Text('Registrar Contraseña'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isPassword = false}) {
    return SizedBox(
      width: columnWidth,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white38)),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: SilentiColors.secondary)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WrapGradientBackground(
        gradient: gradient,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width,
              // height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: isRegister ? _register() : _login(),
            ),
          ),
        ),
      ),
    );
  }
}
