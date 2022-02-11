import 'package:applore/screens/homescreen.dart';
import 'package:applore/screens/signupscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  //hide and show password
  bool _obscureText = true;
  //boolean for google and facebook login
  bool _isLoggedIn = false;
  // google LogIn
  GoogleSignInAccount? _signInAccount;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  //Map for facebook login
  Map _userObj = {};
  //form key
  final _formKey = GlobalKey<FormState>();

  // editing controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  //firebase
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log In'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email'),
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return ("Please enter your email id");
                        }
                        //regression expression
                        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                            .hasMatch(value)) {
                          return ("Please enter valid email id");
                        }
                      },
                      onSaved: (value) {
                        emailController.text = value!;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Password',
                        suffixIcon: GestureDetector(
                          onTap: (){
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                        )
                      ),
                      obscureText: _obscureText,
                      controller: passwordController,
                      validator: (value) {
                        RegExp regex = RegExp(r'^.{6,}$');
                        if (value!.isEmpty) {
                          return ("Please enter your password");
                        }
                        if (!regex.hasMatch(value)) {
                          return ("Please enter password of 6 characters");
                        }
                      },
                      onSaved: (value) {
                        passwordController.text = value!;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        signIn(emailController.text, passwordController.text);
                      },
                      child: Container(
                        height: 50,
                        width: 100,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(30)),
                        child: const Center(
                            child: Text(
                          'LogIn with email',
                          style: TextStyle(color: Colors.white),
                        )),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: _isLoggedIn ? HomeScreen() : ElevatedButton(onPressed: (){
                        _googleSignIn.signIn().then((userData){
                          setState(() {
                            _isLoggedIn = true;
                            _signInAccount = userData;
                          });
                        }).catchError((e){
                          print(e);
                        });
                      }, child:Text("SignIn with Google")),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: _isLoggedIn ? HomeScreen() : ElevatedButton(onPressed: (){
                        FacebookAuth.instance.login(
                          permissions: ["public_profile", "email"]
                        ).then((value){
                          FacebookAuth.instance.getUserData().then((userData){
                            setState(() {
                              _isLoggedIn= true;
                              _userObj = userData;
                            });
                          });
                        });
                      },child:Text("LogIn with facebook"),),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SignUp()));
                            },
                            child: const Text(
                              "SignUp",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ))
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  Future<void> signIn(String email, String password) async {
    if(_formKey.currentState!.validate()){
      await _auth.signInWithEmailAndPassword(email: email, password: password).then((uid) => {
        Fluttertoast.showToast(msg: "Login Successful"),
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const HomeScreen()))
      }).catchError((e){
        Fluttertoast.showToast(msg: e.message);
      });
    }
  }
}
