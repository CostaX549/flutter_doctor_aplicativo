import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/auth_model.dart';
import 'package:flutter_application_1/utils/config.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_application_1/providers/dio_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({super.key, required this.social});

  final String social;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        side: const BorderSide(width: 1, color: Colors.black),
      ),
      onPressed: () async {
        if (social.toLowerCase() == 'google') {
          await _handleGoogleSignIn(context);
        }
      },
      child: SizedBox(
        width: Config.widthSize * 0.4,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Image.asset(
              'assets/$social.png',
              width: 40,
              height: 40,
            ),
            Text(
              social.toUpperCase(),
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final auth = Provider.of<AuthModel>(context, listen: false);

    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return; // Usuário cancelou o login
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String accessToken = googleAuth.accessToken!;
      const String provider = 'google';

      final dioProvider = DioProvider();
      final success = await dioProvider.socialLogin(accessToken, provider);

      if (success) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final tokenValue = prefs.getString('token') ?? '';
        print(" $tokenValue");
        if (tokenValue.isNotEmpty) {
          final response = await DioProvider().getUser(tokenValue);
          String? firebaseToken = await FirebaseMessaging.instance.getToken();

if (firebaseToken != null) {
await DioProvider().storeToken(firebaseToken, tokenValue);

}
          if (response != null) {
            Map<String, dynamic> appointment = {};
            final user = json.decode(response);
            print(response);
            for (var doctorData in user['doctor']) {
              if (doctorData['appointments'] != null) {
                appointment = doctorData;
              }
            }

            auth.loginSuccess(user, appointment);

            // Navegação para a tela principal após sucesso no login
            MyApp.navigatorKey.currentState!.pushNamed('main');
          }
        }
      }

    } catch (error) {
       print(error);
    }
  }
}