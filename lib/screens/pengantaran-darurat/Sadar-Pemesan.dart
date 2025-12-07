import 'package:flutter/material.dart';

class SadarPemesan extends StatelessWidget {
  const SadarPemesan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // MAP BACKGROUND (dummy background color)
          Container(color: Colors.grey.shade300),

          // BOTTOM PANEL
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 240,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: const [
                        Icon(Icons.health_and_safety,
                            color: Colors.orange, size: 40),
                        SizedBox(height: 10),
                        Text(
                          "Tenang dulu ya, Kami lagi nyari pendamping darurat secepatnya",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent),
                      child: const Text("Batalkan Pesanan"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
