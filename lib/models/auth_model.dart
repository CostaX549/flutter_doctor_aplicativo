import 'package:flutter/material.dart';
import 'dart:convert';

class AuthModel extends ChangeNotifier {
  bool _isLogin = false;
  Map<String, dynamic> user = {};
  Map <String, dynamic> appointment = {};
  List <Map<String, dynamic>> favDoc = [];
  List <dynamic> _fav = [];
  bool get isLogin {
    return _isLogin;
  }

  List<dynamic> get getFav {
    return _fav;
  }

  Map<String, dynamic> get getUser {
    return user;
  }

   Map<String, dynamic> get getAppointment {
    return appointment;
  }

  

  void setFavList(List<dynamic> list) {
    _fav = list;
    notifyListeners();
  }

    List<Map<String, dynamic>> get getFavDoc {
    favDoc.clear(); //clear all previous record before get latest list

    //list out doctor list according to favorite list
    for (var num in _fav) {
      for (var doc in user['doctor']) {
        if (num == doc['doc_id']) {
          favDoc.add(doc);
        }
      }
    }
    return favDoc;
  }

   void loginSuccess(
      Map<String, dynamic> userData, Map<String, dynamic> appointmentInfo) {
    _isLogin = true;

    //update all these data when login
    user = userData;
    appointment = appointmentInfo;
    if (user['details']['fav'] != null) {
      _fav = json.decode(user['details']['fav']); 
    }

    notifyListeners();
  }
}
