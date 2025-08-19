import 'package:Simba/screens/edit_profile_page.dart';
import 'package:flutter/material.dart';


class ProfileCard extends StatefulWidget {
  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  String currentName = "caccarehana"; 
  String currentEmail = "caccarehana@example.com";
  String currentDivision = "IT Department";

  void _updateProfile(String name, String email, String division) {
    setState(() {
      currentName = name;
      currentEmail = email;
      currentDivision = division;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () async {
          try {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfilePage(
                  initialName: currentName,
                  initialEmail: currentEmail,
                  initialDivision: currentDivision,
                  onProfileUpdated: _updateProfile,
                ),
              ),
            );
            
            if (result != null && result is Map<String, String>) {
              setState(() {
                currentName = result['name'] ?? currentName;
                currentEmail = result['email'] ?? currentEmail;
                currentDivision = result['division'] ?? currentDivision;
              });
            }
          } catch (e) {
            // Handle error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF405189),
                child: Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentName,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: const Color(0xFF405189),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Citeureup',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: const Color(0xFF405189),
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}