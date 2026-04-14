import 'dart:convert';

import 'package:eyz_movie/_baseUrl/baseUrl.dart';
import 'package:eyz_movie/models/listViewModel.dart';
import 'package:eyz_movie/pages/membership/membership.dart';
import 'package:eyz_movie/pages/video/detailVideo.dart';
import 'package:eyz_movie/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SharedPreferences storage;
  
  bool isLoading = true;

  int myIndex =  0;
  int limit = 10;
  int page = 1;
  String search = "";

  // List<PopularModel> populars = [];
  late Map<String, dynamic> user;
  late bool isUserVIP;
  List<dynamic> popular = [];
  List<dynamic> recent = [];
  List<dynamic> recomendation = [];
  List<dynamic> trending = [];
  List<dynamic> comingSoon = [];

  void _getVideo() async {
    var resp = await BaseClient().getVideo("/video/home", limit.toString(), page.toString(), search);
    var dataJson = jsonDecode(resp);
    setState(() {
      user = dataJson['data'];
      // print(user);
      // print(user['recent'] == null);

      if (user['popular'] != null) {
        popular = user['popular'];
      } else {
        popular = []; // fallback ke list kosong
      }

      if (user['recent'] != null) {
        recent = user['recent'];
      } else {
        recent = []; // fallback ke list kosong
      }

      if (user['recomendation'] != null) {
        recomendation = user['recomendation'];
      } else {
        recomendation = []; // fallback ke list kosong
      }

      if (user['trending'] != null) {
        trending = user['trending'];
      } else {
        trending = []; // fallback ke list kosong
      }

      if (user['coming_soon'] != null) {
        comingSoon = user['coming_soon'];
      } else {
        comingSoon = []; // fallback ke list kosong
      }

      // GETTING VIP STATUS FROM USER
      var stringUser = storage.getString("user");
      var data = jsonDecode(stringUser.toString());
      isUserVIP = data['is_v_i_p'];
      
      isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      // Ganti dengan get data dari API jika perlu
      _getVideo();
    });
  }

  Future<void> initStorage() async {
    storage = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    initStorage();
    _getVideo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading ? 
    Consumer<ThemeProvider>(
      builder: (context, ThemeProvider notifier, child) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // _topBar(),
                  SizedBox(height: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      recent.isEmpty ? Container() : _recent(),
                      SizedBox(height: 20,),
                      _popular(),
                      SizedBox(height: 20,),
                      _trending(),
                      SizedBox(height: 20,),
                      _comingSoon(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    )
    :
    Center(child: CircularProgressIndicator());
  }

  Column _recent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Recent',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          height: 150,
          child: ListView.separated(
            itemCount: recent.length,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            separatorBuilder: (context, index) => SizedBox(width: 25, ),
            itemBuilder: (context, index) {
              var vids = recent[index];
              return Container(
                width: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(0),
                      child: GestureDetector(
                        onTap: () => {
                          vids['is_v_i_p'] && !isUserVIP ?
                          showDialog(
                            context: context,
                            barrierDismissible: false, // klik di luar modal tidak menutup
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text("Apakah Anda ingin Berlangganan untuk Melanjutkan?"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Tutup modal
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Tutup modal
                                      // Aksi "Go" di sini
                                      // print("Go ditekan!");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Membership(),
                                        ),
                                      );
                                    },
                                    child: Text("Langganan"),
                                  ),
                                ],
                              );
                            },
                          )
                          :
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailVideo(id: vids['id'].toString()),
                            ),
                          ).then((result) {
                            if (result == true) {
                              initStorage();
                            }
                          })
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 10,
                          // color: Colors.blue.shade300,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              vids['thumbnail'] != ''
                              ? Opacity(
                                opacity: 0.25,
                                child: Image.network(
                                  vids['thumbnail'],
                                  width: 100,
                                  height: 125,
                                  fit: BoxFit.cover,
                                  ),
                              )
                              : Container(
                                  width: 100,
                                  height: 125,
                                ),
                              // Image.asset(
                              //   populars[index].path,
                              //   fit: BoxFit.cover,
                              //   width: 100,
                              //   height: 125,
                              // ),
                              Text(vids['title']),
                              vids['is_v_i_p'] && !isUserVIP ?
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow[700],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'VIP',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )
                              :
                              Container(),
                            ],
                          )
                        ),
                      )
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Column _popular() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Popular',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          height: 150,
          child: ListView.separated(
            itemCount: popular.length,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            separatorBuilder: (context, index) => SizedBox(width: 25, ),
            itemBuilder: (context, index) {
              var vids = popular[index];
              return Container(
                width: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(0),
                      child: GestureDetector(
                        onTap: () => {
                          vids['is_v_i_p'] && !isUserVIP ?
                          showDialog(
                            context: context,
                            barrierDismissible: false, // klik di luar modal tidak menutup
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text("Apakah Anda ingin Berlangganan untuk Melanjutkan?"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Tutup modal
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Tutup modal
                                      // Aksi "Go" di sini
                                      // print("Go ditekan!");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Membership(),
                                        ),
                                      );
                                    },
                                    child: Text("Langganan"),
                                  ),
                                ],
                              );
                            },
                          )
                          :
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailVideo(id: vids['id'].toString()),
                            ),
                          )
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 10,
                          // color: Colors.blue.shade300,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              vids['thumbnail'] != ''
                              ? Opacity(
                                opacity: 0.25,
                                child: Image.network(
                                  vids['thumbnail'],
                                  width: 100,
                                  height: 125,
                                  fit: BoxFit.cover,
                                  ),
                              )
                              : Container(
                                  width: 100,
                                  height: 125,
                                ),
                              // Image.asset(
                              //   populars[index].path,
                              //   fit: BoxFit.cover,
                              //   width: 100,
                              //   height: 125,
                              // ),
                              Text(vids['title']),
                              vids['is_v_i_p'] && !isUserVIP ?
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow[700],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'VIP',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )
                              :
                              Container(),
                            ],
                          )
                        ),
                      )
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Column _trending() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Trending',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          height: 150,
          child: ListView.separated(
            itemCount: trending.length,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            separatorBuilder: (context, index) => SizedBox(width: 25, ),
            itemBuilder: (context, index) {
              var vids = trending[index];
              return Container(
                width: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(0),
                      child: GestureDetector(
                        onTap: () => {
                          vids['is_v_i_p'] && !isUserVIP ?
                          showDialog(
                            context: context,
                            barrierDismissible: false, // klik di luar modal tidak menutup
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text("Apakah Anda ingin Berlangganan untuk Melanjutkan?"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Tutup modal
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Tutup modal
                                      // Aksi "Go" di sini
                                      // print("Go ditekan!");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Membership(),
                                        ),
                                      );
                                    },
                                    child: Text("Langganan"),
                                  ),
                                ],
                              );
                            },
                          )
                          :
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailVideo(id: vids['id'].toString()),
                            ),
                          )
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 10,
                          // color: Colors.blue.shade300,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              vids['thumbnail'] != ''
                              ? Opacity(
                                opacity: 0.25,
                                child: Image.network(
                                  vids['thumbnail'],
                                  width: 100,
                                  height: 125,
                                  fit: BoxFit.cover,
                                  ),
                              )
                              : Container(
                                  width: 100,
                                  height: 125,
                                ),
                              // Image.asset(
                              //   populars[index].path,
                              //   fit: BoxFit.cover,
                              //   width: 100,
                              //   height: 125,
                              // ),
                              Text(vids['title']),
                              vids['is_v_i_p'] && !isUserVIP ?
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow[700],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'VIP',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )
                              :
                              Container(),
                            ],
                          )
                        ),
                      )
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Column _comingSoon() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          height: 150,
          child: ListView.separated(
            itemCount: comingSoon.length,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            separatorBuilder: (context, index) => SizedBox(width: 25, ),
            itemBuilder: (context, index) {
              var vids = comingSoon[index];
              return Container(
                width: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(0),
                      child: GestureDetector(
                        onTap: () => {
                          showDialog(
                            context: context, 
                            builder: (context) => AlertDialog(
                              title: Text("COMING SOON!!"),
                              content: Text("FILM AKAN DATANG KE APLIKASI INI!!"),
                            )
                          )
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 10,
                          // color: Colors.blue.shade300,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              vids['thumbnail'] != ''
                              ? Opacity(
                                opacity: 0.25,
                                child: Image.network(
                                  vids['thumbnail'],
                                  width: 100,
                                  height: 125,
                                  fit: BoxFit.cover,
                                  ),
                              )
                              : Container(
                                  width: 100,
                                  height: 125,
                                ),
                              // Image.asset(
                              //   populars[index].path,
                              //   fit: BoxFit.cover,
                              //   width: 100,
                              //   height: 125,
                              // ),
                              Text(vids['title']),
                              vids['is_v_i_p'] && !isUserVIP ?
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.yellow[700],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'VIP',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )
                              :
                              Container(),
                            ],
                          )
                        ),
                      )
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}