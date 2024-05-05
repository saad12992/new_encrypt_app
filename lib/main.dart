import 'package:encryption_analysis/decryption_screens/aes_decryption.dart';
import 'package:encryption_analysis/decryption_screens/digest_sha256_decryption.dart';
import 'package:flutter/material.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import './screens/home.dart';
import './screens/aes_algorithm.dart';
import './screens/rsa_algorithm.dart';
import './screens/hmac_algorithm.dart';
import './screens/digest_sha256_algorithm.dart';
import './decryption_screens/hmac_decryption.dart';
import './decryption_screens/rsa_decryption.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// void main() => runApp(MyApp());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Comparative Encryption Analysis",
      // routes: [],
      home: EasySplashScreen(
        loadingTextPadding: EdgeInsets.all(10),
        logo: Image.asset("assets/images/encryption_logo.png"), logoWidth: 130,
        title: Text("Comparative Analysis of \nEncryption Algorithms", style: TextStyle(color: Colors.white, fontSize: 24,), textAlign: TextAlign.center,),
        backgroundColor: Color.fromARGB(255, 13,13,13,),
        durationInSeconds: 5,
        showLoader: false,
        loadingText: Text("Name: Saad Bin Tariq\nStudent ID: 2356185\nSupervisor: Rasha Hafidh\n\n", style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
        navigator: Home(),
         ),

      initialRoute: '/',
      routes: {
        '/home': (context)=> Home(),
        '/rsa_algorithm': (context)=> RSAEncryption(),
        '/aes_algorithm': (context)=> AESEncryption(),
        '/hmac_algorithm': (context)=> HMACEncryption(),
        '/digest_sha256_algorithm': (context)=> DigestSHA256(),
        '/hmac_decryption': (context)=> HMACDecryption(),
        '/rsa_decryption': (context)=> RSADecryption(),
        '/aes_decryption': (context)=> AESDecryption(),
        '/digest_sha256_decryption': (context)=> DigestSHA256Decryption()
        // '/login': (context)=> Login(),
        // '/users': (content)=> Users(),

      },
    );
  }
}
