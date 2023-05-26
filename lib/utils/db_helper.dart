import 'dart:convert';
import 'package:demo_app/models/user.dart';
import 'package:demo_app/utils/constants.dart';
import 'package:demo_app/utils/methods.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class DbHelper {
  DbHelper._createInstance();

  String db_name = "demo_app.db";

  String userTable = "userTable";
  String col_user_id = "id";
  String col_username = "username";
  String col_password = "password";
  String col_deviceAccess = "device_access";
  String col_deviceID = "device_id";

  String appTable = "appTable";
  String col_app_id = "id";
  String col_app_name = "name";
  String col_app_text = "text";
  String col_app_image = "image";

  static Database _database;
  static DbHelper helper;

  factory DbHelper(){
    if(helper == null){
      helper = DbHelper._createInstance();
    }
    return helper;
  }

  Future<Database> get database async {
    if(_database == null){
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future createDb(Database db, int version) async {

    String createUserTable = "create table $userTable ("
        "$col_user_id integer primary key,"
        "$col_username text,"
        "$col_password text,"
        "$col_deviceAccess text,"
        "$col_deviceID text)";

    String createAppTable = "create table $appTable ("
        "$col_app_id integer primary key,"
        "$col_app_name text,"
        "$col_app_text text,"
        "$col_app_image text)";

    await db.execute(createAppTable);
    await db.execute(createUserTable);
  }

  Future<Database> initializeDatabase() async{
    final db_path = await getDatabasesPath();
    final path = join(db_path, db_name);
    return await openDatabase(path, version: 1, onCreate: createDb);
  }

  Future<bool> isUsernameExist(String username) async {
    final params = {
      "username": username
    };
    var uri = Uri.https(Constants.server_get_url, '${Constants.api_url}/_isUsernameExist.php', params);
    var response = await http.get(uri, headers: null);
    if(response.statusCode == 200){
      if(response.body == 'true'){
        return true;
      }
      else{
        return false;
      }
    }
    else{
      print("DbHelper.isUsernameExist failed with code: ${response.statusCode}");
      return false;
    }
  }

  Future<bool> isDeviceIDExist(String deviceID) async {
    final params = {
      "device_id": deviceID
    };
    var uri = Uri.https(Constants.server_get_url, '${Constants.api_url}/_isDeviceIDExist.php', params);
    var response = await http.get(uri, headers: null);
    if(response.statusCode == 200){
      if(response.body == 'true'){
        return true;
      }
      else{
        return false;
      }
    }
    else{
      print("DbHelper.isDeviceIDExist failed with code: ${response.statusCode}");
      return false;
    }
  }

  Future<User> getUserOnline(String username, String password) async {
    var user;
    final params  = {
      "username": username,
      "password": password
    };
    var url = Uri.https(Constants.server_get_url, '${Constants.api_url}/_getUser.php', params);
    var response = await http.get(url);
    if(response.statusCode == 200){
      if(response.body != "failure"){
        var json = jsonDecode(response.body);
        user = User(
            id: int.parse(json[0][col_user_id].toString()),
            username: json[0][col_username],
            password: json[0][col_password],
            device_access: json[0][col_deviceAccess],
            deviceId: json[0][col_deviceID]
        );
      }
      else {
        user = null;
      }
    }
    else{
      print("DbHelper.getUserOnline response error: ${response.body}");
    }
    return user;
  }

  Future<User> getUserByEmail(String username) async {
    var user;
    final params  = {
      "username": username
    };
    var url = Uri.https(Constants.server_get_url, '${Constants.api_url}/_getUserByEmail.php', params);
    var response = await http.get(url);
    print(response.body);
    if(response.statusCode == 200){
      if(response.body != "failure"){
        var json = jsonDecode(response.body);
        user = User(
          id: int.parse(json[0][col_user_id].toString()),
          username: json[0][col_username],
          password: json[0][col_password],
          device_access: json[0][col_deviceAccess],
          deviceId: json[0][col_deviceID],
        );
      }
      else {
        user = null;
      }
    }
    else{
      print("DbHelper.getUserByEmail response error: ${response.body}");
    }
    return user;

  }

  Future<User> getUser() async {
    var user;
    Database db = await database;
    String query = "select * from $userTable";
    List<Map<String, Object>> result = await db.rawQuery(query);
    for(var i = 0; i<result.length; i++){
      user = User(
          id: result[i][col_user_id],
          username: result[i][col_username],
          password: result[i][col_password],
          device_access: result[i][col_deviceAccess],
          deviceId: result[i][col_deviceID]
      );
    }
    return user;
  }

  Future<void> saveUser(User user) async{
    Database db = await database;
    String query = "insert into $userTable ($col_user_id, $col_username,"
        " $col_password, $col_deviceID, $col_deviceAccess) values ('${user.id}', '${user.username}',"
        " '${user.password}', '${user.deviceId}', '${user.device_access}')";
    await db.execute(query);
  }

  Future<bool> uploadUser(User user) async {
    Map<String, dynamic> params = {
      "username": user.username,
      "password": user.password,
      "device_access": user.device_access,
      "device_id": user.deviceId
    };

    try{
      var uri = Uri.parse("${Constants.server_url}${Constants.api_url}/_upload.php");
      var response = await http.post(uri, body: params);
      if(response.body == 'success'){
        return true;
      }
      else{
        showToast(response.body);
        return false;
      }
    }
    catch(e){
      print("dbHelper.uploadUser: ${e.toString()}");
      return false;
    }
  }

}