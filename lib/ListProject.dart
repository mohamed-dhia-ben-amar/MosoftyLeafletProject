import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class ListProjects extends StatefulWidget {
  const ListProjects({super.key});

  @override
  State<ListProjects> createState() => _ListProjectsState();
}

class _ListProjectsState extends State<ListProjects> {
  List<Project>? _projects;

  void ShowProjectOnLeaflet(String longitude, String latitude) {
    final double lat = double.parse(latitude);
    final double lng = double.parse(longitude);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Project Location'),
          content: Container(
              width: double.maxFinite,
              height: 300,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(lat, lng),
                  initialZoom: 9.2,
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
                  MarkerLayer(markers: [
                    Marker(
                        point: latLng.LatLng(lat, lng),
                        child: Icon(Icons.location_pin))
                  ])
                ],
              )),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<Project>> _getProjects() async {
    final response =
        await http.get(Uri.parse('http://104.225.216.185:9405/projects'));

    if (response.statusCode == 200) {
      List<dynamic> projectsJson = jsonDecode(response.body);
      return projectsJson.map((phone) => Project.fromJson(phone)).toList();
    } else {
      throw Exception('Failed to load projects');
    }
  }

  @override
  void initState() {
    super.initState();
    _getProjects().then((projects) {
      setState(() {
        _projects = projects;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            child: _projects != null
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: _projects!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        child: ListTile(
                          title: Text(_projects![index].nom),
                          subtitle: Text(_projects![index].date),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    ShowProjectOnLeaflet(
                                        _projects![index].longitude,
                                        _projects![index].latitude);
                                  },
                                  icon: const Icon(Icons.map_sharp)),
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
              Navigator.pushNamed(context, '/addProject');
            },
            child: const Text('Add Project'),
          ),
        ],
      ),
    );
  }
}

class Project {
  final int idpro;
  final String nom;
  final String description;
  final String date;
  final String latitude;
  final String longitude;

  Project(
      {required this.idpro,
      required this.nom,
      required this.description,
      required this.date,
      required this.latitude,
      required this.longitude});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
        idpro: json['idpro'],
        nom: json['nom'],
        description: json['description'],
        date: json['date'],
        latitude: json['latitude'],
        longitude: json['longitude']);
  }
}
