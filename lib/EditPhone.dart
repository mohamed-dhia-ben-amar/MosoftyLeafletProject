import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditPhone extends StatefulWidget {
  const EditPhone({Key? key}) : super(key: key);

  @override
  State<EditPhone> createState() => _EditPhoneState();
}

class _EditPhoneState extends State<EditPhone> {
  Phone? _phone;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameCtrl = TextEditingController();
  TextEditingController _numberCtrl = TextEditingController();

  static Future<http.Response> _editPhone(
      String id, String name, String number) async {
    Uri editPhoneURI =
        Uri.parse("http://104.225.216.185:9405/mobiles/upmobile/$id");
    final data = {"nom": name, "num": number};
    String params = jsonEncode(data);
    http.Response response =
        await http.put(editPhoneURI, body: params, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    return response;
  }

  static Future<Phone> getPhoneByID(String id) async {
    Uri getPhoneByIDURI =
        Uri.parse("http://104.225.216.185:9405/mobiles/phone/$id");
    http.Response response = await http.get(getPhoneByIDURI);
    var decoded = json.decode(response.body);
    Phone phone =
        Phone(decoded[0]['nom'], decoded[0]['num'], decoded[0]['idtel']);
    return phone;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String? phoneId =
        ModalRoute.of(context)!.settings.arguments as String?;

    Future.delayed(Duration.zero, () {
      getPhoneByID(phoneId.toString()).then((phone) {
        setState(() {
          _phone = phone;
          _nameCtrl.text = _phone!.nom;
          _numberCtrl.text = _phone!.num;
        });
      });
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final response = await _editPhone(
                          ModalRoute.of(context)!.settings.arguments as String,
                          _nameCtrl.text,
                          _numberCtrl.text);
                      Map<String, dynamic> body = jsonDecode(response.body);
                      switch (response.statusCode) {
                        case 200:
                          {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Phone Added Successfully'),
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
                                      Navigator.pushNamed(context, '/');
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
                  child: Text("Edit Phone"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/');
                  },
                  child: Text("Back to home"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Phone {
  final String idtel;
  final String num;
  final String nom;

  Phone(this.nom, this.num, this.idtel);
}
