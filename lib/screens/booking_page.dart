import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/button.dart';
import 'package:flutter_application_1/components/custom_appbar.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/booking_datetime_converted.dart';
import 'package:flutter_application_1/providers/dio_provider.dart';
import 'package:flutter_application_1/utils/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusDay = DateTime.now();
  DateTime _currentDay = DateTime.now();
  int? _currentIndex;
  List<int> _availableDays = [];
  List<String> _availableTimeSlots = []; // Mudou para List<String>
  bool _isWeekend = false;
  bool _dateSelected = false;
  bool _timeSelected = false;
  String? token;

  Future<void> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
  }

  @override
  void initState() {
    super.initState();
    getToken();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final doctorDetails = arguments['doctor'];
    print(doctorDetails);
    _availableDays = (doctorDetails['working_hours'] as List)
      .map((entry) => entry['day'] as int)
      .toList();
  }

  void _loadAvailableTimeSlots(int selectedDay) {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final doctorDetails = arguments['doctor'];
    
    _availableTimeSlots.clear(); // Limpa horários anteriores

    for (var hour in doctorDetails['working_hours']) {
      if (hour['day'] == selectedDay) {
        final String startTime = hour['start'];
        final String endTime = hour['end'];
        _availableTimeSlots.addAll(_generateTimeSlots(startTime, endTime, 60)); // 30 minutos de intervalo
      }
    }
  }

  List<String> _generateTimeSlots(String start, String end, int intervalMinutes) {
    List<String> slots = [];
    
    DateTime startTime = DateFormat('HH:mm:ss').parse(start);
    DateTime endTime = DateFormat('HH:mm:ss').parse(end);

    while (startTime.isBefore(endTime)) {
      slots.add(DateFormat('HH:mm').format(startTime));
      startTime = startTime.add(Duration(minutes: intervalMinutes));
    }
    
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final doctor = arguments['doctor_id'];

    return Scaffold(
      appBar: const CustomAppBar(
        appTitle: 'Agendamento',
        icon: FaIcon(Icons.arrow_back_ios),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                _tableCalendar(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                  child: Center(
                    child: Text(
                      'Selecione o Horário da Consulta',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _isWeekend 
            ? SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                  alignment: Alignment.center,
                  child: const Text(
                    'Esse dia não está mais disponível, por favor selecione outra data.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            : SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= _availableTimeSlots.length) return Container();
                    final timeLabel = _availableTimeSlots[index]; // Pega o horário gerado

                    return InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        setState(() {
                          _currentIndex = index;
                          _timeSelected = true;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _currentIndex == index ? Colors.white : Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          color: _currentIndex == index ? Config.primaryColor : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          timeLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _currentIndex == index ? Colors.white : null,
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _availableTimeSlots.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.5,
                ),
              ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 80),
              child: Button(
                width: double.infinity,
                title: 'Fazer Agendamento',
                onPressed: () async {
                  final getDate = DateConverted.getDate(_currentDay);
                  final getDay = DateConverted.getDay(_currentDay.weekday);
                  String getTime = _availableTimeSlots[_currentIndex!];
               
                  final booking = await DioProvider().bookAppointment(
                    getDate,
                    getDay,
                    getTime,
                    doctor,
                    token!,
                  );
                  if (booking == 200) {
                   MyApp.navigatorKey.currentState!.pushNamed('success_booking');
                  }
                },
                disable: _timeSelected && _dateSelected ? false : true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableCalendar() {
    return TableCalendar(
      locale: 'pt_BR',
      focusedDay: _focusDay,
      firstDay: DateTime.now(),
      lastDay: DateTime(2025, 12, 31),
      calendarFormat: _format,
      currentDay: _currentDay,
      rowHeight: 48,
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(color: Config.primaryColor, shape: BoxShape.circle),
      ),
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      onFormatChanged: (format) {
        setState(() {
          _format = format;
        });
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _currentDay = selectedDay;
          _focusDay = focusedDay;
          _dateSelected = true;
          
          if (_availableDays.contains(selectedDay.weekday)) {
            _isWeekend = false; // O dia está disponível
            _loadAvailableTimeSlots(selectedDay.weekday);
          } else {
            _isWeekend = true; // O dia não está disponível
            _timeSelected = false;
            _currentIndex = null;
            _availableTimeSlots.clear(); // Limpa os horários disponíveis
          }
        });
      },
    );
  }
}
