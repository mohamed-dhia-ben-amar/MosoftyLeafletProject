import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class AddProject extends StatefulWidget {
  const AddProject({super.key});

  @override
  State<AddProject> createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  static Future<http.Response> _addProject(
      String nom, String description, String latitude, String longitude) async {
    Uri addProjectURI =
        Uri.parse("http://104.225.216.185:9405/projects/create");
    final data = {
      "nom": nom,
      "description": description,
      "latitude": latitude,
      "longitude": longitude
    };
    String params = jsonEncode(data);
    http.Response response =
        await http.post(addProjectURI, body: params, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
    return response;
  }

  final _formKey2 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var _nomCtrl = TextEditingController();
    var _descCtrl = TextEditingController();
    var _lattCtrl = TextEditingController();
    var _longCtrl = TextEditingController();

    return Scaffold(
      body: Form(
        key: _formKey2,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _nomCtrl,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              decoration: InputDecoration(hintText: "Project Name"),
            ),
            TextFormField(
              controller: _descCtrl,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
              decoration: InputDecoration(hintText: "Project Description"),
            ),
            TextFormField(
              readOnly: true,
              controller: _lattCtrl,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please pick a lattitide from the map';
                }
                return null;
              },
              decoration: InputDecoration(hintText: "Project lattitide"),
            ),
            TextFormField(
              readOnly: true,
              controller: _longCtrl,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please pick a longitude from the map';
                }
                return null;
              },
              decoration: InputDecoration(hintText: "Project longitude"),
            ),
            SizedBox(height: 80),

            /*
            the map
            */

            Container(
              width: double.maxFinite,
              height: 300,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(33.892166, 9.561555499999997),
                  initialZoom: 9.2,
                  onTap: (tapPos, latLng) {
                    print(latLng.latitude.toString());
                    print(latLng.longitude.toString());

                    _lattCtrl.text = latLng.latitude.toString();
                    _longCtrl.text = latLng.longitude.toString();
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () => launchUrl(
                            Uri.parse('https://openstreetmap.org/copyright')),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /*
            the map
            */

            Row(
              children: [
                Center(
                  child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey2.currentState!.validate()) {
                          final response = await _addProject(_nomCtrl.text,
                              _descCtrl.text, _lattCtrl.text, _longCtrl.text);
                          switch (response.statusCode) {
                            case 200:
                              {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text(
                                        'Project Added Successfully'),
                                    content: Text('Project : ' + _nomCtrl.text),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/ListProjects');
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
                      child: Text("Add Project")),
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
