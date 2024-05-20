import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beawake/providers/event_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimatedToggleButton extends StatefulWidget {
  const AnimatedToggleButton({Key? key}) : super(key: key);

  @override
  _AnimatedToggleButtonState createState() => _AnimatedToggleButtonState();
}

class _AnimatedToggleButtonState extends State<AnimatedToggleButton> with SingleTickerProviderStateMixin {
  bool isAwake = true;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    initIsAwake();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void initIsAwake() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String lastEventType = await Provider.of<EventManager>(context, listen: false).getLastEvent();
      setState(() {
        isAwake = lastEventType != 'awake';
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GestureDetector(
          onTapDown: (_) {
            _controller.forward();
          },
          onTapUp: (_) async {
            _controller.reverse();
            String eventType = isAwake ? 'sleep' : 'awake';
            bool success = await Provider.of<EventManager>(context, listen: false).addEvent(eventType);
            if (success) {
              setState(() {
                isAwake = !isAwake;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Invalid transition: Can't toggle $eventType consecutively.")),
              );
            }
          },
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isAwake ? [Colors.orange[300]!, Colors.orange[500]!] : [Colors.blue[700]!, Colors.blue[900]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                borderRadius: BorderRadius.circular(75),
              ),
              child: Center(
                child: isAwake
                    ? Icon(Icons.wb_sunny, size: 80, color: Colors.white)
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.nightlight_round, size: 80, color: Colors.white),
                          Positioned(
                            top: 20,
                            child: Icon(Icons.star, size: 20, color: Colors.yellow[600]),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}