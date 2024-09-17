import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project1/pages/home.dart';

void main() {
  runApp(MyApp());
}

final options = {
  'method': 'GET',
  'url': 'https://news67.p.rapidapi.com/v2/topic-search',
  'params': {'languages': 'id', 'search': 'Maling'},
  'headers': {
    'X-RapidAPI-Key': dotenv.env['X-RapidAPI-Key'],
    'X-RapidAPI-Host': dotenv.env['X-RapidAPI-Host']
  }
};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(berita.length, (index) {
            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsPage(
                        title: "${berita[index]['judul']}",
                        content: '${berita[index]['isi']}',
                        foto: '${berita[index]['foto']}'),
                  ),
                );
              },
              child: Text('Baca Berita ${index + 1}'),
            );
          }),
        ),
      ),
    );
  }
}

AppBar _appBar() {
  return AppBar(
    title: Text('Home'),
  );
}

// Tambahkan kelas lainnya untuk halaman-halaman berita selanjutnya.
class NewsPage extends StatelessWidget {
  final String title;
  final String content;
  final String foto;

  NewsPage({required this.title, required this.content, required this.foto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(content),
      ),
    );
  }
}
