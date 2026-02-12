import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<String> tripPlaceholderProvider = Provider<String>(
  (ref) => 'واجهة مؤقتة — سنبني الرحلات لاحقًا',
);

class TripListPage extends ConsumerWidget {
  const TripListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String message = ref.watch(tripPlaceholderProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الرحلات')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message),
            const SizedBox(height: 8),
            const Text('Temporary UI — we will build trips later'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
