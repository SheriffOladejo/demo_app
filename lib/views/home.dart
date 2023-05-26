import 'dart:convert';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:demo_app/adapters/item_adapter.dart';
import 'package:demo_app/models/item.dart';
import 'package:demo_app/utils/constants.dart';
import 'package:demo_app/utils/hex_color.dart';
import 'package:demo_app/utils/methods.dart';
import 'package:demo_app/utils/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {

  bool isForward = false;

  bool is_loading = false;

  List<Item> itemList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("#FF66C4"),
        title: const Text(
          "Home",
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'sono-regular',
              fontSize: 20
          ),
        ),
        actions: [
          SearchWidget(
            isForward: isForward,
            callback: callback,
          ),
          Container(width: 10,),
        ],
      ),
      body: is_loading ? loadingPage() :
      OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return SingleChildScrollView(
              child: StaggeredGrid.count(
                crossAxisCount: 1,
                children: List.generate(itemList.length, (index) {
                  return ItemAdapter(item: itemList[index],);
                }),
              ),
            );
          }
          else if (orientation == Orientation.landscape) {
            return SingleChildScrollView(
              child: StaggeredGrid.count(
                crossAxisCount: 2,
                children: List.generate(itemList.length, (index) {
                  return ItemAdapter(item: itemList[index],);
                }),
              ),
            );
          }
          return Container();
        }
      )
    );
  }

  void callback(String search) async {
    setState(() {

    });
    if (search.isNotEmpty) {
      setState(() {
        isForward = true;
        is_loading = true;
      });
      await searchItems(search.trim().toLowerCase());
    }
    else {
      itemList = [];
      setState(() {
        isForward = false;
      });
    }
  }

  Future<void> searchItems(String search) async {
    itemList.clear();
    List<String> words = search.split(" ");
    final params = {
      "search": words[0]
    };
    var uri = Uri.https(Constants.server_get_url, "${Constants.api_url}/_getItems.php", params);
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      if (response.body != 'failure') {
        var json = jsonDecode(response.body);
        List<dynamic> l = json;
        for(var i = 0; i<l.length; i++){
          var m = Item(
              id: int.parse(l[i]["id"]),
              name: l[i]["name"],
              text: l[i]["texts"],
              image: l[i]["image"],
          );
          itemList.add(m);
        }

        List<Item> searchList = [];
        searchList.addAll(itemList);

        if (words.length > 1) {
          for (int i = 1; i < words.length; i++) {
            for (int j = 0; j < searchList.length; j++) {
              String text = searchList[j].text.trim().toLowerCase();
              if (!text.contains(words[i].trim().toLowerCase())) {
                itemList.remove(searchList[j]);
              }
            }
          }
        }

        setState(() {
          is_loading = false;
        });
    }
    else {
      setState(() {
        is_loading = false;
      });
      showToast("Not found");
    }
  }

}
}
