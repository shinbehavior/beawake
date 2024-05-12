import 'package:beawake/providers/event_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimatedToggleButton extends StatefulWidget {
  const AnimatedToggleButton({super.key});
  @override
  _AnimatedToggleButtonState createState() => _AnimatedToggleButtonState();
}

class _AnimatedToggleButtonState extends State<AnimatedToggleButton> {
  bool isAwake = true; // Initial state of the button

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    initIsAwake(); 
  }

  void initIsAwake() async {
    // Example: Assuming getLastEvent returns the last event type
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String lastEventType = await Provider.of<EventManager>(context, listen: false).getLastEvent();
      setState(() {
        isAwake = lastEventType != 'awake';
      });
    });
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        print("Current state: $isAwake");
        String eventType = isAwake ? 'sleep' : 'awake';
        bool success = await Provider.of<EventManager>(context, listen: false).addEvent(eventType);
        if (success) {
          setState((){
            isAwake = !isAwake;
            print("State toggled to: $isAwake");
          });
        } else {
          setState(() {
            isAwake = !isAwake;
            print("State forcibly toggled due to error handling.");
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Invalid transition: Can't toggle $eventType consecutively."))
          );
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500), // Animation duration
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: isAwake ? Colors.orange[300] : Colors.blue[900], // Background color change
          borderRadius: BorderRadius.circular(50), // Circular button
        ),
        child: Center(
          child: isAwake 
            ? Icon(Icons.wb_sunny, size: 60, color: Colors.white) // Sun icon
            : Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.nightlight_round, size: 60, color: Colors.white),
                Icon(Icons.star, size:20, color: Colors.yellow[600],),
              ],
            ),
        ),
      ),
    );
  }
}
