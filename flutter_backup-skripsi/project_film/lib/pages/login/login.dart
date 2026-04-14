import 'dart:convert';

import 'package:eyz_movie/_baseUrl/baseUrl.dart';
import 'package:eyz_movie/pages/home/home.dart';
import 'package:eyz_movie/pages/mainPage.dart';
import 'package:eyz_movie/pages/register/register.dart';
import 'package:eyz_movie/services/google_service.dart';
import 'package:eyz_movie/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late SharedPreferences storage;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void checkInput(BuildContext context) {
    var isFailed = false;
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      showInfoSnackBar(context, "Email tidak boleh kosong!");
      isFailed = true;
    }

    if (password.isEmpty) {
      showInfoSnackBar(context, "Password tidak boleh kosong!");
      isFailed = true;
    }

    if (!isFailed) {
      _login(email, password);
    }
  }

  void _login(String email, String password) async {
    var resp = await BaseClient().login("/user/login", email, password);
    var dataJson = jsonDecode(resp);
    if (dataJson['status_code'] == 'EYZ-01') {
      storage.setString("user", jsonEncode(dataJson['data']));
      storage.setString("token", dataJson['token'] ?? '');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(),
        ),
        (router) => false,
      );
    } else if (dataJson['status_code'] == 'EYZ-02') {
      showInfoSnackBar(context, dataJson['message']);
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

  Future<void> initStorage() async {
    storage = await SharedPreferences.getInstance();
    final token = storage.getString('token') ?? '';
    if (token.toString().isNotEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(),
        ),
        (router) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initStorage();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Consumer<ThemeProvider>(
        builder: (context, ThemeProvider notifier, child) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        // SVG Background
                        Container(
                          margin: EdgeInsets.all(10),
                          child: SvgPicture.asset(
                            'assets/img/Group 1.svg',
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          verticalDirection: VerticalDirection.down,
                          children: [
                              Column(
                                children: [
                                  Text(
                                    "EYZ",
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    "MOVIE",
                                    style: TextStyle(
                                      fontSize: 48,
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
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        hintText: "example.exam@exam.com",
                                        filled: true,
                                        fillColor: isDark ? Color.fromRGBO(93, 93, 93, 1) : Color.fromARGB(255, 190, 190, 190),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: BorderSide.none,
                                        )
                                      ),
                                    ),
                                    SizedBox(height: 10), // jarak antar teks
                                    TextField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        hintText: "password",
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
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(builder: (context) => MainPage()),
                                      // );
                                    },
                                    child: Text('Sign In'),
                                  ),
                                ),
                              ),
                              SizedBox(height: 25,),
                              // RichText(
                              //   text: TextSpan(
                              //     style: TextStyle(fontSize: 18),
                              //     children: [
                              //       TextSpan(text: "Or continue with"),
                              //     ],
                              //   ),
                              // ),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     GestureDetector(
                              //       onTap: AuthService().signInWithGoogle(),
                              //       child: Container(
                              //         padding: EdgeInsets.all(20),
                              //         decoration: BoxDecoration(
                              //           border: Border.all(color: Colors.white),
                              //           borderRadius: BorderRadius.circular(16),
                              //           color: Colors.grey,
                              //         ),
                              //         child: Image.asset('assets/icons/google-icon.png'),
                              //       ),
                              //     )
                              //   ],
                              // ),
                              SizedBox(height: 49), 
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: 18),
                                  children: [
                                    TextSpan(
                                      text: "Didn't have an Account?",
                                      style: TextStyle(color: isDark ? Colors.white : Colors.black )
                                    ),
                                    WidgetSpan(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(builder: (context) => RegisterPage()),
                                            (route) => false
                                          );
                                        },
                                        child: Text(
                                          ' Sign Up Here!',
                                          style: TextStyle(
                                            color: !isDark ? Color.fromRGBO(0, 13, 231, 1) : Color.fromRGBO(23, 108, 255, 1),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 25), // jarak antar teks
                            ],
                        ),
                      ]
                    ),
                  ],
                ),
            ),
          );
        }
      ),
    );
  }
}