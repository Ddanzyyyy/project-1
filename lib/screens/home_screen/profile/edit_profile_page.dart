import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final String? initialName;
  final String? initialUsername;
  final Function(String, String)? onProfileUpdated;

  const EditProfilePage({
    Key? key,
    this.initialName,
    this.initialUsername,
    this.onProfileUpdated,
  }) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initFields();
  }

  Future<void> _initFields() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _nameController.text = widget.initialName ?? prefs.getString('name') ?? '';
    _usernameController.text = widget.initialUsername ?? prefs.getString('username') ?? '';
    _userId = prefs.getString('user_id');

    if (_nameController.text.isEmpty || _usernameController.text.isEmpty) {
      await _loadProfileFromAPI();
    }
    setState(() {});
  }

  Future<void> _loadProfileFromAPI() async {
    if (_userId == null) return;
    setState(() => _isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse('http://192.168.8.131:8000/api/$_userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _nameController.text = data['name'] ?? '';
          _usernameController.text = data['username'] ?? '';
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', data['name'] ?? '');
        await prefs.setString('username', data['username'] ?? '');
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 255, 0, 0),
          ),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF718096),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF718096),
                fontSize: 13,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color.fromARGB(255, 255, 0, 0),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  // Future<void> _pickImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _profileImage = File(pickedFile.path);
  //     });
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     await prefs.setString('profile_image', pickedFile.path);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF405189), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Color(0xFF405189),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Color(0xFF405189),
                  strokeWidth: 2,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFF405189), size: 18),
              onPressed: _logout,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF405189),
                strokeWidth: 2,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar kecil
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFF405189),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Name dan username kecil
                  Text(
                    _nameController.text.isNotEmpty ? _nameController.text : 'No Name',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF405189),
                    ),
                  ),
                  
                  const SizedBox(height: 2),
                  
                  Text(
                    _usernameController.text.isNotEmpty ? '@${_usernameController.text}' : '@username',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF718096),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Form minimalis
                  _buildMinimalField(
                    label: 'Name',
                    controller: _nameController,
                    icon: Icons.person_outline,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildMinimalField(
                    label: 'Role',
                    controller: _usernameController,
                    icon: Icons.work_outline,
                  ),
                  
                  const Spacer(),
                  
                  // Info kecil
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF405189).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Color(0xFF405189),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Profile info is read-only',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: Color(0xFF405189),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildMinimalField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF405189).withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        enabled: false,
        onChanged: (text) {
          if (label == 'Name') setState(() {});
        },
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Color(0xFF405189),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            size: 16,
            color: const Color(0xFF405189).withOpacity(0.7),
          ),
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Color(0xFF718096),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}