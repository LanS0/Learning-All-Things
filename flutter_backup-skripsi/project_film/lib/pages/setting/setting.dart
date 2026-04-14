import 'dart:convert';
import 'dart:io';

import 'package:eyz_movie/_baseUrl/baseUrl.dart';
import 'package:eyz_movie/pages/changeNickname/changeNickname.dart';
import 'package:eyz_movie/pages/changePassword/changePassword.dart';
import 'package:eyz_movie/pages/download/download.dart';
import 'package:eyz_movie/pages/login/login.dart';
import 'package:eyz_movie/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late SharedPreferences storage;

  @override
  void initState() {
    initStorage();
    super.initState();
  }

  Future<void> initStorage() async {
    storage = await SharedPreferences.getInstance();
  }

  void DeleteAll() async {
    final dir = await getApplicationDocumentsDirectory();
    // Simpan metadata ke file JSON
    final metadataFileFavorite = File("${dir.path}/favorite.json");
    final metadataFileDownload = File("${dir.path}/download.json");
    final metadataFileLike = File("${dir.path}/like.json");
    
    if (await metadataFileLike.exists()) {
      metadataFileLike.delete();
    };

    if (await metadataFileFavorite.exists()) {
      metadataFileFavorite.delete();
    };

    if (await metadataFileDownload.exists()) {
      metadataFileDownload.delete();
    };
  }

  @override
  Widget build(BuildContext context) {
  final isDark = Provider.of<ThemeProvider>(context).isDark;
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Consumer<ThemeProvider>(
        builder: (context, ThemeProvider notifier, child) {
          return SingleChildScrollView(
            child: Center(
              heightFactor: 2,
              child: Column(
                children: [
                  SizedBox(
                    width: 250.0, // Fixed width
                    height: 50.0, // Fixed height
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DownloadPage(),
                          ),
                        );
                      },
                      child: Text("Download"),
                    ),
                  ),
                  SizedBox(height: 12,),
                  SizedBox(
                    width: 250.0, // Fixed width
                    height: 50.0, // Fixed height
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => null,
                        //   ),
                        // );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNickPage(),
                          ),
                        );
                      },
                      child: Text("Change Username"),
                    ),
                  ),
                  SizedBox(height: 12,),
                  SizedBox(
                    width: 250.0, // Fixed width
                    height: 50.0, // Fixed height
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangePasswordPage(),
                          ),
                        );
                      },
                      child: Text("Change Password"),
                    ),
                  ),
                  SizedBox(height: 12,),
                  SizedBox(
                    width: 250.0, // Fixed width
                    height: 50.0, // Fixed height
                    child: ElevatedButton(
                      onPressed: () {
                        storage.clear();
                        DeleteAll();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      child: Text("Log Out"),
                    ),
                  ),
                ],
              ),
            )
          );
        }
      ),
    );
  }
}