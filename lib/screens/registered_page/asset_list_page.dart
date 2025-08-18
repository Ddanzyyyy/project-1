import 'package:Simba/screens/welcome_page.dart';
import 'package:flutter/material.dart';

class AssetListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(82),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WelcomePage()),
              );
            },
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF405189),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Image.asset(
                'assets/images/icons/registered_assets.png',
                height: 38,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(10),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          AssetCard(
              title: 'Buku', imagePath: 'assets/images/LOGO_INDOCEMENT.jpg'),
          AssetCard(
              title: 'Semen', imagePath: 'assets/images/LOGO_INDOCEMENT.jpg'),
          AssetCard(
              title: 'Laptop', imagePath: 'assets/images/LOGO_INDOCEMENT.jpg'),
          AssetCard(
              title: 'Laptop', imagePath: 'assets/images/LOGO_INDOCEMENT.jpg'),
        ],
      ),
    );
  }
}

class AssetCard extends StatelessWidget {
  final String title;
  final String imagePath;

  AssetCard({required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            color: Colors.grey[300],
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailPage(title: title)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF405189),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String title;

  DetailPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$title Details',
          style: TextStyle(color: Colors.white), 
        ),
        backgroundColor: Color(0xFF405189),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Text(
          'Details for $title\nHas been registered',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}