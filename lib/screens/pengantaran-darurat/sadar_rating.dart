import 'package:flutter/material.dart';

class SadarRating extends StatefulWidget {
  const SadarRating({super.key});

  @override
  State<SadarRating> createState() => _SadarRatingState();
}

class _SadarRatingState extends State<SadarRating> {
  int selectedRating = 0;
  TextEditingController tipController = TextEditingController();

  List<int> tipOptions = [500, 1000, 2000, 5000];

  void showSuccessPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Berhasil"),
        content: const Text("Rating dan tip berhasil dikirim."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup popup
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            /// ----- TOMBOL CLOSE DI ATAS -----
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Tidak kembali ke halaman user
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                      )
                    ],
                  ),
                  child: const Icon(Icons.close, size: 28),
                ),
              ),
            ),

            /// ----- KONTEN UTAMA -----
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  const CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage("assets/driver.png"),
                  ),

                  const SizedBox(height: 15),
                  const Text(
                    "Esa Anugrah",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text("Ambulance"),

                  const SizedBox(height: 25),

                  /// ----- BINTANG RATING -----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedRating = i + 1;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.star,
                            size: 40,
                            color: (i < selectedRating)
                                ? Colors.orange
                                : Colors.grey[300],
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  /// ----- TIP BUTTONS -----
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Kasih Tip", style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: tipOptions.map((amount) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              tipController.text = amount.toString();
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange),
                              color: tipController.text == amount.toString()
                                  ? Colors.orange.withOpacity(0.2)
                                  : Colors.white,
                            ),
                            child: Center(
                              child: Text(
                                "Rp $amount",
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 15),

                  /// ----- TIP INPUT -----
                  TextField(
                    controller: tipController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Min 500",
                      prefixText: "Rp ",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const Spacer(),

                  /// ----- SUBMIT -----
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        showSuccessPopup();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Kirim Rating",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
