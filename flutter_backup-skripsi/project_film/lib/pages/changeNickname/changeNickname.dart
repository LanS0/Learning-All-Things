import 'dart:convert';

import 'package:eyz_movie/_baseUrl/baseUrl.dart';
import 'package:eyz_movie/pages/login/login.dart';
import 'package:eyz_movie/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeNickPage extends StatefulWidget {
  const ChangeNickPage({super.key});

  @override
  State<ChangeNickPage> createState() => _ChangeNickPageState();
}

class _ChangeNickPageState extends State<ChangeNickPage> {
  late SharedPreferences storage;
  
  TextEditingController _newNick = TextEditingController();

  @override
  void initState() {
    initStorage();
    super.initState();
  }


  Future<void> initStorage() async {
    storage = await SharedPreferences.getInstance();
  }

  void checkInput(BuildContext context) {
    var isFailed = false;
    final newNick = _newNick.text.trim();

    if (newNick.isEmpty) {
      showInfoSnackBar(context, "Password Lama tidak boleh kosong!");
      isFailed = true;
    }


    if (!isFailed) {
      // print('$oldPassword $password');
      _changeNick(newNick);
    }
  }

  void _changeNick(String nick) async {
    var resp = await BaseClient().changeNick("/user/changeName", nick);
    var dataJson = jsonDecode(resp);
    if (dataJson['status_code'] == 'EYZ-01') {
      showDialog(
        context: context,
        barrierDismissible: false, // klik di luar modal tidak menutup
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("Ingin Logout?"),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup modal
                  Navigator.pop(context); // Tutup modal
                },
                child: Text("Tidak"),
              ),
              ElevatedButton(
                onPressed: () {
                  storage.clear();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: Text("Iya"),
              ),
            ],
          );
        },
      );
    } else if (dataJson['status_code'] == 'EYZ-02') {
      showInfoSnackBar(context, dataJson['message'] ?? " ~ ");
    } else {
      showInfoSnackBar(context, dataJson['message'] ?? " ~ ");
    }
  }

  void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // Bisa ganti jadi Colors.green/red
        behavior: SnackBarBehavior.floating, // Agar tidak nempel di bawah
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16), // Jarak dari tepi layar
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Consumer<ThemeProvider>(
        builder: (context, ThemeProvider notifier, child) {
          return SingleChildScrollView(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    icon: Icon(Icons.arrow_back),
                    label: Text('Back'),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(36),
                  padding: EdgeInsets.only(top: 36),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    verticalDirection: VerticalDirection.down,
                    children: [
                        Column(
                          children: [
                            Text(
                              "Change Password",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ]
                        ),
                        SizedBox(height: 25), // jarak antar teks
                        Container(
                          margin: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              TextField(
                                controller: _newNick,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: "Old Password",
                                  filled: true,
                                  fillColor: isDark ? Color.fromRGBO(93, 93, 93, 1) : Color.fromARGB(255, 190, 190, 190),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide.none,
                                  )
                                ),
                              ),
                            ]
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          margin: EdgeInsets.only(left: 20, right: 20,),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, // warna latar
                                backgroundColor: Color.fromRGBO(0, 13, 231, 1), // warna teks
                                textStyle: TextStyle(fontSize: 18),
                              ),
                              onPressed: () {
                                checkInput(context);
                              },
                              child: Text('Change'),
                            ),
                          ),
                        ),
                        SizedBox(height: 25), // jarak antar teks
                      ],
                  ),
                ),
              ]
            ),
          );
        }
      ),
    );
  }

  Future openDialog(String title, String message) => showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
    )
  );
}