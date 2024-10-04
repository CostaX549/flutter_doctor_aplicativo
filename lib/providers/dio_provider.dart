import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:shared_preferences/shared_preferences.dart';

class DioProvider {
  Future<dynamic> getToken(String email, String password) async {
    try {
       var dio = Dio();

     
      dio.options.headers['Accept'] = 'application/json';
      var response = await dio.post("http://192.168.0.207/api/login",
          data: {'email': email, 'password': password});
      if (response.statusCode == 200 && response.data != '') {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", response.data);
        return true;
      } else {
        return false;
      }
    } catch (error) {
      // Captura de erros do Dio
      if (error is DioException) {
        if (error.response != null && error.response!.data != null) {
          // Retorna a resposta do erro se houver detalhes específicos
          return error.response!.data;
        } else {
          // Retorna uma mensagem de erro genérica de conexão
          return 'Erro de conexão: ${error.message}';
        }
      } else {
        // Retorna uma mensagem de erro genérica para outros tipos de erros
        return 'Erro: $error';
      }
    }
  }

  Future<dynamic> getUser(String token) async {
    try {
      var user = await Dio().get("http://192.168.0.207/api/user",
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (user.statusCode == 200 && user.data != '') {
        return json.encode(user.data);
      }
    } catch (error) {
      return error;
    }
  }

  Future<dynamic> registerUser(
      String username, String email, String password) async {

    try {
           var dio = Dio();

     
      dio.options.headers['Accept'] = 'application/json';
      var user = await dio.post("http://192.168.0.207/api/register",
          data: {'name': username, 'email': email, 'password': password});

      if (user.statusCode == 201 && user.data != '') {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      // Captura de erros do Dio
      if (error is DioException) {
        if (error.response != null && error.response!.data != null) {
          // Retorna a resposta do erro se houver detalhes específicos
          return error.response!.data;
        } else {
          // Retorna uma mensagem de erro genérica de conexão
          return 'Erro de conexão: ${error.message}';
        }
      } else {
        // Retorna uma mensagem de erro genérica para outros tipos de erros
        return 'Erro: $error';
      }
    }
  }

  Future<dynamic> bookAppointment(
      String date, String day, String time, int doctor, String token) async {
    try {
      var response = await Dio().post("http://192.168.0.207/api/book",
          data: {'date': date, 'day': day, 'time': time, 'doctor_id': doctor},
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (response.statusCode == 200 && response.data != 'data') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  Future<dynamic> getAppointments(String token) async {
    try {
      var response = await Dio().get("http://192.168.0.207/api/appointments",
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (response.statusCode == 200 && response.data != 'data') {
        return json.encode(response.data);
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  Future<dynamic> storeReviews(
      String reviews, double ratings, int id, int doctor, String token) async {
    try {
      var response = await Dio().post("http://192.168.0.207/api/reviews",
          data: {
            'ratings': ratings,
            'reviews': reviews,
            'appointment_id': id,
            'doctor_id': doctor
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (response.statusCode == 200 && response.data != 'data') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

   Future<dynamic> storeFavDoc(
      String token, List <dynamic> favList) async {
    try {
      var response = await Dio().post("http://192.168.0.207/api/fav",
           data: {
            'favList': favList
          }, 
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (response.statusCode == 200 && response.data != 'data') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

     Future<dynamic> logout(
      String token) async {
    try {
      var response = await Dio().post("http://192.168.0.207/api/logout",
           
          options: Options(headers: {'Authorization': 'Bearer $token'}));
      if (response.statusCode == 200 && response.data != 'data') {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch (error) {
      return error;
    }
  }

  Future<dynamic> storeToken(String firebaseToken, String token) async {
    try {
 var response = await Dio().post("http://192.168.0.207/api/token",
 options: Options(headers: {'Authorization': 'Bearer $token'}),
           data: {
            'token': firebaseToken
          }, 
        );
         if (response.statusCode == 200) {
        return response.statusCode;
      } else {
        return 'Error';
      }
    } catch(error) {
       return error;
    }
  }

  Future<dynamic> socialLogin(String accessToken, String provider) async {
  try {
    var response = await Dio().post(
      "http://192.168.0.207/api/social_login",
      data: {
        'access_token': accessToken,
        'provider': provider,
      },
    );

    if (response.statusCode == 200) {
      // Salve o token no SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", response.data['data']['token']);
      return true; // Login bem-sucedido
    } else {
      return false; // Falha no login
    }
  } catch (error) {
    return error; // Retornar o erro, se ocorrer
  }
}
}
