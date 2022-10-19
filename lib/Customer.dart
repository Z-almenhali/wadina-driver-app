class Customer {
  String? Name;
  String? customerid;
  String? email;
  String? Latitude;
  String? longitude;
  String? phoneNumber;
  String? schoolName;
  bool? isDone = false;
  String? dropOff;
  String? pickUp;
  String? pickupDriver;
  String? dropoffDriver;
  Customer(
      {this.Name,
      this.customerid,
      this.email,
      this.Latitude,
      this.longitude,
      this.phoneNumber,
      this.schoolName,
      this.pickupDriver,
      this.dropoffDriver});
  //receiving data from server
  factory Customer.fromMap(map) {
    return Customer(
        Name: map['Name'],
        customerid: map['customerid'],
        email: map['email'],
        Latitude: map['latitude'],
        longitude: map['longitude'],
        phoneNumber: map['phoneNumber'],
        schoolName: map['schoolName'],
        pickupDriver: map['driverPickup'],
        dropoffDriver: map['driverDropoff']);
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'name': Name,
      'customerid': customerid,
      'email': email,
      'Latitude': Latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'schoolName': schoolName,
    };
  }
}
