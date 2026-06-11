import 'package:flutter/material.dart';

class CurvedAppBarScreen extends StatelessWidget {
  const CurvedAppBarScreen({key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Nichay wala background color
      body: Stack(
        children: [
          // Curved App Bar Background
          ClipPath(
            clipper: AppBarClipper(),
            child: Container(
              height: 240, // Aap apni marzi se height adjust kar sakte hain
              color:
                  const Color(0xff3b9499), // Aap ki image wala teal/blue color
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper jo perfect curve banaye ga
class AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40); // Start from top-left to bottom-left

    // Curve banane ke liye control point aur end point
    var firstControlPoint = Offset(size.width / 2, size.height + 20);
    var firstEndPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    path.lineTo(size.width, 0); // Line to top-right
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
