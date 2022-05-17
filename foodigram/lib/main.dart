import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foodigram/app_initializer.dart';
import 'package:provider/provider.dart';
import 'data_center.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    name: 'foodigram-ed3ee',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => DataCenter())],
      child: const AppInitializer(),
    );
  }
}
