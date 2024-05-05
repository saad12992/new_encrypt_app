import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart' as pointycastle;
import 'package:firebase_database/firebase_database.dart';

class HMACEncryption extends StatefulWidget {
  const HMACEncryption({super.key});

  @override
  State<HMACEncryption> createState() => _HMACEncryptionState();
}

class _HMACEncryptionState extends State<HMACEncryption> {
  static const defaultHMACKey = '0123456789ABCDEF';
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Uint8List? _hmac;
  Duration? _encryptionTime;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HMAC SHA-256 Algorithm'),
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
              controller: _passwordController,
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
                  onPressed: () {
                    _calculateHMAC(defaultHMACKey);
                  },
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
                    Navigator.of(context).pushNamed('/hmac_decryption');
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

  void _calculateHMAC(String hmacKey) async {
    try {
      final username = _usernameController.text;
      final password = _passwordController.text;
      final key = Uint8List.fromList(utf8.encode(hmacKey));
      final message = Uint8List.fromList(utf8.encode(_messageController.text));

      // Check if username already exists
      final usernameExists = await _checkUsernameExists(username);
      if (usernameExists) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Username Exists'),
            content: Text('The username already exists in the database.'),
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
        return;
      }

      final startTime = DateTime.now();
      final hmacValue = hmacSha256(key, message);
      final endTime = DateTime.now();

      final encryptionTime = endTime.difference(startTime);

      setState(() {
        _hmac = hmacValue;
        _encryptionTime = encryptionTime;
      });

      _storeEncryptedMessage(
        username,
        password,
        base64Encode(hmacValue),
        encryptionTime.inMilliseconds.toString(),
        hmacKey,
        _messageController.text, // Pass the message to be stored
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to calculate HMAC. Please try again. Error: $e'),
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

  Uint8List hmacSha256(Uint8List hmacKey, Uint8List data) {
    final hmac = pointycastle.HMac(pointycastle.SHA256Digest(), 64)
      ..init(pointycastle.KeyParameter(hmacKey));

    return hmac.process(data);
  }

  Future<bool> _checkUsernameExists(String username) async {
    try {
      final snapshot = await _databaseReference.child('hmac_algorithm').child(username).once();
      return snapshot.snapshot.exists;
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }

  Future<void> _storeEncryptedMessage(
    String username,
    String password,
    String hmacBase64,
    String encryptionTimeMillis,
    String hmacKey,
    String message, // Add message parameter
  ) async {
    try {
      final Map<String, dynamic> data = {
        'hmac': hmacBase64,
        'encryptionTime': encryptionTimeMillis,
        'hmacKey': hmacKey,
        'password': password,
        'message': message, // Add message to the data
      };

      await _databaseReference.child('hmac_algorithm').child(username).set(data);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Encrypted message: $hmacBase64'),
              SizedBox(height: 8),
              Text('Encryption Time: $encryptionTimeMillis ms'),
              SizedBox(height: 8),
              Text('Password: $password'),
              SizedBox(height: 8),
              Text('Message: $message'), // Display the message
              SizedBox(height: 8),
              Text('Encrypted message, encryption time, password, and message stored successfully in the database.'),
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