import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/user.dart';
import 'package:silenti/infraestructure/storage/user_dao.dart';

class AuthUseCase extends BaseUseCase {
  AuthUseCase() : super("AuthUseCase");

  Future<HandleResult<User?>> getLocalUser() async {
    HandleResult<User?> result = HandleResult<User?>();
    UserDAO dao = UserDAO();
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

  Future<HandleResult<bool>> setPassword(String password) async {
    HandleResult<bool> result = HandleResult<bool>();
    UserDAO dao = UserDAO();
    try {
      // In a real app we would hash the password here
      await dao.updateUserPassword(password);
      result.setData(true);
    } catch (e) {
      result.setError(e.toString());
    }
    return result;
  }

  Future<HandleResult<User>> login(String password) async {
    HandleResult<User> result = HandleResult<User>();
    UserDAO dao = UserDAO();
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
