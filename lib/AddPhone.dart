import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddPhone extends StatefulWidget {
  const AddPhone({super.key});

  @override
  State<AddPhone> createState() => _AddPhoneState();
}

class _AddPhoneState extends State<AddPhone> {
  static Future<http.Response> _addPhone(String name, String number) async {
    Uri addPhoneURI = Uri.parse("http://104.225.216.185:9405/mobiles/create");
    final data = {"nom": name, "num": number};
    String params = jsonEncode(data);
    http.Response response =
        await http.post(addPhoneURI, body: params, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    return response;
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    TextEditingController _nameCtrl = TextEditingController();
    TextEditingController _numberCtrl = TextEditingController();

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _nameCtrl,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              decoration: InputDecoration(hintText: "Phone Name"),
            ),
            TextFormField(
              controller: _numberCtrl,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a number';
                }
                return null;
              },
              decoration: InputDecoration(hintText: "Phone Number"),
            ),
            SizedBox(height: 80),
            Row(
              children: [
                Center(
                  child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final response =
                              await _addPhone(_nameCtrl.text, _numberCtrl.text);
                          Map<String, dynamic> body = jsonDecode(response.body);
                          switch (response.statusCode) {
                            case 200:
                              {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title:
                                        const Text('Phone Added Successfully'),
                                    content: Text('Phone : ' + _nameCtrl.text),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, '/');
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              break;
                            default:
                              {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Error'),
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
                              break;
                          }
                        }
                      },
                      child: Text("Add Phone")),
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/');
                    },
                    child: Text("Back to home"))
              ],
            )
          ],
        ),
      ),
    );
  }
}
