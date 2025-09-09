import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  final String? initialName;
  final String? initialUsername;
  final String? initialEmail;
  final Function(String, String)? onProfileUpdated;

  const EditProfilePage({
    Key? key,
    this.initialName,
    this.initialUsername,
    this.onProfileUpdated,
    this.initialEmail,
  }) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _userId;
  String currentUser = 'caccarehana';
  String currentUserName = 'Loading...';
  String currentEmail = '';
  String lastLoginTime = '';
  bool isLoadingUserInfo = true;

  @override
  void initState() {
    super.initState();
    _initFields();
  }

  // Get current formatted time in WIB (UTC+7)
  String getCurrentTimeWIB() {
    final now = DateTime.now();
    // Convert to WIB (UTC+7)
    final wibTime = now.toUtc().add(const Duration(hours: 7));
    return '${wibTime.year}-${wibTime.month.toString().padLeft(2, '0')}-${wibTime.day.toString().padLeft(2, '0')} ${wibTime.hour.toString().padLeft(2, '0')}:${wibTime.minute.toString().padLeft(2, '0')}:${wibTime.second.toString().padLeft(2, '0')} WIB';
  }

  // Get current time for login in WIB
  String getCurrentLoginTime() {
    final now = DateTime.now();
    // Convert to WIB (UTC+7)
    final wibTime = now.toUtc().add(const Duration(hours: 7));
    return '${wibTime.day.toString().padLeft(2, '0')}-${wibTime.month.toString().padLeft(2, '0')}-${wibTime.year} ${wibTime.hour.toString().padLeft(2, '0')}:${wibTime.minute.toString().padLeft(2, '0')} WIB';
  }

  // Save current login time
  Future<void> _saveLoginTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('login_time', getCurrentLoginTime());
  }

  Future<void> _initFields() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Load comprehensive user data
      final username = prefs.getString('username') ?? 'caccarehana';
      final fullName =
          prefs.getString('full_name') ?? prefs.getString('name') ?? 'User';
      final firstName = prefs.getString('first_name') ?? '';
      final lastName = prefs.getString('last_name') ?? '';
      final email = prefs.getString('email') ?? '';
      final loginTime = prefs.getString('login_time') ?? getCurrentLoginTime();

      // Build display name
      String displayName = fullName;
      if (displayName == 'User' && firstName.isNotEmpty) {
        displayName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;
      }

      setState(() {
        currentUser = username;
        currentUserName = displayName;
        currentEmail = email;
        lastLoginTime = loginTime;
        _nameController.text = widget.initialName ?? displayName;
        _usernameController.text = widget.initialUsername ?? username;
        _emailController.text = email;
        _userId = prefs.getString('user_id');
        isLoadingUserInfo = false;
      });

      print('👤 Edit Profile - User session loaded:');
      print('   - Username: $currentUser');
      print('   - Display Name: $currentUserName');
      print('   - Email: $currentEmail');
      print('   - Current Time WIB: ${getCurrentTimeWIB()}');
      print('   - Last Login: $lastLoginTime');

      // Always load email from database to ensure it's up to date
      await _loadProfileFromAPI();
    } catch (e) {
      print('⚠️ Error loading user session: $e');
      setState(() {
        currentUser = 'caccarehana';
        currentUserName = 'User';
        currentEmail = '';
        lastLoginTime = getCurrentLoginTime();
        isLoadingUserInfo = false;
      });
    }
  }

  Future<void> _loadProfileFromAPI() async {
    if (_userId == null) {
      print('⚠️ User ID is null, cannot load profile from API');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔄 Loading profile from API for user ID: $_userId');
      final response = await http.get(
        Uri.parse('http://192.168.1.9:8000/api/users/$_userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📡 API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 API Response Data: $data');

        final emailFromDB = data['email'] ??
            data['user']?['email'] ??
            data['data']?['email'] ??
            data['profile']?['email'] ??
            '';

        final nameFromDB = data['name'] ??
            data['full_name'] ??
            data['user']?['name'] ??
            data['data']?['name'] ??
            currentUserName;

        final usernameFromDB = data['username'] ??
            data['user']?['username'] ??
            data['data']?['username'] ??
            currentUser;

        setState(() {
          _nameController.text = nameFromDB;
          _usernameController.text = usernameFromDB;
          _emailController.text = emailFromDB;
          currentEmail = emailFromDB;
          currentUserName = nameFromDB;
          currentUser = usernameFromDB;
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', nameFromDB);
        await prefs.setString('full_name', nameFromDB);
        await prefs.setString('username', usernameFromDB);
        await prefs.setString('email', emailFromDB);

        print('📧 Profile data loaded from database:');
        print('   - Name: $nameFromDB');
        print('   - Username: $usernameFromDB');
        print('   - Email: $emailFromDB');

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Profile updated from database',
                style: TextStyle(
                  fontFamily: 'Maison Bold',
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Colors.green[600],
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } else {
        print('⚠️ Failed to load profile from API: ${response.statusCode}');
        print('⚠️ Response body: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to load profile: ${response.statusCode}',
                style: const TextStyle(
                  fontFamily: 'Maison Bold',
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Colors.orange[600],
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading profile from API: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Connection error: ${e.toString().contains('TimeoutException') ? 'Request timeout' : 'Network error'}',
              style: const TextStyle(
                fontFamily: 'Maison Book',
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: Colors.red[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'Maison Bold',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to log out from your account?',
              style: TextStyle(
                fontFamily: 'Maison Book',
                fontSize: 14,
                color: Color(0xFF718096),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.orange[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will need to login again to access the app.',
                      style: TextStyle(
                        fontFamily: 'Maison Book',
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          OverflowBar(
            alignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Maison Bold',
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontFamily: 'Maison Bold',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF405189),
          ),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF405189),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Profile',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white, size: 22),
                onPressed: _logout,
                tooltip: 'Logout',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF405189),
                      Color(0xFF364578),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        20, 60, 20, 20), 
                    child: Row(
                      children: [
                        // User Avatar
                        Container(
                          width: 50, // Reduced from 60
                          height: 50, // Reduced from 60
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 24, // Reduced from 28
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // User Info - Fixed overflow and removed current time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isLoadingUserInfo)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                Flexible(
                                  child: Text(
                                    _nameController.text.isNotEmpty
                                        ? _nameController.text
                                        : currentUserName,
                                    style: const TextStyle(
                                      fontFamily: 'Maison Bold',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              

                              // Text(
                              //   '@$currentUser',
                              //   style: const TextStyle(
                              //     fontFamily: 'Inter',
                              //     fontSize: 13, // Reduced from 14
                              //     color: Colors.white70,
                              //     fontWeight: FontWeight.w400,
                              //   ),
                              //   maxLines: 1,
                              //   overflow: TextOverflow.ellipsis,
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: Color(0xFF405189),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Profile Information'),
                        const SizedBox(height: 16),

                        _buildGojekStyleField(
                          label: 'Full Name',
                          controller: _nameController,
                          icon: Icons.person_outline,
                          enabled: false,
                        ),
                        const SizedBox(height: 16),

                        _buildGojekStyleField(
                          label: 'Username',
                          controller: _usernameController,
                          icon: Icons.alternate_email,
                          enabled: false,
                        ),
                        const SizedBox(height: 16),

                        // System Information Section
                        _buildSectionHeader('System Information'),
                        const SizedBox(height: 16),

                        _buildInfoCard(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Maison Bold',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildGojekStyleField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    bool showRefresh = false,
    VoidCallback? onRefresh,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled
              ? const Color(0xFF405189).withOpacity(0.2)
              : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        style: TextStyle(
          fontFamily: 'Maison Book',
          fontSize: 15,
          color: enabled ? const Color(0xFF1A1A1A) : Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(16),
            child: Icon(
              icon,
              size: 20,
              color: enabled ? const Color(0xFF405189) : Colors.grey[400],
            ),
          ),
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Maison Bold',
            fontSize: 14,
            color: enabled ? const Color(0xFF405189) : Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: (showRefresh && onRefresh != null) || !enabled
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showRefresh && onRefresh != null)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          onPressed: _isLoading ? null : onRefresh,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF405189),
                                  ),
                                )
                              : const Icon(
                                  Icons.refresh,
                                  size: 18,
                                  color: Color(0xFF405189),
                                ),
                          tooltip: 'Refresh from database',
                        ),
                      ),
                    if (!enabled)
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF405189).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Color(0xFF405189),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Account Information',
                  style: TextStyle(
                    fontFamily: 'Maison Bold',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Current User', currentUser),
          _buildInfoRow('Current Time (WIB)', getCurrentTimeWIB()),
          _buildInfoRow('Account Status', 'Active'),
          _buildInfoRow('Last Login',
              lastLoginTime.isNotEmpty ? lastLoginTime : getCurrentLoginTime()),
          // // _buildInfoRow('Email Status',
          //     currentEmail.isNotEmpty ? 'Loaded from DB' : 'Not Available'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Maison Book',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Text(
            ':',
            style: TextStyle(
              fontFamily: 'Maison Book',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
