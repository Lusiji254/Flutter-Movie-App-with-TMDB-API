import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:movie_db/services/login_preference.dart';
import 'package:movie_db/ui/home_page.dart';
import 'package:movie_db/ui/login.dart';
import 'package:movie_db/ui/signup.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase/options.dart';
import 'models/movie_hive_model.dart';
import 'ui/popular_movies.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseOptions options = DefaultFirebaseOptions.getDefaultOptions();
  await Firebase.initializeApp(options: options);
  await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
  );// await Firebase.initializeApp();
  runApp(SignInCheck());
}
class SignInCheck extends StatefulWidget {
  SignInCheck({Key? key}) : super(key: key);
  @override
  _SignInCheckState createState() => _SignInCheckState();
}

class _SignInCheckState extends State<SignInCheck> {
  var islogin;

  checkUserLoginState() async {
    await Shared.getUserSharedPreferences().then((value) {
      setState(() {
        islogin = value;
      });
    });
  }

  @override
  void initState() {
    checkUserLoginState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('>>>>>>>>>>>>>>>>>>>>>>>>>>status$islogin');
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: islogin != null ? islogin ? HomePage() : Login() : Signup(),
    );
  }
}
