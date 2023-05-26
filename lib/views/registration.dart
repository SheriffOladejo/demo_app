import 'dart:io';
import 'package:demo_app/models/user.dart';
import 'package:demo_app/utils/db_helper.dart';
import 'package:demo_app/utils/hex_color.dart';
import 'package:demo_app/utils/methods.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {

  final db_helper = DbHelper();

  // These variables allow you to control the text entered in the fields
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var usernameController = TextEditingController();

  // These variables control when the eye icon is pressed
  bool is_password_visible = false;
  bool is_password_focus = false;
  bool is_confirm_password_visible = false;
  bool is_confirm_password_focus = false;

  // This variable acts a watcher for correct input
  // It is used to wrap all the form-fields
  final form_key = GlobalKey<FormState>();

  // Variable to show or dismiss loading bar
  bool is_loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back, color: Colors.black,),
        ),
        centerTitle: true,
        title: const Text("App name", style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'sono-bold'),),
      ),
      backgroundColor: Colors.white,
      body: is_loading ? loadingPage() : SingleChildScrollView(
        child: Form(
          key: form_key,
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(height: 15,),
                TextFormField(
                  validator: (val) {
                    if (firstNameController.text.isEmpty) {
                      return "Required";
                    }
                    return null;
                  },
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  controller: firstNameController,
                  decoration: InputDecoration(
                    hintText: "First name",
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'sono-regular'),
                    focusedBorder: focusedBorder(),
                    errorBorder: errorBorder(),
                    enabledBorder: enabledBorder(),
                    disabledBorder: disabledBorder(),
                  ),
                ),
                Container(height: 10,),
                TextFormField(
                  validator: (val) {
                    if (lastNameController.text.isEmpty) {
                      return "Required";
                    }
                    return null;
                  },
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  controller: lastNameController,
                  decoration: InputDecoration(
                    hintText: "Last name",
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    focusedBorder: focusedBorder(),
                    errorBorder: errorBorder(),
                    enabledBorder: enabledBorder(),
                    disabledBorder: disabledBorder(),
                  ),
                ),
                Container(height: 10,),
                TextFormField(
                  validator: (val) {
                    if (usernameController.text.isEmpty) {
                      return "Required";
                    }
                    else if (!isValidEmail(usernameController.text)) {
                      return "Invalid email";
                    }
                    return null;
                  },
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    focusedBorder: focusedBorder(),
                    errorBorder: errorBorder(),
                    enabledBorder: enabledBorder(),
                    disabledBorder: disabledBorder(),
                  ),
                ),
                Container(height: 10,),
                FocusScope(
                  child: Focus(
                    onFocusChange: (focus) {
                      setState(() {
                        is_password_focus = !is_password_focus;
                      });
                    },
                    child: TextFormField(
                      validator: (val){
                        if(val != null){
                          if(val.toString().isEmpty) {
                            return "Required";
                          }
                          return null;
                        }
                        return null;
                      },
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'sono-regular'
                      ),
                      controller: passwordController,
                      enableSuggestions: false,
                      autocorrect: false,
                      obscureText: !is_password_visible,
                      decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'sono-regular'),
                          suffixIcon: IconButton(
                            icon: Icon(
                              is_password_visible ? Icons.visibility : Icons.visibility_off,
                              color: is_password_focus ? Theme.of(context).primaryColorDark : Colors.grey,
                            ),
                            onPressed: (){
                              setState(() {
                                is_password_visible = !is_password_visible;
                              });
                            },
                          ),
                          focusedBorder: focusedBorder(),
                          enabledBorder: enabledBorder(),
                          errorBorder: errorBorder()
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 10,
                ),
                FocusScope(
                  child: Focus(
                    onFocusChange: (focus) {
                      setState(() {
                        is_confirm_password_focus = !is_confirm_password_focus;
                      });
                    },
                    child: TextFormField(
                      validator: (val){
                        if(val != null){
                          if(val.toString().isEmpty) {
                            return "Required";
                          }
                          else if (val.toString() != passwordController.text.toString()) {
                            return "Passwords don't match";
                          }
                          return null;
                        }
                        return null;
                      },
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      controller: confirmPasswordController,
                      enableSuggestions: false,
                      autocorrect: false,
                      obscureText: !is_confirm_password_visible,
                      decoration: InputDecoration(
                          hintText: "Confirm password",
                          hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'sono-regular'),
                          suffixIcon: IconButton(
                            icon: Icon(
                              is_confirm_password_visible ? Icons.visibility : Icons.visibility_off,
                              color: is_confirm_password_focus ? Theme.of(context).primaryColorDark :
                              Colors.grey,
                            ),
                            onPressed: (){
                              setState(() {
                                is_confirm_password_visible = !is_confirm_password_visible;
                              });
                            },
                          ),
                          focusedBorder: focusedBorder(),
                          enabledBorder: enabledBorder(),
                          errorBorder: errorBorder()
                      ),
                    ),
                  ),
                ),
                Container(height: 200,),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                  child: MaterialButton(
                    onPressed: () async {
                      if (form_key.currentState.validate()) {
                        await register();
                      }
                    },
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                    color: HexColor("#FF66C4"),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Sign up",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'sono-bold'
                          ),
                        ),
                        Container(width: 5,),
                        Image.asset("assets/images/tick-circle.png", width: 20, height: 20, color: Colors.white,),
                      ],
                    ),
                  ),
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Before using this app, you can review our",
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'sono-regular',
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                var url = "";
                                if(await canLaunch(url)){
                                  await launch(url);
                                }
                                else{
                                  showToast("Cannot launch URL");
                                }
                              },
                              child: const Text(
                                "privacy policy ",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'sono-regular',
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const Text(
                              "and ",
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'sono-regular',
                                color: Colors.black,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                var url = "";
                                if(await canLaunch(url)){
                                  await launch(url);
                                }
                                else{
                                  showToast("Cannot launch URL");
                                }
                              },
                              child: const Text(
                                "terms of use. ",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'sono-regular',
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String> getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id; // unique ID on Android
    }
  }

  Future<void> register() async {
    bool isConnected = await checkConnection();
    if (isConnected) {
      // This will check the input fields for errors
      // using the validators in the text fields
      if (form_key.currentState.validate()) {
        setState(() {
          is_loading = true;
        });

        var firstname = firstNameController.text.trim();
        var lastname = lastNameController.text.trim();
        var username = usernameController.text.trim();
        var password = passwordController.text;
        var device_id = await getDeviceId();

        bool usernameExist = await db_helper.isUsernameExist(username);
        bool deviceIdExist = await db_helper.isDeviceIDExist(device_id);

        if (usernameExist) {
          showToast("This username is taken by another user");
          setState(() {
            is_loading = false;
          });
        }
        else if (deviceIdExist) {
          showToast("Cannot register device");
          setState(() {
            is_loading = false;
          });
        }
        else {
          String deviceAccess = "true";
          var user = User(
            username: username,
            password: password,
            device_access: deviceAccess,
            deviceId: device_id
          );

          await uploadUser(user);
        }
      }
    }
  }

  Future<void> uploadUser(User user) async {
    bool result = await db_helper.uploadUser(user);
    if (result) {
      setState(() {
        is_loading = false;
      });
      showToast("Registration successful");
      Navigator.pop(context);
    }
    else {
      setState(() {
        is_loading = false;
      });
      showToast("Could not sign up");
    }
  }

}
