import 'package:go_router/go_router.dart';

import '../features/trips/presentation/pages/trip_list_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/trips',
  routes: <GoRoute>[
    GoRoute(path: '/trips', builder: (context, state) => const TripListPage()),
  ],
);
