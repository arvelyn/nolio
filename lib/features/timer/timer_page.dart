import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Timer? timer;
  int seconds = 1500;
  bool running = false;
  final minutesCtrl = TextEditingController(text: '25');

  void start() {
    if (running) return;
    running = true;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (seconds == 0) stop();
      setState(() => seconds--);
    });
  }

  void stop() {
    timer?.cancel();
    setState(() => running = false);
  }

  void reset() {
    stop();
    seconds = int.tryParse(minutesCtrl.text) != null
        ? int.parse(minutesCtrl.text) * 60
        : 1500;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final m = seconds ~/ 60;
    final s = seconds % 60;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ).animate().fadeIn().scale(),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 90,
                child: TextField(
                  controller: minutesCtrl,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Minutes'),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                iconSize: 36,
                icon: Icon(
                    running ? Icons.pause : Icons.play_arrow),
                onPressed: running ? stop : start,
              ),
              IconButton(
                iconSize: 36,
                icon: const Icon(Icons.refresh),
                onPressed: reset,
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
}
