// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class SplashScreenOld extends StatelessWidget {
//   const SplashScreenOld ({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.dark(),
//       home: Scaffold(
//         body: Center(
//           child: AnimatedBuilder(animation: _controller, builder: ((context, _) {
//             return(Container(
//               width: screenWidth,
//               height: screenHeight,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(colors:
//                 [
//                   Colors.blue, Colors.yellow
//                 ],
//                 begin: _topAlignmentAnimation.value, end: _bottomAlignmentAnimation.value,
//                 )
//               ),
//             ));
//           }),
//         )
//       ),
   
//        ) );
//   }
// }