import 'package:go_router/go_router.dart';

import '../features/trips/presentation/pages/trip_list_page.dart';
import '../features/trips/presentation/pages/add_edit_trip_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/trips',
  routes: <GoRoute>[
    GoRoute(
      path: '/trips',
      builder: (context, state) => const TripListPage(),
    ),
    GoRoute(
      path: '/trips/new',
      builder: (context, state) => const AddEditTripPage(),
    ),
  ],
);

