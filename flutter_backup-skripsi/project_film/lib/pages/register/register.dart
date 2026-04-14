import 'dart:convert';

import 'package:eyz_movie/_baseUrl/baseUrl.dart';
import 'package:eyz_movie/pages/login/login.dart';
import 'package:eyz_movie/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  TextEditingController _email = TextEditingController();
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();

  void checkInput(BuildContext context) {
    var isFailed = false;
    final email = _email.text.trim();
    final username = _username.text.trim();
    final password = _password.text.trim();
    final confirmPassword = _confirmPassword.text.trim();

    if (email.isEmpty) {
      showInfoSnackBar(context, "Email tidak boleh kosong!");
      isFailed = true;
    }

    if (username.isEmpty) {
      showInfoSnackBar(context, "Username tidak boleh kosong!");
      isFailed = true;
    }

    if (password.isEmpty) {
      showInfoSnackBar(context, "Password tidak boleh kosong!");
      isFailed = true;
    }

    if (confirmPassword.isEmpty) {
      showInfoSnackBar(context, "Confirmation Password tidak boleh kosong!");
      isFailed = true;
    }

    if (password != confirmPassword) {
      showInfoSnackBar(context, "Password dan Confirmation Tidak Sama!");
      isFailed = true;
    }

    if (!isFailed) {
      // print('$email $password');
      _register(email, username, password);
    }
  }

  void _register(String email, String username, String password) async {
    var resp = await BaseClient().register("/user/register", email, username, password);
    var dataJson = jsonDecode(resp);
    if (dataJson['status_code'] == 'EYZ-01') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (router) => false,
        );
    };
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
                // SVG Background
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
                              "Register Member EYZ Movie",
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
                                controller: _email,
                                decoration: InputDecoration(
                                  hintText: "Email",
                                  filled: true,
                                  fillColor: isDark ? Color.fromRGBO(93, 93, 93, 1) : Color.fromARGB(255, 190, 190, 190),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide.none,
                                  )
                                ),
                              ),
                              SizedBox(height: 20), // jarak antar teks
                              TextField(
                                controller: _username,
                                decoration: InputDecoration(
                                  hintText: "Username",
                                  filled: true,
                                  fillColor: isDark ? Color.fromRGBO(93, 93, 93, 1) : Color.fromARGB(255, 190, 190, 190),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide.none,
                                  )
                                ),
                              ),
                              SizedBox(height: 20), // jarak antar teks
                              TextField(
                                controller: _password,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: "Password",
                                  filled: true,
                                  fillColor: isDark ? Color.fromRGBO(93, 93, 93, 1) : Color.fromARGB(255, 190, 190, 190),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide.none,
                                  )
                                ),
                              ),
                              SizedBox(height: 20), // jarak antar teks
                              TextField(
                                controller: _confirmPassword,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: "Confirm Password",
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
                              child: Text('Sign In'),
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

