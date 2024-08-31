import 'package:flutter/material.dart';
import 'package:willow/widgets/home_widgets/emergencies/ambulance_emergency.dart';
import 'package:willow/widgets/home_widgets/emergencies/army_emergency.dart';
import 'package:willow/widgets/home_widgets/emergencies/firebrigade_emergency.dart';
import 'package:willow/widgets/home_widgets/emergencies/police_emergency.dart';

class Emergency extends StatelessWidget {
  const Emergency({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 180,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: const [
          AmbulanceEmergency(),
          ArmyEmergency(),
          PoliceEmergency(),
          FirebrigadeEmergency(),
        ],
      ),
    );
  }
}
