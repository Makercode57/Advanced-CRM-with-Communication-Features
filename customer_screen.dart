import 'package:flutter/material.dart';
import 'models/customer.dart';
import 'customer_service.dart';

class CustomerScreen extends StatefulWidget {
  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  List<Customer> _customers = [];
  TextEditingController _searchController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  String _status = 'Active';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  // Load customers from local storage
  Future<void> _loadCustomers() async {
    final customers = await CustomerService.getCustomers();
    setState(() {
      _customers = customers;
      // Sort by status (Active -> Inactive) and then by name alphabetically
      _customers.sort((a, b) {
        if (a.status != b.status) {
          return a.status == 'Active' ? -1 : 1; // Active should come first
        }
        return a.name.compareTo(b.name); // Sort alphabetically by name
      });
    });
  }

  // Add a new customer
  Future<void> _addCustomer() async {
    final customer = Customer(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      status: _status,
    );
    await CustomerService.addCustomer(customer);
    _loadCustomers();
    _clearTextFields();
    
    // Navigate to chat screen after adding customer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(customerName: customer.name),
      ),
    );
  }

  // Edit an existing customer
  Future<void> _editCustomer(int index) async {
    final customer = Customer(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      status: _status,
    );
    await CustomerService.editCustomer(index, customer);
    _loadCustomers();
    _clearTextFields();
  }

  // Delete a customer
  Future<void> _deleteCustomer(int index) async {
    await CustomerService.deleteCustomer(index);
    _loadCustomers();
  }

  // Clear text fields
  void _clearTextFields() {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _status = 'Active';
  }

  // Filter customers based on search query
  Future<void> _filterCustomers(String query) async {
    final filteredCustomers = await CustomerService.searchCustomers(query);
    setState(() {
      _customers = filteredCustomers;
    });
  }

  // Show the customer status color
  Color _getStatusColor(String status) {
    if (status == 'Active') {
      return Colors.green.shade400;
    } else {
      return Colors.red.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Management'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _filterCustomers,
              decoration: InputDecoration(
                labelText: 'Search Customers',
                labelStyle: TextStyle(color: Colors.black87),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.black54),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _customers.length,
                itemBuilder: (context, index) {
                  final customer = _customers[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        customer.name,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${customer.email} - ${customer.phone}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteCustomer(index),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(customer.status),
                        child: Text(
                          customer.status[0],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      onTap: () {
                        // Edit customer on tap
                        _nameController.text = customer.name;
                        _emailController.text = customer.email;
                        _phoneController.text = customer.phone;
                        _status = customer.status;
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Edit Customer'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(controller: _nameController),
                                TextField(controller: _emailController),
                                TextField(controller: _phoneController),
                                DropdownButton<String>(
                                  value: _status,
                                  items: ['Active', 'Inactive']
                                      .map((e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _status = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _editCustomer(index);
                                  Navigator.pop(context);
                                },
                                child: Text('Save', style: TextStyle(color: Colors.blue)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Add New Customer'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
                        TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
                        TextField(controller: _phoneController, decoration: InputDecoration(labelText: 'Phone')),
                        DropdownButton<String>(
                          value: _status,
                          items: ['Active', 'Inactive']
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _status = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _addCustomer();
                          Navigator.pop(context);
                        },
                        child: Text('Add', style: TextStyle(color: Colors.green)),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Add Customer', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// Chat Screen to display customer name after adding
class ChatScreen extends StatelessWidget {
  final String customerName;

  ChatScreen({required this.customerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $customerName'),
        backgroundColor: Colors.purple.shade600,
      ),
      body: Center(
        child: Text('Welcome to the chat with $customerName!', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
