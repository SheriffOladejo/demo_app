import 'package:demo_app/utils/constants.dart';
import 'package:demo_app/utils/db_helper.dart';
import 'package:demo_app/utils/hex_color.dart';
import 'package:demo_app/utils/methods.dart';
import 'package:demo_app/views/forgot_password.dart';
import 'package:demo_app/views/home.dart';
import 'package:demo_app/views/registration.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  var usernameController = TextEditingController();
  var passwordController = TextEditingController();

  bool is_password_visible = false;
  bool is_password_focus = false;

  bool is_loading = false;

  final db_helper = DbHelper();

  final form_key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
                //Replace the "App name" below with your app name
                const Text(Constants.appName, style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'sono-bold'),),
                Container(height: 10,),
                SizedBox(
                  width: 150,
                  child: Image.asset("assets/images/anynameofyourimage.png"),
                ),
                Container(height: 15,),
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
                  cursorColor: Colors.black,
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
                      cursorColor: Colors.black,
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
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                  child: MaterialButton(
                    onPressed: () async {
                      if (form_key.currentState.validate()) {
                        await signIn();
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
                          "Sign in",
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
                Container(height: 8,),
                // GestureDetector(
                //   onTap: () {
                //     Navigator.push(context, slideLeft(ForgotPassword()));
                //   },
                //   child: const Text(
                //     " Forgot password? ",
                //     style: TextStyle(
                //         color: Colors.grey,
                //         fontFamily: 'sono-bold',
                //         fontSize: 16,
                //         decoration: TextDecoration.underline
                //     ),
                //   ),
                // ),
                Container(height: 200,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 1,
                      width: MediaQuery.of(context).size.width / 2 - 45,
                      color: Colors.blue,
                    ),
                    const Text("  OR  ", style: TextStyle(color: Colors.blue, fontSize: 18, fontFamily: 'sono-bold'),),
                    Container(
                      height: 1,
                      width: MediaQuery.of(context).size.width / 2 - 45,
                      color: Colors.blue,
                    ),
                  ],
                ),
                Container(height: 10,),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                  child: MaterialButton(
                    onPressed: () async {
                      if (mounted) {
                        Navigator.push(context, slideLeft(const RegistrationScreen()));
                      }
                    },
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                    color: HexColor("#FF66C4"),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Sign up",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'sono-bold'
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signIn() async {
    bool isConnected = await checkConnection();
    if (isConnected) {
      if (form_key.currentState.validate()) {
        setState(() {
          is_loading = true;
        });
        var username = usernameController.text.trim();
        var password = passwordController.text;
        var user = await db_helper.getUserOnline(username, password);
        if (user != null) {
          await db_helper.saveUser(user);
          setState(() {
            is_loading = false;
          });
          Navigator.pushAndRemoveUntil(context, slideLeft(const HomeScreen()), (route)=>false);
        }
        else {
          setState(() {
            is_loading = false;
          });
          showToast("Incorrect username or password");
        }
      }
    }
  }

  Future<void> init () async {
    setState(() {
      is_loading = true;
    });
    var user = await db_helper.getUser();
    if (user != null) {
      Navigator.pushReplacement(context, slideLeft(const HomeScreen()));
    }
    else {
      setState(() {
        is_loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

}
