import 'dart:math';
import 'package:demo_app/models/user.dart';
import 'package:demo_app/utils/constants.dart';
import 'package:demo_app/utils/db_helper.dart';
import 'package:demo_app/utils/methods.dart';
import 'package:demo_app/views/reset_password.dart';
import 'package:demo_app/views/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ForgotPassword extends StatefulWidget {

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  TextEditingController email_controller = new TextEditingController();
  TextEditingController pin_controller = new TextEditingController();

  bool from_last_state = false;
  bool is_loading = false;
  bool is_input_pin = false;
  String pin = "";
  var db_helper = new DbHelper();
  final form_key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if(from_last_state){
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            leading:GestureDetector(
                onTap: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignIn()));
                },
                child: const Icon(Icons.arrow_back)
            ),
            title: Container(
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width,
                child: const Text("Recover account")
            )
        ),
        resizeToAvoidBottomInset: false,
        body: is_loading ? loadingPage() : mainPage(),
      );
    }
    else{
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Container(
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width,
                child: const Text("Recover account")
            )
        ),
        resizeToAvoidBottomInset: false,
        body: is_loading ? loadingPage() : mainPage(),
      );
    }
  }

  Widget enterPin(){
    return SingleChildScrollView(
      child: Form(
        key: form_key,
        child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
                child: Column(
                  children: [
                    TextFormField(
                      validator: (v){
                        return isVerifyPin(pin_controller.text.toString()) ? null : "Incorrect pin";
                      },
                      maxLength: 4,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'sono-regular'
                      ),
                      keyboardType: TextInputType.number,
                      controller: pin_controller,
                      decoration: const InputDecoration(
                          labelStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontFamily: 'sono-regular'
                          ),
                          labelText: "Enter pin",
                          border: OutlineInputBorder()
                      ),
                    ),
                    Container(
                        height: 30
                    ),
                    MaterialButton(
                      height: 50.0,
                      minWidth: 150.0,
                      color: Colors.white,
                      textColor: Colors.green,
                      onPressed: () => {
                        if(form_key.currentState.validate()){
                          if(isVerifyPin(pin)){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordScreen(email:email_controller.text)))
                          }
                          // if(isVerifyPin(pin_controller.text.toString())){
                          //   Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordScreen(email:email_controller.text.toString())))
                          // }
                        }
                      },
                      splashColor: Theme.of(context).primaryColor,
                      child:  const Text("Verify pin", style: TextStyle(fontSize: 16, fontFamily: 'aventa_regular'),),
                    ),
                  ],
                )
            )
        ),
      ),
    );
  }

  Widget mainPage() {
    return is_input_pin ?
    enterPin() :
    SingleChildScrollView(
      child: Form(
        key: form_key,
        child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                const Text(
                  "Enter your registered email and we will send a pin. Kindly be patient as it takes some time for servers to respond and send the pin. ",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'sono-regular'
                  ),
                ),
                Container(
                  height: 80,
                ),
                TextFormField(
                  validator: (v){
                    return isValidEmail(email_controller.text.toString()) ? null : "Invalid email";
                  },
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'sono-regular'
                  ),
                  controller: email_controller,
                  decoration: const InputDecoration(
                      labelStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: 'sono-regular'
                      ),
                      labelText: "Email",
                      border: OutlineInputBorder()
                  ),
                ),
                Container(
                    height: 30
                ),
                MaterialButton(
                  height: 50.0,
                  minWidth: 150.0,
                  color: Colors.white,
                  textColor: Colors.green,
                  onPressed: () => {
                    searchEmail(email_controller.text.toString())
                  },
                  splashColor: Theme.of(context).primaryColor,
                  child: const Text("Send pin", style: TextStyle(fontSize: 16, fontFamily: 'aventa_regular'),),
                ),
              ],
            )
        ),
      ),
    );
  }

  Future<void> searchEmail(String email) async{
    if(form_key.currentState.validate()){
      bool is_connected = await checkConnection();
      if(is_connected){
        setState(() {
          is_loading = true;
        });
        User user = await db_helper.getUserByEmail(email);
        if(user == null){
          setState(() {
            is_loading = false;
          });
          showToast("User not found");
        }
        else{
          sendPinToEmail(email_controller.text.toString());
        }
      }
      else{
        setState(() {
          is_loading = false;
        });
        showToast("No internet connection");
      }
    }

  }

  bool isVerifyPin(String _pin){
    if(pin.length < 4)
      return false;
    else if(_pin != pin){
      return false;
    }
    else if(_pin == pin){
      return true;
    }
    return false;
  }

  @override
  initState(){
    super.initState();
  }

  void sendPinToEmail(String email) async{
    pin = generatePin();
    String message = "Use $pin for resetting your password. The pin expires after 5 minutes. Disregard this email if you did not request to reset your password";
    Map<String, String> params = {"pin": message, "email": email};
    var uri = Uri.https(Constants.server_get_url, "${Constants.api_url}/sendPinToEmail.php", params);
    await http.get(uri, headers: null).then((value){
      Response response = value;
      if(response.statusCode == 200){
        showToast("A 4 digit pin has been sent to your email");
        int time = DateTime.now().millisecondsSinceEpoch;

        setState(() {
          is_input_pin = true;
          is_loading = false;
        });
      }
      else{
        showToast("An error occurred");
        setState(() {
          is_loading = false;
        });
      }
    });
  }

  String generatePin(){
    final _random = Random();
    String pin = "";
    for(int i=0; i<4; i++){
      int next(int min, int max) => min + _random.nextInt(max-min);
      pin += next(1,9).toString();
    }
    return pin;
  }

}