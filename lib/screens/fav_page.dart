import "package:flutter/material.dart";
import "package:flutter_application_1/components/doctor_card.dart";
import "package:flutter_application_1/models/auth_model.dart";
import "package:provider/provider.dart";


class FavPage extends StatefulWidget {
  const FavPage({super.key});

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
    child: 
    Padding(
      padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
      child: Column(
        children: [
          const Text(
            'Meus Doutores Preferidos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            )
          ),
          SizedBox(height: 20,),
          Expanded(
            child: 
          Consumer<AuthModel>(
            builder: (context, auth, child) {
                return ListView.builder(
              itemCount: auth.getFavDoc.length,
          
              itemBuilder: (context,index) {
                  
              return DoctorCard(
                
                doctor: auth.getFavDoc[index],
                isFav: true
                ); 
            }
            );
            },
          
          ),
          ),
        ],
      )
      )
    );
  }
}