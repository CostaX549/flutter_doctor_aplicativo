import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/components/custom_appbar.dart';
import 'package:flutter_application_1/models/auth_model.dart';
import 'package:flutter_application_1/providers/dio_provider.dart';
import 'package:flutter_application_1/utils/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Importa o url_launcher

class DoctorDetails extends StatefulWidget {
  const DoctorDetails({super.key, required this.doctor, required this.isFav});
  final Map<String, dynamic> doctor;
  final bool isFav;

  @override
  State<DoctorDetails> createState() => _DoctorDetailsState();
}

class _DoctorDetailsState extends State<DoctorDetails> {
  Map<String, dynamic> doctor = {};
  bool isFav = false;

  @override
  void initState() {
    doctor = widget.doctor;
    isFav = widget.isFav;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appTitle: 'Detalhes do Doutor',
        icon: const FaIcon(Icons.arrow_back_ios),
        actions: [
          IconButton(
            onPressed: () async {
              final list = Provider.of<AuthModel>(context, listen: false).getFav;
              if (list.contains(doctor['doc_id'])) {
                list.removeWhere((id) => id == doctor["doc_id"]);
              } else {
                list.add(doctor['doc_id']);
              }
              Provider.of<AuthModel>(context, listen: false).setFavList(list);

              final SharedPreferences prefs = await SharedPreferences.getInstance();
              final token = prefs.getString("token") ?? '';
              if (token.isNotEmpty && token != '') {
                final response = await DioProvider().storeFavDoc(token, list);
                if (response == 200) {
                  setState(() {
                    isFav = !isFav;
                  });
                }
              }
            },
            icon: FaIcon(
              isFav ? Icons.favorite_rounded : Icons.favorite_outline,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              AboutDoctor(doctor: doctor),
              DetailBody(doctor: doctor), // O DetailBody foi atualizado
              Padding(
                padding: const EdgeInsets.all(10),
                child: Button(
                  width: double.infinity,
                  title: 'Agendar Consulta',
                  onPressed: () {
                    Navigator.of(context).pushNamed('booking_page', arguments: {
                      "doctor_id": doctor['doc_id'],
                      "doctor": doctor,
                    });
                  },
                  disable: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AboutDoctor extends StatelessWidget {
  const AboutDoctor({super.key, required this.doctor});

  final Map<dynamic, dynamic> doctor;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Container(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 65.0,
            backgroundImage: NetworkImage("${doctor['doctor_profile']}"),
            backgroundColor: Colors.white,
          ),
          Config.spaceMedium,
          Text(
            'Dr ${doctor['doctor_name']}',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Config.spaceSmall,
          SizedBox(
            width: Config.widthSize * 0.75,
            child: const Text(
              'MBBS (International Medical University, Malaysia), MRCP (Royal College of Physics, United Kingdom)',
              style: TextStyle(color: Colors.grey, fontSize: 15),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
          Config.spaceSmall,
          SizedBox(
            width: Config.widthSize * 0.75,
            child: const Text(
              'Sarawak General Hospital',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class DetailBody extends StatelessWidget {
  const DetailBody({super.key, required this.doctor});
  final Map<dynamic, dynamic> doctor;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Config.spaceSmall,
          DoctorInfo(patients: doctor['patients'], exp: doctor['experience']),
          Config.spaceMedium,
          const Text(
            'Sobre o Doutor',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          Config.spaceSmall,
          Text(
            'Dr. ${doctor['doctor_name']} é um(a) especialista em ${doctor['category']} com vasta experiência no Hospital Geral de Sarawak.',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            softWrap: true,
            textAlign: TextAlign.justify,
          ),
          Config.spaceSmall,
          Text(
            'Localização: ${doctor['local']['address']}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          Config.spaceSmall,
          Container(
            height: 300, // Altura do mapa
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  doctor['local']['latitude'],
                  doctor['local']['longitude'],
                ),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('doctor_location'),
                  position: LatLng(
                    doctor['local']['latitude'],
                    doctor['local']['longitude'],
                  ),
                ),
              },
            ),
          ),
          Config.spaceSmall, // Espaço entre o mapa e o botão
          Padding(
            padding: const EdgeInsets.all(0),
            child: Button(
              width: double.infinity,
              title: 'Ir até o Local',
              onPressed: () {
                // Ação para iniciar a corrida, como abrir um aplicativo de navegação
                openMap(
                  doctor['local']['latitude'],
                  doctor['local']['longitude'],
                );
              },
              disable: false,
            ),
          ),
        ],
      ),
    );
  }

  // Função para abrir o aplicativo de navegação
 static Future<void> openMap(double latitude, double longitude) async {
  String googleUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
  if (await canLaunchUrl(Uri.parse(googleUrl))) {
    await launchUrl(Uri.parse(googleUrl));
  } else {
    throw 'Could not open the map.';
  }
}
}
class DoctorInfo extends StatelessWidget {
  const DoctorInfo({super.key, required this.patients, required this.exp});

  final int patients;
  final int exp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        InfoCard(label: 'Pacientes', value: '$patients'),
        const SizedBox(width: 15),
        InfoCard(label: 'Experiência', value: '$exp anos'),
        const SizedBox(width: 15),
        const InfoCard(label: 'Avaliação', value: '4.6'),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Config.primaryColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Column(
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
