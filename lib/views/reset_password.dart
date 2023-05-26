import 'package:demo_app/models/user.dart';
import 'package:demo_app/utils/constants.dart';
import 'package:demo_app/utils/db_helper.dart';
import 'package:demo_app/utils/methods.dart';
import 'package:demo_app/views/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResetPasswordScreen extends StatefulWidget {

  String email;

  ResetPasswordScreen({this.email});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  bool is_loading = false;
  bool password_visible = false;
  bool confirm_password_visible = false;
  TextEditingController password_controller = new TextEditingController();
  TextEditingController confirm_password_controller = new TextEditingController();

  final form_key = GlobalKey<FormState>();
  var db_helper = DbHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Container(
              alignment: Alignment.centerLeft,
              width: MediaQuery.of(context).size.width,
              child: Text("Create new password")
          )
      ),
      resizeToAvoidBottomInset: false,
      body: is_loading ? loadingPage() : mainPage(),
    );
  }

  Widget mainPage(){
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Form(
          key: form_key,
          child: Column(
            children: [
              TextFormField(
                validator: (val){
                  return val.length > 6 ? null : "Password must contain at least six characters";
                },
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'sono-regular'
                ),
                controller: password_controller,
                obscureText: !password_visible,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        password_visible ? Icons.visibility : Icons.visibility_off,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      onPressed: (){
                        setState(() {
                          password_visible = !password_visible;
                        });
                      },
                    ),
                    labelStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontFamily: 'sono-regular'
                    ),
                    labelText: "Password",
                    border: const OutlineInputBorder()
                ),
              ),
              Container(height: 10,),
              TextFormField(
                validator: (val){
                  if(val != password_controller.text){
                    return "Passwords don't match";
                  }
                  else{
                    return null;
                  }
                },
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'sono-regular'
                ),
                controller: confirm_password_controller,
                obscureText: !confirm_password_visible,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        confirm_password_visible ? Icons.visibility : Icons.visibility_off,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      onPressed: (){
                        setState(() {
                          confirm_password_visible = !confirm_password_visible;
                        });
                      },
                    ),
                    labelStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontFamily: 'sono-regular'
                    ),
                    labelText: "Confirm password",
                    border: const OutlineInputBorder()
                ),
              ),
              Container(height: 8,),
              Center(
                  child: MaterialButton(
                    height: 50.0,
                    minWidth: 100.0,
                    color: Colors.white,
                    textColor: Colors.green,
                    onPressed: () => {
                      updatePassword(password_controller.text.toString())
                    },
                    splashColor: Theme.of(context).primaryColor,
                    child: const Text("Update password", style: TextStyle(fontSize: 14, fontFamily: 'aventa_regular'),),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updatePassword(String password) async {
    if(form_key.currentState.validate()){
      bool is_connected = await checkConnection();
      if(is_connected){
        setState(() {
          is_loading = true;
        });
        User user = await db_helper.getUserByEmail(widget.email);
        final params = {
          "password": "$password",
          "email": "${widget.email}"
        };
        var url = Uri.parse("${Constants.server_url}${Constants.api_url}/_updatePassword.php");
        var response = await http.post(url,body: params);
        if(response.statusCode == 200){
          if(response.body == "success"){
            showToast("Password changed");
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                SignIn()), (Route<dynamic> route) => false);
          }
          else{
            setState(() {
              is_loading = false;
            });
            print("reset_password.updatePassword error: ${response.body}");
            showToast("An error occurred");
          }
        }
        else{
          setState(() {
            is_loading = false;
          });
          showToast("Unable to reset password");
        }
      }
      else{
        showToast("No internet connection");
      }
    }
  }
}