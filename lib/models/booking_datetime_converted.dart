import 'package:intl/intl.dart';

class DateConverted {
   static String getDate(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

  static String getDay(int day) {
    switch (day) {
      case 1:
      return 'Segunda';
      case 2:
      return 'Terça';
      case 3:
      return 'Quarta';
      case 4:
      return 'Quinta';
      case 5:
      return 'Sexta';
      case 6:
      return 'Sábado';
      case 7:
      return 'Domingo';
      default:
      return 'Domingo';
    }
  }

  static String getTime(int time) {
    switch(time) {
      case 0:
      return '9:00';
      case 1:
      return '10:00';
      case 2:
      return '11:00';
      case 3:
      return '12:00';
      case 4:
      return '13:00';
      case 5:
      return '14:00';
      case 6:
      return '15:00';
      case 7:
      return '16:00';
      default: 
      return '9:00';
    }
  }
}