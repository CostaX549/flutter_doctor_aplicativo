import 'package:flutter/material.dart';
import 'package:flutter_application_1/main_layout.dart';
import 'package:flutter_application_1/models/auth_model.dart';
import 'package:flutter_application_1/screens/auth_page.dart';
import 'package:flutter_application_1/screens/booking_page.dart';
import 'package:flutter_application_1/screens/doctor_details.dart';
import 'package:flutter_application_1/screens/success_booked.dart';
import 'package:flutter_application_1/utils/config.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthModel>(
      create: (context) => AuthModel(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Flutter Doctor App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
         inputDecorationTheme: const InputDecorationTheme(
          focusColor: Config.primaryColor,
          border: Config.outlinedBorder,
          focusedBorder: Config.focusBorder,
          errorBorder: Config.errorBorder,
          enabledBorder: Config.outlinedBorder,
          floatingLabelStyle: TextStyle(color: Config.primaryColor),
          prefixIconColor: Colors.black38
         ),
         scaffoldBackgroundColor: Colors.white,
         bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Config.primaryColor,
            selectedItemColor: Colors.white,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            unselectedItemColor: Colors.grey.shade700,
            elevation: 10,
            type: BottomNavigationBarType.fixed,
         ),
        ),
        initialRoute: '/',
        routes: {
         '/': (context) => const AuthPage(),
         'main': (context) => const MainLayout(),
        /*  'doc_details': (context) => const DoctorDetails(), */
         'booking_page': (context) => const BookingPage(),
         'success_booking': (context) => const AppointmentBooked()
        },
        
      ),
    );
  }
}


