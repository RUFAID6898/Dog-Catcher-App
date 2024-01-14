import 'package:flutter/material.dart';

// ignore: must_be_immutable
class HomeScreenWidget extends StatelessWidget {
  String image;
  Function()? onTap;
  String ButtonName;
  Color textcolor;
  bool iconvisibility;
  IconData icons;

  HomeScreenWidget({
    required this.image,
    required this.onTap,
    required this.ButtonName,
    required this.textcolor,
    required this.iconvisibility,
    required this.icons,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(image), fit: BoxFit.cover),
                // color: Colors.amber,
                borderRadius: BorderRadius.circular(20)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 218, 214, 214),
                  borderRadius: BorderRadius.circular(20)),
              child: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ButtonName,
                    style: TextStyle(color: textcolor),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Visibility(visible: iconvisibility, child: Icon(icons))
                ],
              )),
            ),
          ),
        ),
      ],
    );
  }
}
