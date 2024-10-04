import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/appointment_card.dart';
import 'package:flutter_application_1/components/doctor_card.dart';
import 'package:flutter_application_1/models/auth_model.dart';
import 'package:flutter_application_1/providers/dio_provider.dart';
import 'package:flutter_application_1/utils/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> user = {};
  Map<String, dynamic> doctor = {};
  List<dynamic> favList = [];

  List<Map<String, dynamic>> medCat = [
    
    {"icon": FontAwesomeIcons.brain, "category": "Psiquiatra"},
  ];

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    user = Provider.of<AuthModel>(context, listen: false).getUser;
    doctor = Provider.of<AuthModel>(context, listen: false).getAppointment;
    favList = Provider.of<AuthModel>(context, listen: false).getFav;
    print('user data is : $user');
    print('favorite list data is : $favList');
 
    return Scaffold(
      body: user.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            user['name'],
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  NetworkImage('${user['profile_photo_url']}'),
                            ),
                          )
                        ],
                      ),
                      Config.spaceSmall,
                      const Text('Categoria',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Config.spaceSmall,
                      SizedBox(
                          height: Config.heightSize * 0.05,
                          child: ListView(
                              scrollDirection: Axis.horizontal,
                              children:
                                  List<Widget>.generate(medCat.length, (index) {
                                return Card(
                                  margin: const EdgeInsets.only(right: 20),
                                  color: Config.primaryColor,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        FaIcon(medCat[index]['icon'],
                                            color: Colors.white),
                                        const SizedBox(width: 20),
                                        Text(medCat[index]['category'],
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white))
                                      ],
                                    ),
                                  ),
                                );
                              }))),
                      Config.spaceSmall,
                      const Text('Agendamentos de Hoje',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Config.spaceSmall,
                      doctor.isNotEmpty
                          ? AppointmentCard(
                              doctor: doctor, color: Config.primaryColor)
                          : Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text('Nenhum Agendamento Hoje',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                ),
                              )),
                      Config.spaceSmall,
                      const Text('Melhores Doutores',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Config.spaceSmall,
                      Column(
                          children:
                              List.generate(user['doctor'].length, (index) {
                        return DoctorCard(
                           
                            doctor: user['doctor'][index],
                            isFav: favList.contains(user['doctor'][index]['doc_id']) ? true : false,

                            );
                      }))
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
