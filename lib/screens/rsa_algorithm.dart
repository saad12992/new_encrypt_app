import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pointycastle/export.dart' as pointycastle;
import 'package:firebase_database/firebase_database.dart';

class RSAEncryption extends StatefulWidget {
  const RSAEncryption({super.key});

  @override
  State<RSAEncryption> createState() => _RSAEncryptionState();
}

class _RSAEncryptionState extends State<RSAEncryption> {
  final String defaultModulus =
      '11819046281425913506441900651897154771439135784809722510790959065924166307388429948284463211669108290102944147083604469393273659859426976029735184011174249';

  TextEditingController _messageController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController(); // Add password controller
  Uint8List? _encryptedMessage;
  Duration? _encryptionTime;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RSA Algorithm'),
        backgroundColor: Color.fromARGB(255, 13, 13, 13),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Enter Username'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController, // Add TextField for password
              decoration: InputDecoration(labelText: 'Enter Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: 'Enter Amount or secret message'),
            ),
            SizedBox(height: 16),
             SizedBox(
              width: 400,
              height: 100,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 13, 13, 13)),
                  ),
              onPressed: _encryptMessage,
              child: Text('Encrypt Data', style: TextStyle(fontSize: 18)),
                ),
              ),
             ),
            SizedBox(height: 16),
            SizedBox(
              width: 400,
              height: 100,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 13, 13, 13)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/rsa_decryption');
                  },
                  child: Text('Decrypt Data', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _encryptMessage() {
    try {
      final publicKey = pointycastle.RSAPublicKey(
        BigInt.parse(defaultModulus),
        BigInt.parse('65537'),
      );

      final startTime = DateTime.now();
      final encryptor = pointycastle.OAEPEncoding(pointycastle.RSAEngine())
        ..init(
          true,
          pointycastle.PublicKeyParameter<pointycastle.RSAPublicKey>(
            publicKey,
          ),
        );

      final messageToEncrypt = utf8.encode(_messageController.text);
      final encryptedMessage = encryptor.process(Uint8List.fromList(messageToEncrypt));
      final endTime = DateTime.now();

      setState(() {
        _encryptedMessage = encryptedMessage;
        _encryptionTime = endTime.difference(startTime);
      });

      _storeEncryptedMessage(
        _usernameController.text,
        _passwordController.text, // Pass the password to store
        base64Encode(encryptedMessage),
        _encryptionTime!.inMilliseconds.toString(),
        defaultModulus, // Store the default modulus used for encryption
        _messageController.text, // Store the original message
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(
              'Failed to parse RSA modulus. Please enter a valid RSA modulus.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _storeEncryptedMessage(
    String username,
    String password,
    String encryptedMessageBase64,
    String encryptionTimeMillis,
    String modulus,
    String originalMessage, // Add the original message parameter
  ) async {
    try {
      final Map<String, dynamic> data = {
        'encryptedMessage': encryptedMessageBase64,
        'encryptionTime': encryptionTimeMillis,
        'modulus': modulus,
        'originalMessage': originalMessage, // Store the original message
        'password': password, // Store the password
      };

      await _databaseReference
          .child('rsa_algorithm')
          .child(username)
          .set(data);

      // Show success message with encrypted message, encryption time, and original message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Encrypted Message: ${base64Encode(_encryptedMessage!)}'),
              SizedBox(height: 8),
              Text(
                  'Encryption Time: ${_encryptionTime!.inMilliseconds} ms'),
              SizedBox(height: 8),
              // Text('Original Message: $originalMessage'),
              // SizedBox(height: 8),
              // Text('Password: $password'), // Display the password
              SizedBox(height: 8),
              Text(
                  'Encrypted message, encryption time, original message, and password stored successfully in the database.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to store encrypted message. Error: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
