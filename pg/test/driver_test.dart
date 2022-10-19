import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pg/list.dart';
import 'package:pg/company.dart';

void main() async {
  // Used to get rid of the 400 error (because of NetworkImage)
  setUpAll(() => HttpOverrides.global = null);

  final firestore = FakeFirebaseFirestore();

  Company mockCompany = Company.fromMap({
    'CompanyID': '123456789',
    'address': 'Alnassem',
    'contract': 'contract',
    'description': 'description',
    'email': 'wosol@gmail.com',
    'imageURL': 'http://example.com/bus.jpg',
    'name': 'wosol',
    'phoneNumber': '0555555555',
    'price': '123.4',
    'rate': '5',
    'registerStatus': false,
  });

  await firestore
      .collection('company')
      .doc(mockCompany.CompanyID)
      .set(mockCompany.toMap());

  await firestore.collection('driver').doc('123456788').set({
    'NationalidIqama': '1231231239',
    'busNumber': '12',
    'companyID': '123456789',
    'destination': '118 high school',
    'email': 'f@gmail.com',
    'id': '123456788',
    'image': 'http://example.com/driver.jpg',
    'name': 'Fahad Ali',
    'neighbrhoods': 'Alfihaa',
    'password': '123123',
    'phoneNumber': '0551234125',
    'shift': '12',
  });

  await firestore
      .collection('company')
      .doc(mockCompany.CompanyID)
      .collection('customer')
      .doc('123456787')
      .set({
    'companyID': '123456789',
    'Name': 'zehar',
    'customerid': '123456787',
    'driverDropoff': '123456788',
    'driverPickup': '123456788',
    'email': 'am@gmail.com',
    'latitude': '37.421998333333335',
    'longitude': '-122.084',
    'neighbrhoods': 'Alfihaa',
    'paymentMethod': 'creditCard',
    'phoneNumber': '0551234155',
    'schoolName': '24 primary school',
  });

  await firestore
      .collection('company')
      .doc(mockCompany.CompanyID)
      .collection('customer')
      .doc('123456687')
      .set({
    'companyID': '123456789',
    'Name': 'sara',
    'customerid': '123456687',
    'driverDropoff': '123456777',
    'driverPickup': '123456777',
    'email': 'am@gmail.com',
    'latitude': '37.421998333333335',
    'longitude': '-122.084',
    'neighbrhoods': 'Alfihaa',
    'paymentMethod': 'creditCard',
    'phoneNumber': '0551234155',
    'schoolName': '24 primary school',
  });

  await firestore
      .collection('schadule')
      .doc('123456787')
      .collection('days')
      .doc('1Sunday')
      .set({
    'Day': '1Sunday',
    'active': 'true',
    'dropoff': '12',
    'pickup': '8',
  });

  await firestore
      .collection('schadule')
      .doc('123456787')
      .collection('days')
      .doc('2Monday')
      .set({
    'Day': '2Monday',
    'active': 'true',
    'dropoff': '12',
    'pickup': '8',
  });

  await firestore
      .collection('schadule')
      .doc('123456787')
      .collection('days')
      .doc('3Tuesday')
      .set({
    'Day': '3Tuesday',
    'active': 'true',
    'dropoff': '12',
    'pickup': '8',
  });

  await firestore
      .collection('schadule')
      .doc('123456787')
      .collection('days')
      .doc('4Wednesday')
      .set({
    'Day': '4Wednesday',
    'active': 'true',
    'dropoff': '12',
    'pickup': '8',
  });

  await firestore
      .collection('schadule')
      .doc('123456787')
      .collection('days')
      .doc('5Thursday')
      .set({
    'Day': '5Thursday',
    'active': 'true',
    'dropoff': '12',
    'pickup': '8',
  });

  final Driver = MockUser(
    isAnonymous: false,
    uid: '123456788',
    email: 'f@gmail.com',
    displayName: 'Fahad Ali',
  );

  final firebaseStorage = MockFirebaseStorage();

  final firebaseAuth = MockFirebaseAuth(signedIn: true, mockUser: Driver);

//==================================================================================

  testWidgets('Load driver customer list ', (WidgetTester tester) async {
    Widget testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(
            home: listWidget(
                firestore: firestore,
                firebaseAuth: firebaseAuth,
                firebaseStorage: firebaseStorage)));
    await tester.pumpWidget(testWidget);

    await tester.pump(new Duration(seconds: 1));

    expect(find.text("zehar"), findsOneWidget);
    expect(find.text("sara"), findsNothing);
  });

  testWidgets('Test driver list search', (WidgetTester tester) async {
    Widget testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(
            home: listWidget(
                firestore: firestore,
                firebaseAuth: firebaseAuth,
                firebaseStorage: firebaseStorage)));
    await tester.pumpWidget(testWidget);

    await tester.pump(new Duration(seconds: 1));

    expect(find.text("zehar"), findsWidgets);
    // Type in search sara
    await tester.enterText(find.byKey(const ValueKey('searchFiled')), 'sara');
    // check of zehar exist or not (not supposed to exist)
    await tester.pump(new Duration(seconds: 1));
    expect(find.text("zehar"), findsNothing);
  });

  testWidgets('Not a driver', (WidgetTester tester) async {
    final Driver = MockUser(
      isAnonymous: false,
      uid: 'someuid',
      email: 'imnotanadriver@gmail.com',
      displayName: 'fake driver',
    );
    final firebaseAuth = MockFirebaseAuth(signedIn: true, mockUser: Driver);

    Widget testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(
            home: listWidget(
                firestore: firestore,
                firebaseAuth: firebaseAuth,
                firebaseStorage: firebaseStorage)));
    await tester.pumpWidget(testWidget);

    await tester.pump(new Duration(seconds: 1));

    expect(
        find.text("You are not a driver, no records found!"), findsOneWidget);
  });
}
