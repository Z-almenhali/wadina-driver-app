import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pg/company.dart';
import 'package:pg/login.dart';
import './editProfile.dart';
import 'package:firebase_storage/firebase_storage.dart';

class profileScreen extends StatefulWidget {
  const profileScreen({Key? key, required this.firestore, required this.firebaseAuth,
      required this.firebaseStorage}) : super(key: key);

  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final FirebaseStorage firebaseStorage;

  @override
  State<profileScreen> createState() => _profileScreenState();
}

@override
class _profileScreenState extends State<profileScreen> {
//=========================================================================

  Company currentCompany = Company();
  var isLoaded = false;
  @override
  void initState() {
    super.initState();
    User? user = widget.firebaseAuth.currentUser;

    widget.firestore
        .collection('company')
        .where("email", isEqualTo: user!.email)
        .get()
        .then((value) {
      if (value.docs.length == 0) {
        showDialog<String>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(35.0))),
            title: Text('Error',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                )),
            content: Text("You are not an admin, no company found!"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  widget.firebaseAuth.signOut();
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => Login(firestore: widget.firestore, firebaseAuth: widget.firebaseAuth, firebaseStorage: widget.firebaseStorage)));
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        this.currentCompany = Company.fromMap(value.docs.first.data());
        setState(() {
          isLoaded = true;
        });
      }
    });
  }

  Widget build(BuildContext context) {
    if (isLoaded) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF536DFE),
          title: const Text("Profile"),
          actions: <Widget>[
            PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                      onTap: () async {
                        Future(
                          () {
                            Navigator.of(context)
                                .push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    editProfile(currentCompany: currentCompany, firebaseAuth: widget.firebaseAuth, firebaseStorage: widget.firebaseStorage, firestore: widget.firestore),
                              ),
                            )
                                .then((_) {
                              setState(() {});
                            });
                          },
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.black,
                            size: 20.0,
                          ),
                          Text(' Edit Profile'),
                        ],
                      )),
                  PopupMenuItem(
                      onTap: () async {
                        await widget.firebaseAuth.signOut();
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => Login(firestore: widget.firestore, firebaseAuth: widget.firebaseAuth, firebaseStorage: widget.firebaseStorage)));
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.red,
                            size: 20.0,
                          ),
                          Text(
                            ' Log out',
                            style: TextStyle(color: Colors.red),
                          )
                        ],
                      ))
                ];
              },
            )
          ],
        ),
        body: Column(children: [
          Container(
            width: MediaQuery.of(context).size.width,
            color: Color(0xFF536DFE),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 140,
                      width: 140,
                      child: Stack(
                        fit: StackFit.expand,
                        clipBehavior: Clip.none,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  currentCompany.imageURL.toString()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 20, 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(currentCompany.name.toString() + " Company",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                    color: Colors.black))
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                  size: 25,
                                ),
                                Text("${currentCompany.rate}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    )),
                                SizedBox(
                                  width: 100,
                                ),
                                Icon(
                                  Icons.location_on,
                                  size: 25,
                                  color: Colors.white,
                                ),
                                Text("${currentCompany.address}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.price_change,
                              size: 25,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "SR" + "${currentCompany.price}" + "/month",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                            child: Text("Registering status:",
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          ),
                          SizedBox(
                            height: 30,
                            child: Switch(
                              activeColor: Colors.green,
                              value: currentCompany.registerStatus!,
                              onChanged: (value) {
                                setState(() {
                                  currentCompany.registerStatus = value;
                                });
                                widget.firestore
                                    .collection('company')
                                    .doc(currentCompany.CompanyID)
                                    .update(currentCompany.toMap());
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TextButton(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 5, 30, 5),
                        child: Icon(
                          Icons.home,
                          color: Colors.blue,
                          size: 45.0,
                        ),
                      ),
                      Text('Home',
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ],
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white24,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TextButton(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 5, 30, 5),
                        child: Icon(
                          Icons.people_alt_outlined,
                          color: Colors.blue,
                          size: 45.0,
                        ),
                      ),
                      Text('Drivers',
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ],
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white24,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TextButton(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 5, 30, 5),
                        child: Icon(
                          Icons.directions_bus,
                          color: Colors.blue,
                          size: 45.0,
                        ),
                      ),
                      Text('Bueses',
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ],
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white24,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TextButton(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 5, 30, 5),
                        child: Icon(
                          Icons.people,
                          color: Colors.blue,
                          size: 45.0,
                        ),
                      ),
                      Text('Customers',
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ],
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white24,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ]),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF536DFE),
          title: const Text("Profile"),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          ],
        ),
      );
    }
  }
}
