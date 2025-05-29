import 'package:shared_preferences/shared_preferences.dart';
import 'models/customer.dart';

class CustomerService {
  static const _customersKey = 'customers';

  // Fetch customers from local storage
  static Future<List<Customer>> getCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final customerData = prefs.getStringList(_customersKey) ?? [];
    return customerData.map((e) => Customer.fromJson(e)).toList();
  }

  // Save customers to local storage
  static Future<void> saveCustomers(List<Customer> customers) async {
    final prefs = await SharedPreferences.getInstance();
    final customerData = customers.map((e) => e.toJson()).toList();
    await prefs.setStringList(_customersKey, customerData);
  }

  // Add a new customer
  static Future<void> addCustomer(Customer customer) async {
    final customers = await getCustomers();
    customers.add(customer);
    await saveCustomers(customers);
  }

  // Edit an existing customer
  static Future<void> editCustomer(int index, Customer customer) async {
    final customers = await getCustomers();
    customers[index] = customer;
    await saveCustomers(customers);
  }

  // Delete a customer
  static Future<void> deleteCustomer(int index) async {
    final customers = await getCustomers();
    customers.removeAt(index);
    await saveCustomers(customers);
  }

  // Search for customers by name, email, or phone
  static Future<List<Customer>> searchCustomers(String query) async {
    final customers = await getCustomers();
    return customers
        .where((customer) =>
            customer.name.toLowerCase().contains(query.toLowerCase()) ||
            customer.email.toLowerCase().contains(query.toLowerCase()) ||
            customer.phone.contains(query))
        .toList();
  }
}
