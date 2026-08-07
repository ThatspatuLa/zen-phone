import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/kanban_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/skills_screen.dart';
import 'screens/memory_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/register_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'widgets/side_drawer.dart';

void main() {
  runApp(const ZenPhoneApp());
}

class ZenPhoneApp extends StatelessWidget {
  const ZenPhoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..load(),
      child: MaterialApp(
        title: 'Zen',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: const AppShell(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case 'home':
              return MaterialPageRoute(builder: (_) => const HomeScreen());
            case 'kanban':
              return MaterialPageRoute(builder: (_) => const KanbanScreen());
            case 'chat':
              final project = settings.arguments as String?;
              return MaterialPageRoute(
                builder: (_) => ChatScreen(initialProject: project),
              );
            case 'skills':
              return MaterialPageRoute(builder: (_) => const SkillsScreen());
            case 'memory':
              return MaterialPageRoute(builder: (_) => const MemoryScreen());
            case 'settings':
              return MaterialPageRoute(builder: (_) => const SettingsScreen());
            case 'register':
              return MaterialPageRoute(builder: (_) => const RegisterScreen());
          }
          return null;
        },
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String _currentRoute = 'home';

  void _navigate(String route) {
    setState(() => _currentRoute = route);
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(
        currentRoute: _currentRoute,
        onNavigate: _navigate,
      ),
      body: const _RouteController(),
    );
  }
}

class _RouteController extends StatefulWidget {
  const _RouteController();

  @override
  State<_RouteController> createState() => _RouteControllerState();
}

class _RouteControllerState extends State<_RouteController> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: GlobalKey<NavigatorState>(),
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/kanban':
            page = const KanbanScreen();
            break;
          case '/chat':
            final project = settings.arguments as String?;
            page = ChatScreen(initialProject: project);
            break;
          case '/skills':
            page = const SkillsScreen();
            break;
          case '/memory':
            page = const MemoryScreen();
            break;
          case '/settings':
            page = const SettingsScreen();
            break;
          case '/register':
            page = const RegisterScreen();
            break;
          case '/':
          default:
            page = const HomeScreen();
        }
        return MaterialPageRoute(builder: (_) => page, settings: settings);
      },
    );
  }
}
