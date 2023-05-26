import 'package:flutter/material.dart';

class MySearchWidget extends StatefulWidget {
  const MySearchWidget({Key key}) : super(key: key);

  @override
  State<MySearchWidget> createState() => _MySearchWidgetState();
}

class _MySearchWidgetState extends State<MySearchWidget> with SingleTickerProviderStateMixin {

  Animation<double> animation;
  AnimationController animController;

  bool isForward = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: animation.value,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                bottomLeft: Radius.circular(50),
              )
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 5),
              child: TextField(
                cursorColor: Colors.white,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none
                ),
              ),
            ),
          ),
          Container(
            width: 50,
            height: 50,
            child: IconButton(
              onPressed: () {
                if (isForward) {
                  animController.forward();
                  isForward = true;
                }
                else {
                  animController.reverse();
                  isForward = false;
                }
                print(isForward);
              },
              icon: Icon(Icons.search),
              color: Colors.white,
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: animation.value > 1 ? BorderRadius.only(
                topLeft: Radius.circular(0),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(50),
                topRight: Radius.circular(50)
              ) : BorderRadius.circular(50),
            )
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    final curvedAnimation = CurvedAnimation(parent: animController, curve: Curves.easeOutExpo);
    animation = Tween<double>(begin: 0, end: 150).animate(curvedAnimation)
      ..addListener(() {
        setState(() {

        });
      });
  }

}
