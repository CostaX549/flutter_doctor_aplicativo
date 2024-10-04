import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/auth_model.dart';
import 'package:flutter_application_1/providers/dio_provider.dart';
import 'package:flutter_application_1/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool obsecurePass = true;

  // Estado para armazenar mensagens de erro para os campos
  String? emailErrorMessage;
  String? passwordErrorMessage;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Config.primaryColor,
            decoration: InputDecoration(
              hintText: 'Email',
              labelText: 'Email',
              alignLabelWithHint: true,
              prefixIcon: const Icon(Icons.email_outlined),
              prefixIconColor: Config.primaryColor,
              errorText: emailErrorMessage, // Mensagem de erro para o e-mail
            ),
          ),
          Config.spaceSmall,
          TextFormField(
            controller: _passController,
            keyboardType: TextInputType.visiblePassword,
            cursorColor: Config.primaryColor,
            obscureText: obsecurePass,
            decoration: InputDecoration(
              hintText: 'Senha',
              labelText: 'Senha',
              alignLabelWithHint: true,
              prefixIcon: const Icon(Icons.lock_outline),
              prefixIconColor: Config.primaryColor,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obsecurePass = !obsecurePass;
                  });
                },
                icon: obsecurePass
                    ? const Icon(Icons.visibility_off_outlined, color: Colors.black)
                    : const Icon(Icons.visibility_outlined, color: Config.primaryColor),
              ),
              errorText: passwordErrorMessage, // Mensagem de erro para a senha
            ),
          ),
          Config.spaceSmall,
          Consumer<AuthModel>(builder: (context, auth, child) {
            return Button(
              width: double.infinity,
              title: 'Login',
              onPressed: () async {
                // Limpar mensagens de erro anteriores
                setState(() {
                  emailErrorMessage = null;
                  passwordErrorMessage = null;
                });

                final dynamic token = await DioProvider().getToken(
                  _emailController.text,
                  _passController.text,
                );

                if (token is bool && token) {
                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  final tokenValue = prefs.getString('token') ?? '';
                  if (tokenValue.isNotEmpty && tokenValue != '') {
                    final response = await DioProvider().getUser(tokenValue);

                    // Escuta para atualização de token
                    String? firebaseToken = await FirebaseMessaging.instance.getToken();
                    if (firebaseToken != null) {
                      await DioProvider().storeToken(firebaseToken, tokenValue);
                    }

                    if (response != null) {
                      setState(() {
                        Map<String, dynamic> appointment = {};
                        final user = json.decode(response);
                        for (var doctorData in user['doctor']) {
                          if (doctorData['appointments'] != null) {
                            appointment = doctorData;
                          }
                        }
                        auth.loginSuccess(user, appointment);
                        MyApp.navigatorKey.currentState!.pushNamed('main');
                      });
                    }
                  }
                } else {
                  // Exibe mensagem de erro se as credenciais forem incorretas
                  setState(() {
                    // Verifica se existem erros e atribui mensagens específicas
                    emailErrorMessage = token['errors']['email']?.join(', ') ?? null;
                    
                    // Atribui mensagem de erro apenas se existir
                    if (token['errors']['password'] != null) {
                      passwordErrorMessage = token['errors']['password']!.join(', ');
                    } else {
                      passwordErrorMessage = null; // Não exibe nada se não houver erro
                    }

                    // Se não houver mensagens de erro específicas, exibe mensagem genérica
                    if (emailErrorMessage == null && passwordErrorMessage == null) {
                      emailErrorMessage = 'Erro desconhecido ao fazer login.';
                    }
                  });
                }
              },
              disable: false,
            );
          }),
        ],
      ),
    );
  }
}
