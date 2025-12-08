import 'package:flutter/material.dart';
import 'package:sahabat_rs/screens/pengantaran-darurat/saDar-pengantaran-selesai.dart';
import 'package:sahabat_rs/screens/pelacakan/SaLacak-Tracking.dart'; // TAMBAH untuk tracking

class SadarKonfirmasi extends StatelessWidget {
  const SadarKonfirmasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.grey.shade300),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 320, // Sedikit ditinggikan agar muat
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 35,
                        // Pastikan asset ini ada, atau ganti icon
                        child: Icon(Icons.person, size: 40), 
                        // backgroundImage: AssetImage("assets/driver.png"), 
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Esa Anugrah",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("Ambulance"),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              Text(" 5.0"),
                            ],
                          )
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: const [
                          Icon(Icons.call, size: 28, color: Colors.green),
                          SizedBox(width: 10),
                          Icon(Icons.message, size: 28, color: Colors.blue),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text("Kami menuju ke lokasi kamu!"),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigasi ke Pengantaran Selesai
                        //Navigator.pushReplacement(
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  //const SadarPengantaranSelesai()), //punya nabb aku koment sementara 
                                  const SaLacakTrackingPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange),
                      child: const Text("Lacak Pendampingan", style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}