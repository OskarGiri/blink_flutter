import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentImage = 0;

  final List<String> images = [
    'assets/images/butterfly@.jpg',
    'assets/images/butterfly.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            /// IMAGE SWIPER
            Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() => currentImage = index);
                    },
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          images[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),

                  /// TOP IMAGE INDICATORS
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: List.generate(
                        images.length,
                        (index) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 4,
                            decoration: BoxDecoration(
                              color: currentImage == index
                                  ? Colors.white
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// USER INFO
                  Positioned(
                    bottom: 90,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Ram, 26 ✔",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: const [
                            Chip(label: Text("Online shopping")),
                            Chip(label: Text("Anime")),
                            Chip(label: Text("Horror films")),
                            Chip(label: Text("Skincare")),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// ACTION BUTTONS
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  actionButton(Icons.refresh, Colors.orange),
                  actionButton(Icons.close, Colors.red),
                  actionButton(Icons.favorite, Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),

      /// BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, '/chat');
          if (index == 2) Navigator.pushNamed(context, '/profile');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  Widget actionButton(IconData icon, Color color) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.white,
      child: Icon(icon, color: color, size: 28),
    );
  }
}
