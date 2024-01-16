import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ListPhones extends StatefulWidget {
  const ListPhones({Key? key}) : super(key: key);

  @override
  State<ListPhones> createState() => _ListPhonesState();
}

class _ListPhonesState extends State<ListPhones> {
  List<Phone>? _phones;

  Future<List<Phone>> _getPhones() async {
    final response =
        await http.get(Uri.parse('http://104.225.216.185:9405/mobiles'));

    if (response.statusCode == 200) {
      List<dynamic> phonesJson = jsonDecode(response.body);
      return phonesJson.map((phone) => Phone.fromJson(phone)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<http.Response> _deletePhone(String id) async {
    Uri deletePhoneURI = Uri.parse("http://104.225.216.185:9405/mobiles/$id");
    http.Response response = await http.delete(deletePhoneURI);
    return response;
  }

  @override
  void initState() {
    super.initState();
    _getPhones().then((phones) {
      setState(() {
        _phones = phones;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            child: _phones != null
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: _phones!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        child: ListTile(
                          title: Text(_phones![index].nom),
                          subtitle: Text(_phones![index].num),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/editPhone',
                                        arguments:
                                            _phones![index].idtel.toString());
                                  },
                                  icon: const Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () async {
                                    final response = await _deletePhone(
                                        _phones![index].idtel.toString());
                                    Navigator.pushNamed(context, '/ListPhones');
                                  },
                                  icon: const Icon(Icons.delete)),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Center(child: CircularProgressIndicator()),
          ),
          ElevatedButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/addPhone');
            },
            child: const Text('Add Phone'),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/assignPhone');
            },
            child: const Text('Assign Phone'),
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/ListProjects');
            },
            child: const Text('List Projects'),
          ),
        ],
      ),
    );
  }
}

class Phone {
  final int idtel;
  final String num;
  final String nom;

  Phone({
    required this.nom,
    required this.num,
    required this.idtel,
  });

  factory Phone.fromJson(Map<String, dynamic> json) {
    return Phone(idtel: json['idtel'], num: json['num'], nom: json['nom']);
  }
}
