import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../data/todo_db.dart';

enum _TimerMode { work, breakTime }

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final TextEditingController _workCtrl = TextEditingController(text: '25');
  final TextEditingController _breakCtrl = TextEditingController(text: '5');

  Timer? _ticker;
  _TimerMode _mode = _TimerMode.work;
  bool _running = false;
  bool _autoCycle = true;
  bool _isTransitioning = false;

  int _remainingSeconds = 25 * 60;
  int _activeSessionSeconds = 25 * 60;

  Map<String, int> _todayTotals = {'work': 0, 'break': 0, 'total': 0};
  List<Map<String, dynamic>> _dailyStats = [];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _durationFor(_mode);
    _activeSessionSeconds = _remainingSeconds;
    _loadStats();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _workCtrl.dispose();
    _breakCtrl.dispose();
    super.dispose();
  }

  String _dateKey(DateTime d) => d.toIso8601String().split('T')[0];

  int _safeMinutes(TextEditingController ctrl, int fallback) {
    final parsed = int.tryParse(ctrl.text.trim());
    if (parsed == null || parsed <= 0) return fallback;
    return parsed;
  }

  int _durationFor(_TimerMode mode) {
    if (mode == _TimerMode.work) return _safeMinutes(_workCtrl, 25) * 60;
    return _safeMinutes(_breakCtrl, 5) * 60;
  }

  String _modeLabel(_TimerMode mode) {
    return mode == _TimerMode.work ? 'Work/Study' : 'Break';
  }

  String _formatClock(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final hrs = minutes ~/ 60;
    final mins = minutes % 60;
    if (hrs == 0) return '${mins}m';
    return '${hrs}h ${mins}m';
  }

  String _displayDate(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return key;
    return '${parts[1]}/${parts[2]}';
  }

  Future<void> _loadStats() async {
    final today = _dateKey(DateTime.now());
    final totals = await TodoDB.instance.getTimerTotalsForDate(today);
    final daily = await TodoDB.instance.getTimerDailyStats(limit: 14);
    if (!mounted) return;
    setState(() {
      _todayTotals = totals;
      _dailyStats = daily;
    });
  }

  void _start() {
    if (_running) return;
    setState(() => _running = true);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted || _isTransitioning) return;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds -= 1);
      }
      if (_remainingSeconds == 0) {
        await _onSessionFinished();
      }
    });
  }

  void _pause() {
    _ticker?.cancel();
    setState(() => _running = false);
  }

  void _resetCurrentMode() {
    _pause();
    setState(() {
      _remainingSeconds = _durationFor(_mode);
      _activeSessionSeconds = _remainingSeconds;
    });
  }

  void _applySetup() {
    _resetCurrentMode();
  }

  void _switchMode(_TimerMode mode) {
    _pause();
    setState(() {
      _mode = mode;
      _remainingSeconds = _durationFor(mode);
      _activeSessionSeconds = _remainingSeconds;
    });
  }

  Future<void> _onSessionFinished() async {
    if (_isTransitioning) return;
    _isTransitioning = true;
    _ticker?.cancel();

    final finishedMode = _mode;
    final finishedSeconds = _activeSessionSeconds;

    await TodoDB.instance.addTimerLog(
      date: _dateKey(DateTime.now()),
      type: finishedMode == _TimerMode.work ? 'work' : 'break',
      seconds: finishedSeconds,
    );

    await _loadStats();

    if (mounted) {
      final nextMode = finishedMode == _TimerMode.work
          ? _TimerMode.breakTime
          : _TimerMode.work;
      final note = _autoCycle
          ? '${_modeLabel(finishedMode)} finished. ${_modeLabel(nextMode)} started.'
          : '${_modeLabel(finishedMode)} finished.';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(note), duration: const Duration(seconds: 3)),
        );
    }

    if (!mounted) {
      _isTransitioning = false;
      return;
    }

    if (_autoCycle) {
      final next = finishedMode == _TimerMode.work
          ? _TimerMode.breakTime
          : _TimerMode.work;
      setState(() {
        _mode = next;
        _remainingSeconds = _durationFor(next);
        _activeSessionSeconds = _remainingSeconds;
        _running = true;
      });
      _isTransitioning = false;
      _start();
      return;
    }

    setState(() {
      _running = false;
      _remainingSeconds = _durationFor(finishedMode);
      _activeSessionSeconds = _remainingSeconds;
    });
    _isTransitioning = false;
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final workSeconds = _todayTotals['work'] ?? 0;
    final breakSeconds = _todayTotals['break'] ?? 0;
    final totalSeconds = _todayTotals['total'] ?? 0;
    final workPct = totalSeconds == 0
        ? 0.0
        : (workSeconds / totalSeconds) * 100;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Work/Study'),
                      selected: _mode == _TimerMode.work,
                      onSelected: (_) => _switchMode(_TimerMode.work),
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text('Break'),
                      selected: _mode == _TimerMode.breakTime,
                      onSelected: (_) => _switchMode(_TimerMode.breakTime),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _formatClock(_remainingSeconds),
                  style: TextStyle(
                    fontSize: 68,
                    fontWeight: FontWeight.bold,
                    color: accent,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn().scale(),
                const SizedBox(height: 8),
                Text(
                  _modeLabel(_mode),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 36,
                      icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                      onPressed: _running ? _pause : _start,
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      iconSize: 36,
                      icon: const Icon(Icons.refresh),
                      onPressed: _resetCurrentMode,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Auto cycle: Session -> Break -> Session'),
                  value: _autoCycle,
                  onChanged: (v) => setState(() => _autoCycle = v),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _workCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Work min',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _breakCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Break min',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _applySetup,
                      child: const Text('Set'),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.08),
          const SizedBox(height: 14),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today Stats',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          label: 'Worked/Studied',
                          value: _formatDuration(workSeconds),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatTile(
                          label: 'Break',
                          value: _formatDuration(breakSeconds),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatTile(
                          label: 'Focus %',
                          value: '${workPct.toStringAsFixed(1)}%',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Date-wise Entries',
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _dailyStats.isEmpty
                        ? Center(
                            child: Text(
                              'No timer entries yet',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _dailyStats.length,
                            itemBuilder: (context, i) {
                              final row = _dailyStats[i];
                              final date = row['date']?.toString() ?? '';
                              final ws =
                                  (row['work_seconds'] as num?)?.toInt() ?? 0;
                              final bs =
                                  (row['break_seconds'] as num?)?.toInt() ?? 0;
                              final total = ws + bs;
                              final pct = total == 0 ? 0.0 : (ws / total) * 100;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.06),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 64,
                                      child: Text(
                                        _displayDate(date),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Work ${_formatDuration(ws)} • Break ${_formatDuration(bs)}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    Text('${pct.toStringAsFixed(0)}%'),
                                  ],
                                ),
                              ).animate().fadeIn(
                                delay: Duration(milliseconds: 60 * i),
                                duration: 220.ms,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
