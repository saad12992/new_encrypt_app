import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pointycastle/export.dart' as pointycastle;
import 'package:firebase_database/firebase_database.dart';

class AESEncryption extends StatefulWidget {
  const AESEncryption({super.key});

  @override
  State<AESEncryption> createState() => _AESEncryptionState();
}

Uint8List aesCbcEncrypt(Uint8List key, Uint8List iv, Uint8List paddedPlaintext) {
  assert([128, 192, 256].contains(key.length * 8));
  assert(128 == iv.length * 8);
  assert(128 == paddedPlaintext.length * 8);

  final cbc = pointycastle.CBCBlockCipher(pointycastle.AESEngine())
    ..init(true, pointycastle.ParametersWithIV(pointycastle.KeyParameter(key), iv));

  final cipherText = Uint8List(paddedPlaintext.length);

  var offset = 0;
  while (offset < paddedPlaintext.length) {
    offset += cbc.processBlock(paddedPlaintext, offset, cipherText, offset);
  }
  assert(offset == paddedPlaintext.length);

  return cipherText;
}

class _AESEncryptionState extends State<AESEncryption> {
  static const defaultAESKey = '0123456789ABCDEF';
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // Add TextEditingController for password
  Uint8List? _encryptedMessage;
  Duration? _encryptionTime;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AES Algorithm'),
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
              decoration: InputDecoration(
                  labelText: 'Enter Amount or secret message'),
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
                    _encryptMessage(defaultAESKey); // Pass the password
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
                    Navigator.of(context).pushNamed('/aes_decryption');
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

  void _encryptMessage(String aesKey) {
    try {
      final aesKeyBytes = Uint8List.fromList(aesKey.codeUnits);
      final iv = _generateIV();
      final messageBytes =
          Uint8List.fromList(utf8.encode(_messageController.text)); // Convert to Uint8List
      final paddedMessageBytes = _padPlaintext(messageBytes);

      // Check if the username exists in the database
      _checkUsernameExists(_usernameController.text).then((exists) {
        if (exists) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Text('Username already exists.'),
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
        } else {
          final startTime = DateTime.now();
          final encryptedMessageBytes =
              aesCbcEncrypt(aesKeyBytes, iv, paddedMessageBytes);
          final endTime = DateTime.now();

          setState(() {
            _encryptedMessage = encryptedMessageBytes;
            _encryptionTime = endTime.difference(startTime);
          });

          // Store the encrypted message, encryption time, AES key, and password in Realtime Database
          _storeEncryptedMessage(
            _usernameController.text,
            base64Encode(encryptedMessageBytes),
            _encryptionTime!.inMilliseconds.toString(),
            defaultAESKey, // Store the provided AES key
            _messageController.text, // Store the original message
            _passwordController.text, // Store the password
          );

          // Show success message with encrypted message and encryption time
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Success'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Encrypted Message: ${base64Encode(_encryptedMessage!)}'),
                  SizedBox(height: 8),
                  Text(
                    'Encryption Time: ${_encryptionTime!.inMilliseconds} ms',
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Encrypted message and encryption time stored successfully in the database.',
                  ),
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
        }
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(
              'Failed to encrypt message. Please try again. Error: $e'),
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

  Future<bool> _checkUsernameExists(String username) async {
    try {
      final snapshot = await _databaseReference
          .child('aes_algorithm')
          .child(username)
          .once();
      return snapshot.snapshot.exists;
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }

  Uint8List _generateIV() {
    return Uint8List.fromList(
        List.generate(16, (_) => Random.secure().nextInt(256)));
  }

  Uint8List _padPlaintext(Uint8List plaintext) {
    final padLength = 16 - (plaintext.length % 16);
    final paddedPlaintext = Uint8List(plaintext.length + padLength);
    paddedPlaintext.setAll(0, plaintext);
    paddedPlaintext.fillRange(plaintext.length, paddedPlaintext.length, padLength);
    return paddedPlaintext;
  }

  Future<void> _storeEncryptedMessage(
    String username,
    String encryptedMessageBase64,
    String encryptionTimeMillis,
    String aesKey,
    String originalMessage,
    String password, // Add password parameter
  ) async {
    try {
      final Map<String, dynamic> data = {
        'encryptedMessage': encryptedMessageBase64,
        'encryptionTime': encryptionTimeMillis,
        'aesKey': aesKey,
        'originalMessage': originalMessage,
        'password': password, // Store the password
      };

      await _databaseReference
          .child('aes_algorithm')
          .child(username)
          .set(data);
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
