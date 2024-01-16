import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AssignPhoneToUser extends StatefulWidget {
  const AssignPhoneToUser({super.key});

  @override
  State<AssignPhoneToUser> createState() => _AssignPhoneToUserState();
}

class _AssignPhoneToUserState extends State<AssignPhoneToUser> {
  List<Phone>? _phones;
  List<String>? _phoneNumbers;
  List<User>? _users;
  List<String>? _userNames;
  String? selectedUserName;
  String? selectedPhoneName;
  TextEditingController phoneNumberCtrl = TextEditingController();

  static Future<http.Response> _assignPhone(
      String idTel, String idEmployee) async {
    print("idTel : ");
    print(idTel);
    print("idEmployee : ");
    print(idEmployee);
    Uri addPhoneURI =
        Uri.parse("http://104.225.216.185:9405/mobiles/$idTel/$idEmployee");
    http.Response response =
        await http.put(addPhoneURI, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    return response;
  }

  Future<List<Phone>> _getPhones() async {
    final response =
        await http.get(Uri.parse('http://104.225.216.185:9405/mobiles'));

    if (response.statusCode == 200) {
      List<dynamic> phonesJson = jsonDecode(response.body);
      return phonesJson.map((phone) => Phone.fromJson(phone)).toList();
    } else {
      throw Exception('Failed to load phiones');
    }
  }

  Future<List<User>> _getUsers() async {
    final response =
        await http.get(Uri.parse('http://104.225.216.185:9405/persons'));

    if (response.statusCode == 200) {
      List<dynamic> usersJson = jsonDecode(response.body);
      return usersJson.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  String getPhoneNumberFromPhoneName(String PhoneName) {
    for (var element in _phones!) {
      if (element.nom == PhoneName) {
        return element.num;
      }
    }
    return "";
  }

  String GetPhoneIDFromPhoneName(String PhoneName) {
    print("PhoneName : ");
    print(PhoneName);
    for (var element in _phones!) {
      if (element.nom == PhoneName) {
        print(true);
        return element.idtel.toString();
      }
    }
    return "";
  }

  String GetUserIDFromUserName(String UserName) {
    print("UserName : ");
    print(UserName);
    for (var element in _users!) {
      if (element.nom == UserName) {
        print(true);
        return element.idperson.toString();
      }
    }
    return "";
  }

  @override
  void initState() {
    super.initState();
    _phones = [];
    _phoneNumbers = [];
    _users = [];
    _userNames = [];

    _getPhones().then((phones) {
      setState(() {
        _phones = phones;
        for (var element in phones) {
          _phoneNumbers?.add(element.nom);
        }
      });
    });

    _getUsers().then((users) {
      setState(() {
        _users = users;
        for (var element in users) {
          _userNames?.add(element.nom);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
          child: Column(
        children: <Widget>[
          Text("Phone name: "),
          DropdownButton(
            value: selectedPhoneName,
            items: _phoneNumbers?.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                selectedPhoneName = value!;
                /*phoneNumberCtrl.value =
                    getPhoneNumberFromPhoneName(value!) as TextEditingValue;*/
              });
            },
          ),
          /*
          TextFormField(
            readOnly: true,
            controller: phoneNumberCtrl,
          ),
          */
          Text("Employee: "),
          DropdownButton(
            value: selectedUserName,
            items: _userNames?.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                selectedUserName = value!;
              });
            },
          ),
          ElevatedButton(
              onPressed: () async {
                final response = await _assignPhone(
                    GetPhoneIDFromPhoneName(selectedPhoneName!),
                    GetUserIDFromUserName(selectedUserName!.toString()));
                switch (response.statusCode) {
                  case 200:
                    {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Phone Assigned Successfully'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/ListPhones');
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
              },
              child: Text("Assign Phone")),
        ],
      )),
    );
  }
}

class Phone {
  final int idtel;
  final String num;
  final String nom;

  Phone(this.idtel, this.nom, this.num);

  factory Phone.fromJson(Map<String, dynamic> json) {
    return Phone(json['idtel'], json['nom'], json['num']);
  }
}

class User {
  final int idperson;
  final String nom;
  final String prenom;
  final String mail;
  final String password;
  final String username;

  User(this.idperson, this.nom, this.prenom, this.mail, this.password,
      this.username);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['idperson'],
      json['nom'],
      json['prenom'],
      json['mail'],
      json['password'],
      json['username'],
    );
  }
}
