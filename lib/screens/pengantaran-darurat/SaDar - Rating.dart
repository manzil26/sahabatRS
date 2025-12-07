import 'package:flutter/material.dart';

class SadarRating extends StatelessWidget {
  const SadarRating({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Beri Rating"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 50),
              // backgroundImage: AssetImage("assets/driver.png"),
            ),
            const SizedBox(height: 15),
            const Text("Esa Anugrah",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text("Ambulance"),
            const SizedBox(height: 25),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => const Icon(Icons.star, color: Colors.orange, size: 35),
              ),
            ),

            const SizedBox(height: 25),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Tulis ulasan...",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Selesai -> Kembali ke Home (pop semua sampai home)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Kirim Rating", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}