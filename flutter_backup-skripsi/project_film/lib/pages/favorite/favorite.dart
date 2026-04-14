import 'dart:convert';
import 'dart:io';

import 'package:eyz_movie/_baseUrl/baseUrl.dart';
import 'package:eyz_movie/models/listViewModel.dart';
import 'package:eyz_movie/pages/membership/membership.dart';
import 'package:eyz_movie/pages/video/detailSeries.dart';
import 'package:eyz_movie/pages/video/detailVideo.dart';
import 'package:eyz_movie/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late SharedPreferences storage;
  late bool isUserVIP;

  int myIndex =  1;
  int limit = 10;
  int page = 1;
  String search = "";

  // List<PopularModel> populars = [];
  List<dynamic> video = [];

  // void _getPopulars() {
  //   populars = PopularModel.getPopular();
  // }

  void _getVideo() async {
    // var resp = await BaseClient().getVideo("/video/home", limit.toString(), page.toString(), search);
    // var dataJson = jsonDecode(resp);
    // setState(() {
    //   // video = dataJson['data'];
    //   // print(dataJson['data']);
    // });

    final dir = await getApplicationDocumentsDirectory();
    // Simpan metadata ke file JSON
    final metadataFile = File("${dir.path}/favorite.json");
    List favorite = [];

    if (await metadataFile.exists()) {
      final content = await metadataFile.readAsString();
      favorite = jsonDecode(content);
    }

    setState(() {
      video = favorite;
    });
  }

  Future<void> initStorage() async {
    storage = await SharedPreferences.getInstance();

    // GETTING VIP STATUS FROM USER
    var stringUser = storage.getString("user");
    var data = jsonDecode(stringUser.toString());
    isUserVIP = data['is_v_i_p'];
  }
  
  @override
  void initState() {
    initStorage();
    _getVideo();
    // _getPopulars();
    super.initState();
  }

  Future<void> _refreshData() async {
    setState(() {
      // Ganti dengan get data dari API jika perlu
      _getVideo();
    });
  }

  @override
  Widget build(BuildContext context) {
    _getVideo();
    return Consumer<ThemeProvider>(
      builder: (context, ThemeProvider notifier, child) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          'Favorite',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      video.length > 0 ? 
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
                          itemCount: video.length, 
                          itemBuilder: (context, index) {
                            final item = video[index];
                            return Container(
                  width: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(0),
                        child: GestureDetector(
                          onTap: () => {
                            item['is_v_i_p'] && !isUserVIP ?
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
                                builder: (context) => !item['is_series'] ? DetailVideo(id: item['id'].toString()) : DetailSeries(id: item['id'].toString()),
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
                                item['thumbnail'] != ''
                                ? Opacity(
                                  opacity: 0.25,
                                  child: Image.network(
                                    item['thumbnail'],
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    ),
                                )
                                : Container(
                                    width: 200,
                                    height: 200,
                                  ),
                                // Image.asset(
                                //   populars[index].path,
                                //   fit: BoxFit.cover,
                                //   width: 100,
                                //   height: 125,
                                // ),
                                Text(item['title']),
                                item['is_v_i_p'] && !isUserVIP ?
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
                  :
                  Container()
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}