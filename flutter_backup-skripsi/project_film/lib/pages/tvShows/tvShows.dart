import 'dart:async';
import 'dart:convert';

import 'package:eyz_movie/_baseUrl/baseUrl.dart';
import 'package:eyz_movie/models/listViewModel.dart';
import 'package:eyz_movie/pages/membership/membership.dart';
import 'package:eyz_movie/pages/video/detailVideo.dart';
import 'package:eyz_movie/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TvShowPage extends StatefulWidget {
  const TvShowPage({super.key});

  @override
  State<TvShowPage> createState() => _TvShowPageState();
}

class _TvShowPageState extends State<TvShowPage> {
  late SharedPreferences storage;
  int myIndex =  1;
  int limit = 10;
  int page = 1;
  int condition = 0;
  String search = "";

  bool _isLoading = false;
  late bool isUserVIP;
  bool _isSearching = false;
  bool _hasMore = true; // untuk stop kalau datanya habis

  final TextEditingController _controllerText = TextEditingController();
  ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  List<PopularModel> populars = [];
  List<dynamic> video = [];

  void _getSearch() async {
    setState(() {
      _isLoading = true;
    });
    
    var resp = await BaseClient().getSearch("/tv", limit.toString(), page.toString(), search, condition.toString());
    var dataJson = jsonDecode(resp);
    
    if (dataJson['data'].isEmpty) {
      _hasMore = false; // stop kalau data habis
    } else {
      video.addAll(dataJson['data']);
      page++;
    }

    setState(() {
      _isLoading = false;
    });

    // GETTING VIP STATUS FROM USER
    var stringUser = storage.getString("user");
    var data = jsonDecode(stringUser.toString());
    isUserVIP = data['is_v_i_p'];
  }

  Future<void> initStorage() async {
    storage = await SharedPreferences.getInstance();
  }
  
  @override
  void initState() {
    initStorage();
    _debounce?.cancel();
    _getSearch();
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        // posisi 200px sebelum paling bawah
        if (!_isLoading && _hasMore) {
          _getSearch();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (query.isNotEmpty) {
        _searchAPI(query);
      }
    });
  }

  void _searchAPI(String query) {
    // debugPrint("🔍 Call API with query: $query");
    // TODO: Ganti dengan call API-mu
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
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, right: 8.0),
                  child: Row(
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
                          'TV Shows',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        itemCount: video.length + (_isLoading ? 1 : 0), 
                        itemBuilder: (context, index) {
                          if (index == video.length) {
                            return Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

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
                              builder: (context) => DetailVideo(id: item['id'].toString()),
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