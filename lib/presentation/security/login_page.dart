import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_colors.dart';
import 'package:silenti/core/models/user.dart';
import 'package:silenti/presentation/components/wrap_gradient_backgroud.dart';
import 'package:silenti/presentation/home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double columnWidth = 300;
  bool isRegister = false;
  LinearGradient gradient = LinearGradient(
    stops: [
      0.1,
      0.9,
    ],
    colors: [
      SilentiColors.primary,
      SilentiColors.dark,
    ],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  Future<User> sesionInit() {
    throw UnimplementedError();
  }

  Widget _login(BuildContext context) {
    if (kDebugMode) {
      print("login");
    }
    Widget result = WrapGradientBackground(
      gradient: gradient,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.transparent,
        alignment: Alignment.center,
        child: Card(
          color: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10)),
              width: double.infinity,
              height: 350,
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    child: Icon(
                      Icons.monetization_on,
                      size: 100,
                      color: SilentiColors.secondary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    width: columnWidth,
                    height: 30,
                    child: Padding(
                        padding: EdgeInsets.all(5),
                        child: TextField(
                          style: TextStyle(color: SilentiColors.white),
                          obscureText: true,
                          controller: TextEditingController(),
                          decoration: InputDecoration(
                            icon: Icon(
                              Icons.password,
                              color: SilentiColors.white,
                            ),
                            hintStyle: TextStyle(
                              color: SilentiColors.white,
                            ),
                            label: Text(
                              "password",
                              style: TextStyle(
                                color: SilentiColors.white,
                              ),
                            ),
                          ),
                        )),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: columnWidth,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!isRegister) {
                          try {
                            var sesion = await sesionInit();
                            sesion; //TODO manage sesion information
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(
                                  title: "silenti",
                                ),
                              ),
                            );
                          } catch (e) {
                            if (kDebugMode) {
                              print(e);
                            }
                            //TODO: show error message and remove navigator push
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(
                                  title: "silenti",
                                ),
                              ),
                            );
                          }
                        }
                        setState(() {});
                      },
                      child: Text('Ingresar'),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: columnWidth,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isRegister) {
                          isRegister = false;
                        } else {
                          isRegister = true;
                        }
                        setState(() {});
                      },
                      child: Text('Registrarse'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return result;
  }

  Widget _register(BuildContext context) {
    print("register");
    Widget result = WrapGradientBackground(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container(
            //   width: columnWidth,
            //   height: columnWidth,
            //   decoration: BoxDecoration(
            //     image: DecorationImage(
            //       image: AssetImage('assets/images/logo.png'),
            //     ),
            //   ),
            // ),
            Container(
              width: columnWidth,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Usuario',
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: columnWidth,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: columnWidth,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Repetir Contraseña',
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: columnWidth,
              child: ElevatedButton(
                onPressed: () {
                  if (isRegister) {
                    isRegister = false;
                  } else {
                    isRegister = true;
                  }
                  setState(() {});
                },
                child: Text('Ingresar'),
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: columnWidth,
              child: ElevatedButton(
                onPressed: () {
                  if (!isRegister) {
                    isRegister = true;
                  } else {
                    isRegister = false;
                  }
                  setState(() {});
                },
                child: Text('Registrarse'),
              ),
            ),
          ],
        ),
      ),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isRegister ? _register(context) : _login(context),
    );
  }
}
