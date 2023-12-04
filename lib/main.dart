import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:movie_db/services/login_preference.dart';
import 'package:movie_db/ui/navigation.dart';
import 'package:movie_db/ui/login.dart';
import 'package:movie_db/ui/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase/options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final FirebaseOptions options = DefaultFirebaseOptions.getDefaultOptions();
  await Firebase.initializeApp(options: options);
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  ); // await Firebase.initializeApp();
  runApp(SignInCheck());
}

class SignInCheck extends StatefulWidget {
  SignInCheck({Key? key}) : super(key: key);

  @override
  _SignInCheckState createState() => _SignInCheckState();
}

class _SignInCheckState extends State<SignInCheck> {
  late bool? islogin;

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
    debugPrint('>>>>>status$islogin');
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: islogin != null
          ? islogin!
              ? HomePage()
              : Login()
          : Signup(),
    );
  }
}
