import 'package:go_router/go_router.dart';

import '../../features/discovery/ui/discovery_screen.dart';
import '../../features/settings/ui/ai_settings_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DiscoveryScreen(),
    ),
    GoRoute(
      path: '/settings/ai',
      builder: (context, state) => const AiSettingsScreen(),
    ),
  ],
);