import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beawake/providers/event_manager.dart';

class AnimatedToggleButton extends StatefulWidget {
  const AnimatedToggleButton({Key? key}) : super(key: key);

  @override
  _AnimatedToggleButtonState createState() => _AnimatedToggleButtonState();
}

class _AnimatedToggleButtonState extends State<AnimatedToggleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventManager>(
      builder: (context, eventManager, child) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: GestureDetector(
              onTapDown: (_) => _controller.forward(),
              onTapUp: (_) async {
                _controller.reverse();
                bool success = await eventManager.toggleEvent();
                if (!success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Cannot add the same event type consecutively.")),
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
                      colors: eventManager.isAwake 
                          ? [Colors.orange[300]!, Colors.orange[500]!] 
                          : [Colors.blue[700]!, Colors.blue[900]!],
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
                    child: eventManager.isAwake
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
      },
    );
  }
}