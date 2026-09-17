import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/user.dart';
import 'package:silenti/infraestructure/storage/user_dao.dart';

class AuthUseCase extends BaseUseCase {
  final UserDAO dao;
  AuthUseCase({UserDAO? dao})
      : dao = dao ?? UserDAO(),
        super("AuthUseCase");

  Future<HandleResult<User?>> getLocalUser() async {
    HandleResult<User?> result = HandleResult<User?>();
    try {
      final userMap = await dao.getUser();
      if (userMap != null) {
        result.setData(User.fromMap(userMap));
      } else {
        result.setData(null);
      }
    } catch (e) {
      result.setError(e.toString());
    }
    return result;
  }

  Future<HandleResult<bool>> registerUser(
      String name, String email, String password) async {
    HandleResult<bool> result = HandleResult<bool>();
    try {
      // In a real app we would hash the password here
      await dao.registerUser(name, email, password);
      result.setData(true);
    } catch (e) {
      result.setError(e.toString());
    }
    return result;
  }

  Future<HandleResult<User>> login(String password) async {
    HandleResult<User> result = HandleResult<User>();
    try {
      final userMap = await dao.getUser();
      if (userMap != null) {
        final user = User.fromMap(userMap);
        if (user.password == password) {
          result.setData(user);
        } else {
          result.setError("Contraseña incorrecta");
        }
      } else {
        result.setError("Usuario no encontrado");
      }
    } catch (e) {
      result.setError(e.toString());
    }
    return result;
  }
}
