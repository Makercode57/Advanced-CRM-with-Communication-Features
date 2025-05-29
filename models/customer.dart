import 'dart:convert';

class Customer {
  String name;
  String email;
  String phone;
  String status; // Active or Inactive

  Customer({
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
  });

  // Convert a Customer object into a map (for shared preferences storage)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'status': status,
    };
  }

  // Convert a map into a Customer object
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      status: map['status'],
    );
  }

  // Convert Customer object to a JSON string
  String toJson() => json.encode(toMap());

  // Create Customer object from JSON string
  factory Customer.fromJson(String source) => Customer.fromMap(json.decode(source));
}
