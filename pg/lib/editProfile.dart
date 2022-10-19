import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'company.dart';

class editProfile extends StatefulWidget {
  editProfile(
      {Key? key,
      required this.currentCompany,
      required this.firestore,
      required this.firebaseAuth,
      required this.firebaseStorage})
      : super(key: key);

  Company currentCompany;
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final FirebaseStorage firebaseStorage;

  @override
  State<editProfile> createState() =>
      _editProfileState(currentCompany: currentCompany);
}

class _editProfileState extends State<editProfile> {
  Company currentCompany;
  _editProfileState({required this.currentCompany});

  @override
  void initState() {
    super.initState();
  }

  final ImagePicker _picker = ImagePicker();
  final Passkey = GlobalKey<FormState>();
  final Savekey = GlobalKey<FormState>();
  var password;
  var newPassword;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Color(0xFF536DFE),
          bottomOpacity: 0.0,
          elevation: 0.0,
          centerTitle: true,
          actions: [
            IconButton(
                icon: Icon(
                  Icons.check,
                  color: Color.fromARGB(255, 0, 255, 8),
                  size: 28,
                ),
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (Savekey.currentState!.validate()) {
                    Savekey.currentState!.save();
                    // use the information provided

                    widget.firestore
                        .collection('company')
                        .doc(currentCompany.CompanyID)
                        .update(currentCompany.toMap());
                    Navigator.pop(context);
                  }
                }),
          ],
        ),
        body: SingleChildScrollView(
          reverse: true,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 115,
                          width: 115,
                          child: Stack(
                            fit: StackFit.expand,
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(
                                    currentCompany.imageURL.toString()),
                              ),
                              Positioned(
                                right: -16,
                                bottom: 0,
                                child: SizedBox(
                                  height: 46,
                                  width: 46,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                        side: BorderSide(color: Colors.white),
                                      ),
                                      primary: Colors.white,
                                      backgroundColor: Color(0xFFF5F6F9),
                                    ),
                                    onPressed: () async =>
                                        _pickImageFromGallery(),
                                    child: SvgPicture.asset(
                                        "assets/icons/Camera Icon.svg"),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ]),
              const Divider(
                height: 20,
                thickness: 1,
                indent: 0,
                endIndent: 0,
                color: Colors.black,
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                // height: MediaQuery.of(context).size.height - 400,
                height: 500,
                width: 300,
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: Savekey,
                  child: ListView(children: <Widget>[
                    TextFormField(
                      key: const ValueKey('NameField'),
                      initialValue: currentCompany.name.toString(),
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        filled: true,
                        icon: Icon(Icons.person),
                        labelText: 'Name *',
                      ),
                      //----------validation---------
                      validator: (value) {
                        if (value != null && value.length < 3) {
                          return 'Enter at least 3 characters';
                        } else {
                          return null; // form is valid
                        }
                      },
                      onSaved: (String? value) {
                        currentCompany.name = value;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    TextFormField(
                      initialValue: currentCompany.address.toString(),
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        filled: true,
                        icon: Icon(Icons.location_city),
                        labelText: 'Address *',
                      ),
                      //----------validation---------
                      validator: (value) {
                        if (value != null && value.length < 3) {
                          return 'Enter at least 3 characters';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (String? value) {
                        currentCompany.address = value;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    Text(currentCompany.phoneNumber.toString()),
                    TextFormField(
                      key: const ValueKey('PhoneNumberField'),
                      initialValue: currentCompany.phoneNumber.toString(),
                      maxLength: 10,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        filled: true,
                        icon: Icon(Icons.phone),
                        labelText: 'Phone Number *',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null && !isNumeric(value)) {
                          return 'Only digit allowed';
                        } else if (value != null && value.length < 10) {
                          return 'Phone number must be 10 numbers';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (String? value) {
                        currentCompany.phoneNumber = value;
                      },
                    ),
                    TextFormField(
                      maxLines: 7,
                      initialValue: currentCompany.description.toString(),
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        filled: true,
                        icon: Icon(Icons.description),
                        labelText: 'Description *',
                      ),
                      //----------validation---------
                      validator: (value) {
                        if (value != null && value.length < 1) {
                          return 'Enter description';
                        } else {
                          return null; // form is valid
                        }
                      },
                      onSaved: (String? value) {
                        currentCompany.description = value;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    TextFormField(
                      initialValue: currentCompany.price.toString(),
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        filled: true,
                        icon: Icon(Icons.price_change_outlined),
                        suffixText: 'SR',
                        labelText: 'Price *',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && !isNumeric(value)) {
                          return 'Only digit allowed';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (String? value) {
                        currentCompany.price = value;
                      },
                    ),
                    const SizedBox(height: 24.0),
                    TextFormField(
                      key: const ValueKey('ChangePasswordField'),
                      obscureText: true,
                      initialValue: "123456789",
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        filled: true,
                        icon: Icon(Icons.password),
                        labelText: 'Password *',
                      ),
                      readOnly: true,
                      autofocus: false,
                      onTap: () => showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.only(
                            topLeft: const Radius.circular(35.0),
                            topRight: const Radius.circular(35.0),
                          )),
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return _buildBottomSheet(context);
                            });
                          }),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        ));
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File _imageFile = File(pickedFile.path);
      var companyID = currentCompany.CompanyID.toString();
      var randomID = DateTime.now().millisecondsSinceEpoch.toString();

      // Delete old image
      await widget.firebaseStorage
          .ref('images/' + companyID)
          .listAll()
          .then((value) {
        // No old images is found
        if (value.items.length != 0) {
          widget.firebaseStorage.ref(value.items.first.fullPath).delete();
        }
      });

      // Upload image
      await widget.firebaseStorage
          .ref('images/' + companyID)
          .child(randomID)
          .putFile(_imageFile);

      currentCompany.imageURL =
          'https://firebasestorage.googleapis.com/v0/b/wadinaapp.appspot.com/o/images%2F' +
              companyID +
              "%2F" +
              randomID +
              '?alt=media';
      widget.firestore
          .collection('company')
          .doc(currentCompany.CompanyID)
          .update(currentCompany.toMap());
      setState(() {});
      //
    }
  }

  var isload = false;
  Padding _buildBottomSheet(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    return Padding(
      padding: mediaQueryData.viewInsets,
      child: Container(
        padding: const EdgeInsets.all(18.0),
        height: 350,
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: Passkey,
          child: SizedBox(
            height: 100,
            width: 100,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                const ListTile(title: Text('Edit password')),
                // "Password" form.
                PasswordField(
                  fieldKey: const ValueKey('CurrentPasswordField'),
                  labelText: 'Curent Password *',
                  onSaved: (String? value) {
                    password = value;
                  },

                  //----------validation---------
                  validator: (value) {
                    if (value != null && value.length < 8) {
                      return 'Password must have at least 8 characters';
                    } else {
                      return null; // form is valid
                    }
                  },
                ),
                const SizedBox(height: 24.0),
                PasswordField(
                  fieldKey: const ValueKey('NewPasswordField'),
                  labelText: 'New password *',
                  onSaved: (String? value) {
                    newPassword = value; //   this._password = value;
                  },
                  validator: (value) {
                    if (value != null && value.length < 8) {
                      return 'Password must have at least 8 characters';
                    } else {
                      return null; // form is valid
                    }
                  },
                ),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    isload
                        ? CircularProgressIndicator()
                        : OutlinedButton(
                            key: const ValueKey('ChangePasswordButton'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              // side: BorderSide(width: 2, color: Colors.grey),
                            ),
                            onPressed: () {
                              print('I"M PRESSED!!!!');
                              setState(() {
                                isload = true;
                              });
                              // Validate returns true if the form is valid, or false otherwise.
                              if (Passkey.currentState!.validate()) {
                                User? user = widget.firebaseAuth.currentUser;
                                Passkey.currentState!.save();
                                final cred = EmailAuthProvider.credential(
                                    email: currentCompany.email.toString(),
                                    password: password);
                                user!
                                    .reauthenticateWithCredential(cred)
                                    .then((value) {
                                  user.updatePassword(newPassword).then((_) {
                                    Navigator.pop(context);
                                    showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              35.0))),
                                              title: Text('Successful',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                              content: Text(
                                                  "Pasword was changed succufully"),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ));
                                  }).catchError((error) {
                                    print(error.toString());
                                  });
                                }).catchError((err) {
                                  print(err.message.toString());
                                  showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(35.0))),
                                      title: Text('Error',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          )),
                                      content: Text(err.message.toString()),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'OK'),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                                setState(() {
                                  isload = false;
                                });
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Save",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
  });

  final Key? fieldKey;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.fieldKey,
      obscureText: _obscureText,
      // maxLength: 8,
      onSaved: widget.onSaved,
      validator: widget.validator,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        filled: true,
        hintText: widget.hintText,
        labelText: widget.labelText,
        helperText: widget.helperText,
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        ),
      ),
    );
  }
}
