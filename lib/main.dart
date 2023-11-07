import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_db/home_page.dart';
import 'package:movie_db/login.dart';
import 'package:movie_db/signup.dart';
import 'package:movie_db/ui/favorite_movies.dart';
import 'package:movie_db/models/toprated_model.dart';
import 'package:movie_db/ui/top_rated.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';


import 'firebase/options.dart';
import 'models/movie_hive_model.dart';
import 'ui/popular_movies.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseOptions options = DefaultFirebaseOptions.getDefaultOptions();
  await Firebase.initializeApp(options: options);
  await Hive.initFlutter();
  Hive.registerAdapter(MovieHiveModelAdapter());
  await Hive.openBox<MovieHiveModel>('Movies');

  // await Firebase.initializeApp();


  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // initialRoute: 'signup',
      // routes: {
      //   //'welcome_screen': (context) => WelcomeScreen(),
      //   'signup': (context) => Signup(),
      //   'login': (context) => Login(),
      //   'home_page': (context) => HomePage()
      // },
      home: Signup(),

    );
  }
}
