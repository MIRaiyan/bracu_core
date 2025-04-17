import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class BracuCoreApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RatingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RatingPage extends StatefulWidget {
  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _rating = 0;
  bool _submitted = false;

  final List<String> emojis = ["😠", "😞", "😐", "🙂", "🥰"];
  final List<String> texts = ["Terrible!", "Bad!", "Okay!", "Good!", "Great!"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE7828C),
      body: Center(
        child: _submitted ? thankYouWidget() : ratingWidget(),
      ),
    );
  }

  Widget ratingWidget() {
    return Scaffold(
      backgroundColor: Color(0xFF7DA7DE),
      appBar: AppBar(
        title: Text(
          "Feedback",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Color(0xFF7DA7DE),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo (you can use Image.asset if it's an image)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                "BRACU\nCORE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.0,
                ),
              ),
            ),

            Text(
              "Tell us how was your experience",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),

            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white60,
              child: Text(
                _rating > 0 ? emojis[_rating - 1] : "🙂",
                style: TextStyle(fontSize: 40),
              ),
            ),

            SizedBox(height: 15),
            Text(
              "Please rate us!",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    size: 32,
                    color: _rating > index ? Colors.black : Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),

            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _rating == 0
                  ? null
                  : () {
                setState(() {
                  _submitted = true;
                });

                // Delay and return to rating page
                Future.delayed(Duration(seconds: 5), () {
                  setState(() {
                    _submitted = false;
                    _rating = 0;
                  });
                });
              },

              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                child: Text(
                  "Submit",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow.shade400,
                shape: StadiumBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget thankYouWidget() {
    return Scaffold(
      backgroundColor: Color(0xFFD2594F),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Sparkles around star
                  ..._buildStarParticles(),
                  Lottie.asset(
                    'assets/animation/star.json',
                    width: 250,
                    height: 250,
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                "Thank You for your feedback",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// ➕ Helper functions must be INSIDE _RatingPageState:
  List<Widget> _buildStarParticles() {
    return [
      Positioned(top: 0, child: _dot()),
      Positioned(bottom: 0, child: _dot()),
      Positioned(left: 0, child: _dot()),
      Positioned(right: 0, child: _dot()),
      Positioned(top: 10, left: 10, child: _dot()),
      Positioned(bottom: 10, right: 10, child: _dot()),
    ];
  }

  Widget _dot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.yellow.shade400,
        shape: BoxShape.circle,
      ),
    );
  }
}
