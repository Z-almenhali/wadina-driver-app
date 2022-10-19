import 'dart:io';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pg/editProfile.dart';
import 'package:pg/company.dart';
import 'package:pg/profileScreen.dart';

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
  // Creating a mock user
  final user = MockUser(
    isAnonymous: false,
    uid: 'someuid',
    email: 'wosol@gmail.com',
    displayName: 'wosol',
  );
  // making the firebase auth with the mock user signed in
  final firebaseAuth = MockFirebaseAuth(signedIn: true, mockUser: user);

  final firebaseStorage = MockFirebaseStorage();

  // Load profile screen
  testWidgets('Load company profile', (WidgetTester tester) async {
    Widget testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(
            home: profileScreen(
                firestore: firestore,
                firebaseAuth: firebaseAuth,
                firebaseStorage: firebaseStorage)));
    await tester.pumpWidget(testWidget);

    await tester.pump(new Duration(seconds: 1));

    expect(find.text("Alnassem"), findsOneWidget);
    expect(find.text("wosol Company"), findsOneWidget);
    expect(find.text("SR123.4/month"), findsOneWidget);
    expect(find.text("5"), findsOneWidget);
  });

  // Load profile screen not admin user
  testWidgets('Load company profile no user', (WidgetTester tester) async {
    // mock user with incorrect email
    final user = MockUser(
      isAnonymous: false,
      uid: 'someuid',
      email: 'imnotanadmin@gmail.com',
      displayName: 'fake wosol',
    );

    final firebaseAuth = MockFirebaseAuth(signedIn: true, mockUser: user);

    Widget testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(
            home: profileScreen(
                firestore: firestore,
                firebaseAuth: firebaseAuth,
                firebaseStorage: firebaseStorage)));
    await tester.pumpWidget(testWidget);

    await tester.pump(new Duration(seconds: 1));

    expect(
        find.text("You are not an admin, no company found!"), findsOneWidget);
  });

  // Change company register status
  testWidgets('Change company register status', (WidgetTester tester) async {
    Widget testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(
            home: profileScreen(
                firestore: firestore,
                firebaseAuth: firebaseAuth,
                firebaseStorage: firebaseStorage)));
    await tester.pumpWidget(testWidget);
    await tester.pump(new Duration(seconds: 1));
    // Tap on the switch that changes the register status value of the company
    await tester.tap(find.byType(Switch));
    await tester.pump(new Duration(seconds: 1));
    // Check if the register status actually got changed in the firestore or not
    firestore
        .collection("company")
        .doc(mockCompany.CompanyID)
        .get()
        .then((value) {
      // excpect true because originally it was false in line:30
      expect(value.data()!['registerStatus'], true);
    });
  });

  // Edit company profile
  testWidgets('Edit company profile', (WidgetTester tester) async {
    Widget testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(
            home: editProfile(
                currentCompany: mockCompany,
                firestore: firestore,
                firebaseAuth: firebaseAuth,
                firebaseStorage: firebaseStorage)));
    await tester.pumpWidget(testWidget);
    await tester.pump(new Duration(microseconds: 500));
    // Test input validation
    await tester.enterText(
        find.byKey(const ValueKey('PhoneNumberField')), 'test123');
    await tester.pump(new Duration(microseconds: 500));
    expect(find.text("Only digit allowed"), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('NameField')), 'wo');
    await tester.pump(new Duration(microseconds: 500));
    expect(find.text("Enter at least 3 characters"), findsOneWidget);

    // Test editing company profile with correct values
    await tester.enterText(
        find.byKey(const ValueKey('PhoneNumberField')), '0512345678');
    await tester.pump(new Duration(microseconds: 500));
    await tester.enterText(find.byKey(const ValueKey('NameField')), 'Wosol');
    await tester.pump(new Duration(microseconds: 500));
    // Click save button
    await tester.tap(find.byType(IconButton));
    await tester.pump(new Duration(microseconds: 500));
    // Check if information was updated in the firestore or not
    firestore
        .collection("company")
        .doc(mockCompany.CompanyID)
        .get()
        .then((value) {
      expect(value.data()!['phoneNumber'], "0512345678");
      expect(value.data()!['name'], "Wosol");
    });
  });
}
