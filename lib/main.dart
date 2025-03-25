import 'package:clip_vibe/firebase_options.dart';
import 'package:clip_vibe/provider/gender_model.dart';
import 'package:clip_vibe/provider/loading_model.dart';
import 'package:clip_vibe/provider/login_phone.dart';
import 'package:clip_vibe/provider/save_model.dart';
import 'package:clip_vibe/views/pages/auth/auth_screen.dart';
import 'package:clip_vibe/views/pages/auth/login_phone_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => LoginPhoneProvider(),
            child: LoginWithPhoneNumber(),
          ),
          ChangeNotifierProvider(
            create: (context) => LoadingModel(),
          ),
          ChangeNotifierProvider(
            create: (context) => SaveModel(),
          ),
          ChangeNotifierProvider(
            create: (context) => GenderModel(),
          ),
        ],
        child: MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.varelaRoundTextTheme().copyWith(
            bodySmall: const TextStyle(fontFamily: "Tiktok_Sans"),
            bodyMedium: const TextStyle(fontFamily: "Tiktok_Sans"),
            bodyLarge: const TextStyle(fontFamily: "Tiktok_Sans")
        ),
      ),
      home: AuthScreen(),
    );
  }

}