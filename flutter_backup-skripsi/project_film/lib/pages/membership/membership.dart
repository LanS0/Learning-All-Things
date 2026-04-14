import 'package:eyz_movie/pages/home/home.dart';
import 'package:flutter/material.dart';

class Membership extends StatelessWidget {
  const Membership({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
        
            SizedBox(height: 48,),
        
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kirimkan Bukti Transfer ke Nomor Admin, Atau bisa Memverifikasikan Status'),
                SizedBox(height: 8,),
                Text('Admin 1 : 021-112'),
                Text('Admin 2 : 021-14045'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}