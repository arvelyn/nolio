import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'data/todo_db.dart';
import 'features/calendar/calendar_page.dart';
import 'features/todos/todos_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await TodoDB.instance.init();

  const windowOptions = WindowOptions(
    titleBarStyle: TitleBarStyle.hidden,
    backgroundColor: Colors.transparent,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const NolioApp());
}

class NolioApp extends StatelessWidget {
  const NolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nolio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1DB954),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  DateTime selectedDate = DateTime.now();
  final PageController controller = PageController();

  void goToTodos() {
    controller.animateToPage(
      1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      CalendarPage(
        selectedDate: selectedDate,
        onDateSelected: (d) => setState(() => selectedDate = d),
        onOpenTodos: goToTodos,
      ),
      TodosPage(selectedDate: selectedDate),
      const Center(
        child: Text(
          'Timer (coming soon)',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    ];

    return Scaffold(
      body: PageView(
        controller: controller,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (i) => setState(() => index = i),
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          controller.animateToPage(
            i,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle),
            label: 'Todos',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
        ],
      ),
    );
  }
}
