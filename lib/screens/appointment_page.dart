import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/dio_provider.dart';
import 'package:flutter_application_1/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

enum FilterStatus { futuro, completo, cancelado }



class _AppointmentPageState extends State<AppointmentPage> {
  FilterStatus status = FilterStatus.futuro;
Alignment _alignment = Alignment.centerLeft;
List<dynamic> schedules = [
 
];

Future<void> getAppointments() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token") ?? '';
  final appointment = await DioProvider().getAppointments(token);
  if(appointment != 'Error' && mounted) {
    setState(() {
      schedules = json.decode(appointment);
    
    });
  }
}
@override
void initState() {
     super.initState(); 
  getAppointments();


}
  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredSchedules = schedules.where((var schedule) {

      switch (schedule['status']) {
        case 'futuro':
          schedule['status'] = FilterStatus.futuro;
          break;
        case 'completo'  :
        schedule['status'] = FilterStatus.completo;
          break;
        case 'cancelado'  :
        schedule['status'] = FilterStatus.cancelado;
          break;
      }
     
      return schedule['status'] == status;
    }).toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 20, right:20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text('Agenda de Consultas', textAlign: TextAlign.center, style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),),
           Config.spaceSmall,
           Stack(  
            children: [
              Container(
               width: double.infinity,
               height: 40,
               decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20)
               ),
               child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [ 
                  for(FilterStatus filterStatus in FilterStatus.values) 
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if(filterStatus == FilterStatus.futuro) {
                              status = FilterStatus.futuro;
                              _alignment = Alignment.centerLeft;
                            } else if(filterStatus == FilterStatus.completo) {
                               status = FilterStatus.completo;
                              _alignment = Alignment.center;
                            } else if(filterStatus == FilterStatus.cancelado) {
                               status = FilterStatus.cancelado;
                              _alignment = Alignment.centerRight;
                            }
                          });
                        },
                        child: Center(child: Text(filterStatus.name))
                      )
                      ),
                 
                ],
               ),
              ),
              AnimatedAlign(
                alignment: _alignment, 
                duration: const Duration(milliseconds: 200),
                child: Container( 
                  width: 100,
                  height: 40,
                  decoration:  BoxDecoration(
                    color: Config.primaryColor,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Center(
                    child: Text(
                      status.name, 
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                ),
                ),
            ],
           ),
           Config.spaceSmall,
           Expanded(
            child: ListView.builder(
              itemCount: filteredSchedules.length,
              itemBuilder: ((context, index) {
                var _schedule = filteredSchedules[index];
                bool isLastElement = filteredSchedules.length + 1 == index;
                return Card(
                  color: Colors.white,
                 shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(20)
                 ),
                 margin: !isLastElement ? const EdgeInsets.only(bottom: 20) : EdgeInsets.zero,
                 child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column( 
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(_schedule['doctor_profile']),
                          ),
                         const SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text( 
                                _schedule['doctor_name'],
                                style: const TextStyle(
                                 color: Colors.black,
                                 fontWeight: FontWeight.w700
                                ),
                              ),
                              const SizedBox(height: 5,),
                                Text( 
                                _schedule['category'],
                                style: const TextStyle(
                                 color: Colors.grey,
                                 fontSize: 12,
                                 fontWeight: FontWeight.w600
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                        const SizedBox(height: 15,),
                        ScheduleCard(
                          date: _schedule['date'],
                          day: _schedule['day'],
                          time: _schedule['time']
                        ),
                             const SizedBox(height: 15,),
                             Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                              Expanded( 
                                child: OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('Cancelar', style: TextStyle(color: Config.primaryColor))
                                )
                              ),
                              const SizedBox(width:20,),
                              Expanded( 
                                child: OutlinedButton(
                                  style:  OutlinedButton.styleFrom(
                                    backgroundColor: Config.primaryColor
                                  ),
                                  onPressed: () {},
                                  child: const Text('Reagendar', style: TextStyle(color: Colors.white))
                                )
                              ),
                             ],
                             ),
                    ]
                  )
                 )
                );
              }),
            )
           )
          ],
        )
      )
      );
  }
}

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({super.key, required this.date, required this.day, required this.time});
  final String date;
  final String day;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child:  Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Icon(Icons.calendar_today, color: Config.primaryColor, size: 15),
          const SizedBox(
            width: 5,
          ),
          Text('$day, $date', style: const TextStyle(color: Config.primaryColor)),
          const SizedBox(
            width: 20,
          ),
          const Icon(Icons.access_alarm, color: Config.primaryColor, size: 17),
          const SizedBox(
            width: 5,
          ),
           Flexible(
              child: Text(time, style: const TextStyle(color: Config.primaryColor)))
        ],
      ),
    );
  }
}

