import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pg/profileScreen.dart';
import './list.dart';
// import 'package:wadina_app/guestScreen/avalibleCompanies.dart';
// import 'package:wadina_app/guestScreen/companyContract.dart';
// import 'package:wadina_app/guestScreen/companyPage.dart';
// import 'package:wadina_app/guestScreen/current_location.dart';
// import 'package:wadina_app/guestScreen/resetPassword.dart';
// import 'package:wadina_app/guestScreen/schadule.dart';
// import 'package:wadina_app/guestScreen/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

//import '../model/flutterfire.dart';

class Login extends StatefulWidget {
  const Login(
      {Key? key,
      required this.firestore,
      required this.firebaseAuth,
      required this.firebaseStorage})
      : super(key: key);

  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final FirebaseStorage firebaseStorage;

  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<Login> {
  //-------------------------------------------------------------------------
  TextEditingController _passwordField = TextEditingController();
  TextEditingController _emailField = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _formkey = GlobalKey<FormState>();
  //-------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    _passwordField.text = "123456";
    // _passwordField.text = "87654321";
    _emailField.text = "fares1@gmail.com";

    return Scaffold(
      backgroundColor: Color.fromRGBO(97, 120, 232, 1),
      body: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 350,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                            // onTap: () {
                            //   Navigator.pushReplacement(
                            //       context,
                            //       MaterialPageRoute(
                            //           builder: (context) =>
                            //               avalibleCompanies()));
                            // },
                            child: Icon(
                              Icons.arrow_back,
                              size: 30,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 85),
                            child: Text(
                              "Welcome!",
                              style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Please sign in to continue",
                        style: TextStyle(
                          fontSize: 19,
                        ),
                      ),
                      SizedBox(height: 40),
                      Image.asset('assets/logo.png'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 50, right: 50),
                        child: TextFormField(
                          autofocus: false,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return ("Please Enter Your Email");
                            }
                            //reg exp

                            if (!RegExp(
                                    "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                .hasMatch(value)) {
                              return ("Please Enter valid Email");
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _emailField.text = value!;
                          },
                          textInputAction: TextInputAction.next,
                          controller: _emailField,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.white70,
                            ),
                            labelText: ' Enter your email',
                            labelStyle: TextStyle(
                                color: Colors.white70,
                                fontFamily: 'Microsoft_PhagsPa'),
                            enabledBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Colors.white70,
                                width: 3.0,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 3.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // ---------------------------------------------------------------
                      // Password Text Field

                      Padding(
                        padding: const EdgeInsets.only(left: 50, right: 50),
                        child: TextFormField(
                          obscureText: true,
                          autofocus: false,
                          validator: (value) {
                            RegExp regex = new RegExp(r'^.{6,}$');

                            if (value!.isEmpty) {
                              return ("please Enter Your Password");
                            }

                            if (!regex.hasMatch(value)) {
                              return ("please Enter Valid Password for Min 6 charecter");
                            }
                          },
                          controller: _passwordField,
                          onSaved: (value) {
                            _passwordField.text = value!;
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.white70,
                            ),
                            labelText: ' Enter your password',
                            labelStyle: TextStyle(
                                color: Colors.white70,
                                fontFamily: 'Micrrdosoft_PhagsPa'),
                            enabledBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(
                                color: Colors.white70,
                                width: 3.0,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 3.0,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 40),
                      // -----------------------------------------------------
                      // Button

                      ElevatedButton(
                        onPressed: () async {
                          // print(_emailField.text);
                          // print(_passwordField.text);
                          // bool shouldnavigate =
                          //     await logIn(_emailField.text, _passwordField.text);

                          // if (shouldnavigate) {
                          //   Navigator.pushReplacement(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) => CompanyContact(0)));
                          // }

                          login(_emailField.text, _passwordField.text);
                        },
                        child: const Text(
                          'Get Started',
                          style: TextStyle(letterSpacing: 2),
                        ),
                        style: ElevatedButton.styleFrom(
                            primary: Color.fromRGBO(243, 214, 35, 1),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 80, vertical: 15),
                            textStyle: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50))),
                      ),
                      SizedBox(height: 30),
                      // Text
                      InkWell(
                        // onTap: () {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => ResetPassword()),
                        //   );
                        // },
                        child: Container(
                          alignment: Alignment.center,
                          child: Text.rich(
                            TextSpan(
                              text: 'Forget password? ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontFamily: 'Microsoft_PhagsPa',
                                  fontWeight: FontWeight.bold),
                              children: const <TextSpan>[
                                TextSpan(
                                    text: ' Reset password',
                                    style: TextStyle(
                                        color: Color.fromRGBO(114, 206, 243, 1),
                                        fontSize: 18,
                                        fontFamily: 'Microsoft_PhagsPa',
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      InkWell(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => Signup()),
                            // );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Text.rich(
                              TextSpan(
                                text: 'Dont have an account yet? ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontFamily: 'Microsoft_PhagsPa',
                                    fontWeight: FontWeight.bold),
                                children: const <TextSpan>[
                                  TextSpan(
                                      text: ' sign up',
                                      style: TextStyle(
                                          color:
                                              Color.fromRGBO(114, 206, 243, 1),
                                          fontSize: 18,
                                          fontFamily: 'Microsoft_PhagsPa',
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void login(String email, String password) async {
    print("inside method");
    if (_formkey.currentState!.validate()) {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) => {
                print("Login done"),
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => listWidget(
                        firestore: widget.firestore,
                        firebaseAuth: widget.firebaseAuth,
                        firebaseStorage: widget.firebaseStorage)))
              })
          .catchError((e) {
        print("Error");
      });
    }
  }
}
