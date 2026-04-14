import 'dart:convert';
import 'dart:io';

import 'package:eyz_movie/_baseUrl/baseUrl.dart';
import 'package:eyz_movie/models/listViewModel.dart';
import 'package:eyz_movie/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  List<Map<String, dynamic>> videos = [];

  @override
  void initState() {
    super.initState();
    loadVideos().then((data) {
      setState(() {
        videos = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, ThemeProvider notifier, child) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 25),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(
                          context,
                        );
                      },
                      icon: Icon(Icons.arrow_back),
                      label: Text('Back'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        'Download',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 25,
                          crossAxisSpacing: 25,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: videos.length, 
                        itemBuilder: (context, index) {
                          final item = videos[index];
                      
                          return GridTile(
                            child: Image.asset(
                              item['path'],
                              fit: BoxFit.cover,
                              width: 50,
                              height: 75,
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

Future<List<Map<String, dynamic>>> loadVideos() async {
  final dir = await getApplicationDocumentsDirectory();
  final metadataFile = File("${dir.path}/download.json");

  if (await metadataFile.exists()) {
    final content = await metadataFile.readAsString();
    return List<Map<String, dynamic>>.from(jsonDecode(content));
  }
  return [];
}