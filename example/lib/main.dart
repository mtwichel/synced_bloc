import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synced_bloc/synced_bloc.dart';
import 'package:synced_bloc_example/counter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SyncedBloc.storage = await LocalStorage.build(
    storageDirectory:
        kIsWeb
            ? LocalStorageDirectory.web
            : LocalStorageDirectory((await getTemporaryDirectory()).path),
  );
  SyncedBloc.serverHost = 'localhost:8080';
  LiveBloc.serverHost = '192.168.1.100:8080';
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: const MainAppView(),
    );
  }
}

class MainAppView extends StatelessWidget {
  const MainAppView({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.select((CounterBloc bloc) => bloc.state);
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              Text('Counter'),
              Text(count.toString()),
              ElevatedButton(
                onPressed: () => context.read<CounterBloc>().add(Increment()),
                child: const Text('Increment'),
              ),
              ElevatedButton(
                onPressed: () => context.read<CounterBloc>().add(Decrement()),
                child: const Text('Decrement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
