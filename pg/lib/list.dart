import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'Customer.dart';
import 'package:pg/login.dart';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';

class listWidget extends StatefulWidget {
  const listWidget(
      {Key? key,
      required this.firestore,
      required this.firebaseAuth,
      required this.firebaseStorage})
      : super(key: key);

  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final FirebaseStorage firebaseStorage;
  @override
  _listWidgetState createState() => _listWidgetState();
}

class _listWidgetState extends State<listWidget> {
  static List<Customer> customersList = [];
  static List<Customer> customersListSearch = [];

  static var searchWord = "";
  var shift = "";
  @override
  void initState() {
    super.initState();
    getCustomers();
  }

  Future<void> getCustomers() async {
    User? user = widget.firebaseAuth.currentUser;

    String currentDay = DateFormat('EEEE').format(DateTime.now());
    int currentDayNumber = DateTime.now().weekday;
    if (currentDayNumber == 7) {
      currentDayNumber = 1;
    } else {
      currentDayNumber++;
    }
    widget.firestore
        .collection("driver")
        .doc(user!.uid)
        .get()
        .then((value) async {
      if (value.data() == null) {
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
            content: Text("You are not a driver, no records found!"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  widget.firebaseAuth.signOut();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => Login(
                          firestore: widget.firestore,
                          firebaseAuth: widget.firebaseAuth,
                          firebaseStorage: widget.firebaseStorage)));
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        shift = "Your shift is: " + value.data()!['shift'];
        setState(() {});
        await for (var customers in widget.firestore
            .collection('company')
            .doc(value.data()!['companyID'])
            .collection('customer')
            .snapshots()) {
          for (var customer in customers.docs.toList()) {
            Customer currentCustomer = Customer.fromMap(customer.data());
            //
            if (currentCustomer.pickupDriver == user.uid ||
                currentCustomer.dropoffDriver == user.uid) {
              widget.firestore
                  .collection('schadule')
                  .doc(currentCustomer.customerid)
                  .collection('days')
                  .doc(currentDayNumber.toString() + "" + currentDay)
                  .get()
                  .then((value) {
                if (value.data() != null) {
                  currentCustomer.dropOff = value.data()!['dropoff'];
                  currentCustomer.pickUp = value.data()!['pickup'];
                  setState(() {
                    customersList.add(currentCustomer);
                    customersListSearch.add(currentCustomer);
                  });
                }
              });
            }
          }
        }
      }
    });
    return;
  }

  launchMap(String lat, String long) async {
    String mapSchema =
        'https://www.google.com/maps/search/?api=1&query=$lat,$long';
    if (!await launch(mapSchema)) throw 'Could not launch $mapSchema';
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.green;
  }

  var _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF536DFE),
          bottomOpacity: 0.0,
          elevation: 0.0,
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    onTap: () async {
                      customersList = [];
                      customersListSearch = [];
                      await widget.firebaseAuth.signOut();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => Login(
                              firestore: widget.firestore,
                              firebaseAuth: widget.firebaseAuth,
                              firebaseStorage: widget.firebaseStorage)));
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
                    ),
                  )
                ];
              },
            ),
          ],
        ),
        backgroundColor: Color(0xFF536DFE),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: Text(
                  'Today\'s rides',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: Text(
                  shift.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 13),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 40),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(24.0),
                    ),
                  ),
                  child: TextField(
                    key: const ValueKey('searchFiled'),
                    controller: _controller,
                    onChanged: (value) {
                      setState(() {
                        searchWord = value;
                        customersListSearch = customersList
                            .toList()
                            .where((s) => s.Name.toString()
                                .toLowerCase()
                                .contains(searchWord.toLowerCase()))
                            .toList();
                      });
                    },
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            setState(() {
                              searchWord = "";
                              customersListSearch = customersList
                                  .toList()
                                  .where((s) => s.Name.toString()
                                      .toLowerCase()
                                      .contains(searchWord.toLowerCase()))
                                  .toList();
                            });
                          },
                        ),
                        hintText: 'Search...',
                        border: InputBorder.none),
                  ),
                ),
              ),
              Expanded(
                  child: RefreshIndicator(
                onRefresh: () async {
                  customersList = [];
                  customersListSearch = [];
                  await getCustomers();
                  return Future.value();
                },
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: customersListSearch.length,
                    itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                                backgroundColor: Colors.white),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: ExpansionTile(
                                backgroundColor: Colors.white,
                                title: Row(children: [
                                  Checkbox(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    checkColor: Colors.white,
                                    fillColor:
                                        MaterialStateProperty.resolveWith(
                                            getColor),
                                    value: customersListSearch[index].isDone,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        customersListSearch[index].isDone =
                                            value;
                                      });
                                    },
                                  ),
                                  Text(customersListSearch[index]
                                      .Name
                                      .toString()),
                                ]),
                                children: [
                                  Row(
                                    children: [
                                      Column(children: [
                                        Row(children: [
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                26, 5, 10, 5),
                                            child: Icon(
                                              Icons.departure_board,
                                              color: Colors.blue,
                                              size: 30.0,
                                            ),
                                          ),
                                        ]),
                                      ]),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text("Pick-up time: ",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(customersListSearch[index]
                                                  .pickUp
                                                  .toString())
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text("Drop-Off time: ",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(customersListSearch[index]
                                                  .dropOff
                                                  .toString())
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(26, 5, 10, 5),
                                        child: Icon(
                                          Icons.location_city,
                                          color: Colors.blue,
                                          size: 30.0,
                                        ),
                                      ),
                                      Text("Destination: ",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(customersListSearch[index]
                                          .schoolName
                                          .toString())
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(26, 5, 10, 5),
                                        child: Icon(
                                          Icons.phone,
                                          color: Colors.blue,
                                          size: 30.0,
                                        ),
                                      ),
                                      Text("Phone number: ",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(customersListSearch[index]
                                          .phoneNumber
                                          .toString())
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () => launchMap(
                                            customersListSearch[index]
                                                .Latitude
                                                .toString(),
                                            customersListSearch[index]
                                                .longitude
                                                .toString()),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              color: Colors.blue,
                                              size: 30.0,
                                            ),
                                            Text("Open Location",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
              ))
            ],
          ),
        ));
  }
}
