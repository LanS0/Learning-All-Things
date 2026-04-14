import 'dart:convert';

import 'package:eyz_movie/components/sidebar/sidebar.dart';
import 'package:eyz_movie/pages/download/download.dart';
import 'package:eyz_movie/pages/favorite/favorite.dart';
import 'package:eyz_movie/pages/home/home.dart';
import 'package:eyz_movie/pages/search/search.dart';
import 'package:eyz_movie/pages/setting/setting.dart';
import 'package:eyz_movie/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isLoading = true;

  var email;
  var name;
  var is_vip;

  late SharedPreferences storage;
  int myIndex =  0;
  late Map<String, dynamic> user;

  @override
  void initState() {
    initStorage();
    super.initState();
  }
  
  Future<void> initStorage() async {
    storage = await SharedPreferences.getInstance();
    _getPrefs();
  }

  void _getPrefs() async {
    var stringUser = storage.getString("user");
    
    var data = jsonDecode(stringUser.toString());
    setState(() {
      user = data;
      isLoading = false;
      email = data['email'];
      name = data['name'];
      is_vip = data['is_vip'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading ? Consumer<ThemeProvider>(
      builder: (context, ThemeProvider notifier, child) {
        return Scaffold(
          appBar: _appBar(),
          drawer: Sidebar(name: name, email: email,),
          body: IndexedStack(
            index: myIndex,
            children: [
              HomePage(),
              SearchPage(),
              FavoritePage(),
              SettingPage(),
            ],
          ),
          bottomNavigationBar: _navbar(),
        );
      }
    )
    :
    Center(child: CircularProgressIndicator());
  }

  BottomNavigationBar _navbar() {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    return BottomNavigationBar(
      selectedItemColor: !isDark ? Color.fromRGBO(0, 13, 231, 1) : Colors.white,
      unselectedItemColor: Colors.grey,
      onTap: (value) {
        setState(() {
          myIndex = value;
        });
      },
      currentIndex: myIndex,
      items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
      ],
      backgroundColor: Colors.grey,
    );
  }

  Container _topBar() {
    return Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 152, 152, 152)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: SvgPicture.asset(
                  width: 30,
                  height: 30,
                  "assets/icons/Search.svg",
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10)
                ),
              ),
              Text(
                "Movies",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                "Series",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                "TV Shows",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
  }

  AppBar _appBar() {
    return AppBar(
      automaticallyImplyLeading: false, // MENGHILANGKAN PANAH, SAAT MENGGUNAKAN NAVIGATOR.push DAN ADA APPBAR ke-2
      title: Text(
        "EYZ MOVIE",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
        ),
      ),
      centerTitle: true,
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
    );
  }
}