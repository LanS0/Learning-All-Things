import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const mockBerita = [
  {
    "judul":
        "Senator Asal Jambi Sebut Keputusan Kejari Serang Setop Kasus Muhyani Hadirkan Keadilan",
    "isi":
        'jpnn.com, JAKARTA - Anggota DPD Ria Mayang Sari mengapresiasi keputusan Kejaksaan Negeri (Kejari) Serang menghentikan kasus Muhyani, penjaga ternak yang menusuk maling kambing hingga tewas. Ini yang harus kita hindari," ungkap anggota Komite III DPD itu.'
  },
  {"judul": "Hai2", "isi": ""},
  {"judul": "Hai3", "isi": ""},
  {"judul": "Hai4", "isi": ""},
  {"judul": "Hai5", "isi": ""}
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(mockBerita.length, (index) {
            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsPage(
                        title: "${mockBerita[index]['judul']}",
                        content: '${mockBerita[index]['isi']}',
                        foto: '${mockBerita[index]['foto']}'),
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
