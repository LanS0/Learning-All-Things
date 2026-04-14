import 'package:eyz_movie/pages/login/login.dart';
import 'package:eyz_movie/pages/mainPage.dart';
import 'package:eyz_movie/pages/series/series.dart';
import 'package:eyz_movie/pages/tvShows/tvShows.dart';
import 'package:eyz_movie/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sidebar extends StatefulWidget {
  final String name;
  final String email;

  const Sidebar({super.key, required this.name, required this.email});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  // late SharedPreferences storage;

  // @override
  // void initState() {
  //   initStorage();
  //   super.initState();
  // }

  // Future<void> initStorage() async {
  //   storage = await SharedPreferences.getInstance();
  // }
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<ThemeProvider>(
        builder: (context, ThemeProvider notifier, child) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                arrowColor: Colors.black,
                accountName: Text(
                  widget.name ?? "~",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ), 
                accountEmail: Text(
                  widget.email ?? "~",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  child: ClipOval(
                    // child: Image.file(
                    //   File("/asasets/img/default_profile_image.svg"),
                    //   width: 90,
                    //   height: 90,
                    //   fit: BoxFit.fill,
                    // ),
                    child: SvgPicture.asset(
                      width: 70,
                      height: 70,
                      color: Colors.black,
                      "assets/img/default_profile_image.svg",
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  // image: DecorationImage(
                  //   image: FileImage(
                  //     File("/assets/img/Group 1.svg")
                  //   )
                  // ) 
                  color: Color.fromRGBO(0, 13, 231, 1),
                ),
              ),
              ListTile(
                leading: Icon(Icons.local_movies),
                title: Text("Movies"),
                onTap: () => {
                  Navigator.pop(context),
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainPage(),
                    ),
                    (router) => false,
                  )
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_in_picture),
                title: Text("Series"),
                onTap: () => {
                  Navigator.pop(context),
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeriesPage(),
                    ),
                  )
                },
              ),
              ListTile(
                leading: Icon(Icons.tv),
                title: Text("TV Shows"),
                onTap: () => {
                  Navigator.pop(context),
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TvShowPage(),
                    ),
                  )
                },
              ),
              ListTile(
                leading: Icon(Icons.dark_mode),
                title: Text("Dark Theme"),
                trailing: Switch(
                  value: notifier.isDark, 
                  onChanged: (value) => {
                    notifier.toggleTheme()
                  }
                ),
              ),
              // SizedBox(height: 24),
              // ListTile(
              //   leading: Icon(Icons.exit_to_app),
              //   title: Text("Log Out"),
              //   onTap: () => {
              //     storage.clear(),
              //     Navigator.pushAndRemoveUntil(
              //       context,
              //       MaterialPageRoute(builder: (context) => const LoginPage()),
              //       (route) => false,
              //     )
              //   },
              // ),
            ],
          );
        }
      ),
    );
  }
}