import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/auth_model.dart';
import 'package:flutter_application_1/providers/dio_provider.dart';
import 'package:flutter_application_1/utils/config.dart';
import 'package:provider/provider.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool obsecurePass = true;

  // Map para armazenar mensagens de erro para cada campo
  Map<String, String?> errorMessages = {
    'name': null,
    'email': null,
    'password': null,
  };

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            keyboardType: TextInputType.text,
            cursorColor: Config.primaryColor,
            decoration: InputDecoration(
              hintText: 'Nome',
              labelText: 'Nome',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.person_outlined),
              prefixIconColor: Config.primaryColor,
              errorText: errorMessages['name'], // Mensagem de erro para o nome
            ),
          ),
          Config.spaceSmall,
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Config.primaryColor,
            decoration: InputDecoration(
              hintText: 'Email',
              labelText: 'Email',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.email_outlined),
              prefixIconColor: Config.primaryColor,
              errorText: errorMessages['email'], // Mensagem de erro para o e-mail
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
              prefixIcon: Icon(Icons.lock_outline),
              prefixIconColor: Config.primaryColor,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obsecurePass = !obsecurePass;
                  });
                },
                icon: obsecurePass
                    ? Icon(Icons.visibility_off_outlined, color: Colors.black)
                    : Icon(Icons.visibility_outlined, color: Config.primaryColor),
              ),
              errorText: errorMessages['password'], // Mensagem de erro para a senha
            ),
          ),
          Config.spaceSmall,
          Consumer<AuthModel>(
            builder: (context, auth, child) {
              return Button(
                width: double.infinity,
                title: 'Registrar',
                onPressed: () async {
                  // Limpar mensagens de erro anteriores
                  setState(() {
                    errorMessages = {
                      'name': null,
                      'email': null,
                      'password': null,
                    };
                  });

                  final dynamic userRegistration = await DioProvider().registerUser(
                    _nameController.text,
                    _emailController.text,
                    _passController.text,
                  );

                  if (userRegistration is bool && userRegistration) {
                    final token = await DioProvider().getToken(
                      _emailController.text,
                      _passController.text,
                    );

                    if (token) {
                      MyApp.navigatorKey.currentState!.pushNamed('main');
                    }
                  } else   {
                    // Atualiza mensagens de erro com base na resposta
                    setState(() {
                      if (userRegistration['errors'] != null) {
                        final errors = userRegistration['errors'];
                        errorMessages['name'] = errors['name']?.join(', ');
                        errorMessages['email'] = errors['email']?.join(', ');
                        errorMessages['password'] = errors['password']?.join(', ');
                      }
                    });
                  }
                },
                disable: false,
              );
            },
          )
        ],
      ),
    );
  }
}
