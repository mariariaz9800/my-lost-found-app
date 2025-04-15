import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  int selectedCategory = 0;
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _regNoController;
  late TextEditingController _mobileController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _regNoController = TextEditingController();
    _mobileController = TextEditingController();
  }

  void _clearControllers() {
    _fullNameController.clear();
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _regNoController.clear();
    _mobileController.clear();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _regNoController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        final uid = userCredential.user!.uid;

        // Initialize userData map
        Map<String, dynamic> userData = {
          'uid': uid,
          'full_name': _fullNameController.text.trim(),
          'email': email,
          'category': selectedCategory == 0
              ? 'Student'
              : selectedCategory == 1
              ? 'Teacher'
              : 'Other',
          'created_at': FieldValue.serverTimestamp(),
        };

        // Add additional data based on category
        if (selectedCategory == 0) {
          userData.addAll({
            'reg_no': _regNoController.text.trim(),
            'mobile': _mobileController.text.trim(),
          });
        } else if (selectedCategory == 1) {
          userData.addAll({
            'username': _usernameController.text.trim(),
          });
        } else if (selectedCategory == 2) {
          userData.addAll({
            'mobile': _mobileController.text.trim(),
          });
        }

        // Add user data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(userData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } on FirebaseAuthException catch (e) {
        String error = 'Registration failed';
        if (e.code == 'email-already-in-use') {
          error = 'This email is already registered.';
        } else if (e.code == 'invalid-email') {
          error = 'Invalid email format.';
        } else if (e.code == 'weak-password') {
          error = 'Password is too weak.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: const Color(0xFFFFA500),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Create Account",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Join Item Radar as a ${selectedCategory == 0 ? 'Student' : selectedCategory == 1 ? 'Teacher' : 'Other'}",
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  buildInputFields(),
                  const SizedBox(height: 16),
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(20),
                    isSelected: [
                      selectedCategory == 0,
                      selectedCategory == 1,
                      selectedCategory == 2
                    ],
                    selectedColor: Colors.white,
                    fillColor: const Color(0xFFFFA500),
                    onPressed: (index) {
                      _clearControllers();
                      setState(() {
                        selectedCategory = index;
                      });
                    },
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Student")),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Teacher")),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Other")),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: _isLoading ? null : _registerUser,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Already have an account? Sign In",
                      style: TextStyle(color: Color(0xFFFFA500)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputFields() {
    switch (selectedCategory) {
      case 1:
        return Column(
          children: [
            buildTextField("Full Name", Icons.person, controller: _fullNameController),
            const SizedBox(height: 10),
            buildTextField("Username", Icons.account_circle, controller: _usernameController),
            const SizedBox(height: 10),
            buildTextField("Email Address", Icons.email, isEmail: true, controller: _emailController),
            const SizedBox(height: 10),
            buildTextField("Password", Icons.lock, isPassword: true, controller: _passwordController),
          ],
        );
      case 2:
        return Column(
          children: [
            buildTextField("Full Name", Icons.person, controller: _fullNameController),
            const SizedBox(height: 10),
            buildTextField("Email Address", Icons.email, isEmail: true, controller: _emailController),
            const SizedBox(height: 10),
            buildTextField("Password", Icons.lock, isPassword: true, controller: _passwordController),
            const SizedBox(height: 10),
            buildTextField("Mobile Number", Icons.phone, isPhone: true, controller: _mobileController),
          ],
        );
      default:
        return Column(
          children: [
            buildTextField("Full Name", Icons.person, controller: _fullNameController),
            const SizedBox(height: 10),
            buildTextField("Registration No.", Icons.numbers, controller: _regNoController),
            const SizedBox(height: 10),
            buildTextField("Email Address", Icons.email, isEmail: true, controller: _emailController),
            const SizedBox(height: 10),
            buildTextField("Password", Icons.lock, isPassword: true, controller: _passwordController),
            const SizedBox(height: 10),
            buildTextField("Mobile Number", Icons.phone, isPhone: true, controller: _mobileController),
          ],
        );
    }
  }

  Widget buildTextField(String label, IconData icon,
      {bool isPassword = false,
        bool isEmail = false,
        bool isPhone = false,
        required TextEditingController controller}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isPhone
          ? TextInputType.phone
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        )
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }

        if (isEmail) {
          print("Email entered: $value");
          if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[a-zA-Z]{2,}$').hasMatch(value)) {
            return 'Please enter a valid email';
          }
        }


        if (isPassword) {
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
        }

        if (isPhone) {
          print("Phone entered: $value");
          if (!RegExp(r'^\d{10,15}$').hasMatch(value)) {
            return 'Please enter a valid phone number';
          }
        }

        if (label == "Registration No.") {
          if (value.length < 3) {
            return 'Registration number too short';
          }
        }

        if (label == "Username") {
          if (value.length < 4) {
            return 'Username must be at least 4 characters';
          }

          if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
            return 'Only letters, numbers and underscore allowed';
          }
        }
        return null;
      },
    );
  }
}
