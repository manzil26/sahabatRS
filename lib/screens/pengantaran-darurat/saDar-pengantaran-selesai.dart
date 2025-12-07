import 'package:flutter/material.dart';
import 'package:sahabat_rs/screens/pengantaran-darurat/SaDar - Rating.dart';

class SadarPengantaranSelesai extends StatelessWidget {
  const SadarPengantaranSelesai({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.grey.shade300),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 260,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    child: Icon(Icons.person, size: 40),
                    // backgroundImage: AssetImage("assets/driver.png"),
                  ),
                  const SizedBox(height: 10),
                  const Text("Esa Anugrah",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text("Ambulance"),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigasi ke Rating
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SadarRating()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text("Pengantaran Selesai", style: TextStyle(color: Colors.white)),
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