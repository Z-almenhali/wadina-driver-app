class Company {
  String? CompanyID;
  String? address;
  String? contract;
  String? description;
  String? email;
  String? imageURL;
  String? name;
  String? phoneNumber;
  String? price;
  String? rate;
  bool? registerStatus;
  Company(
      {this.CompanyID,
      this.address,
      this.contract,
      this.description,
      this.email,
      this.imageURL,
      this.name,
      this.phoneNumber,
      this.price,
      this.rate,
      this.registerStatus});
  //receiving data from server
  factory Company.fromMap(map) {
    return Company(
        CompanyID: map['CompanyID'],
        address: map['address'],
        contract: map['contract'],
        description: map['description'],
        email: map['email'],
        imageURL: map['imageURL'],
        name: map['name'],
        phoneNumber: map['phoneNumber'],
        price: map['price'],
        rate: map['rate'],
        registerStatus: map['registerStatus']);
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'CompanyID': CompanyID,
      'address': address,
      'contract': contract,
      'description': description,
      'email': email,
      'imageURL': imageURL,
      'name': name,
      'phoneNumber': phoneNumber,
      'price': price,
      'rate': rate,
      'registerStatus': registerStatus
    };
  }
}
