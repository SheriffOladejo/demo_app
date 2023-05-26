import 'package:demo_app/models/item.dart';
import 'package:flutter/material.dart';

class ItemAdapter extends StatelessWidget {

  Item item;

  ItemAdapter({
    this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        elevation: 10,
        color: Colors.white,
        child: Container(
          color: Colors.white,
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(height: 5,),
              Text(item.name, style: const TextStyle(
                color: Colors.black,
                fontFamily: 'sono-bold',
                fontSize: 18,
              ),),
              Container(height: 10,),
              Image.network(item.image,),
              Container(height: 10,),
              Container(
                padding: const EdgeInsets.only(left: 10),
                alignment: Alignment.centerLeft,
                child: Text(item.text, style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'sono-regular',
                  fontSize: 16,
                ),),
              ),
              Container(height: 10,)
            ],
          ),
        ),
      ),
    );
  }
}
