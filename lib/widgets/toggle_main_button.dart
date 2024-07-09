import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_manager.dart';

class AnimatedToggleButton extends ConsumerStatefulWidget {
  const AnimatedToggleButton({Key? key}) : super(key: key);

  @override
  _AnimatedToggleButtonState createState() => _AnimatedToggleButtonState();
}

class _AnimatedToggleButtonState extends ConsumerState<AnimatedToggleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotateAnimation;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _iconScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _iconRotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      _controller.value += details.primaryDelta! / 200;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });

    if (_controller.value > 0.5) {
      _controller.animateTo(1.0, curve: Curves.easeOut);
      _toggleState(true);
    } else {
      _controller.animateTo(0.0, curve: Curves.easeOut);
      _toggleState(false);
    }
  }

  void _toggleState(bool isAwake) async {
    final eventManager = ref.read(eventManagerProvider);
    if (isAwake != eventManager.isAwake) {
      bool success = await eventManager.toggleEvent();
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Cannot add the same event type consecutively.")),
        );
        _controller.animateTo(isAwake ? 0.0 : 1.0, curve: Curves.easeOut);
      } else {
        // Trigger icon animation
        _controller.forward(from: 0.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventManager = ref.watch(eventManagerProvider);
    bool isAwake = eventManager.isAwake;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDragging) {
        _controller.animateTo(isAwake ? 1.0 : 0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });

    return Center(
      child: GestureDetector(
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: 200,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[900]!,
                    Color.lerp(Colors.blue[900]!, Colors.orange[300]!, _controller.value)!,
                    Colors.orange[300]!,
                  ],
                  stops: [0.0, _controller.value, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Sleep icon (left side)
                  Positioned(
                    left: 20,
                    top: 25,
                    child: Opacity(
                      opacity: 1 - _controller.value,
                      child: Icon(
                        Icons.nightlight_round,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                  // Awake icon (right side)
                  Positioned(
                    right: 20,
                    top: 25,
                    child: Opacity(
                      opacity: _controller.value,
                      child: Icon(
                        Icons.wb_sunny,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                  // Sliding button
                  Positioned(
                    left: _controller.value * 100,
                    top: 5,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: ScaleTransition(
                          scale: _iconScaleAnimation,
                          child: RotationTransition(
                            turns: _iconRotateAnimation,
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              child: Icon(
                                _controller.value > 0.5 ? Icons.wb_sunny : Icons.nightlight_round,
                                key: ValueKey<bool>(_controller.value > 0.5),
                                color: Color.lerp(Colors.blue[700], Colors.orange[500], _controller.value),
                                size: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}