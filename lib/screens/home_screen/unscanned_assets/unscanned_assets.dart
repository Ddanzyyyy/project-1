import 'package:Simba/screens/welcome_page.dart';
import 'package:flutter/material.dart';

class UnscannedAssetsWidget extends StatelessWidget {
  final List<AssetItem> assets = [
    AssetItem(name: "Laptop Dell", year: "2017"),
    AssetItem(name: "Meeting Chairs", year: "2020"),
    AssetItem(name: "SHE Desk", year: "2024"),
    AssetItem(name: "Container", year: "2022"),
    AssetItem(name: "Air Conditioner (AC)", year: "2017"),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: assets
          .map((asset) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildAssetItem(asset.name, asset.year),
              ))
          .toList(),
    );
  }

  Widget _buildAssetItem(String assetName, String year) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF405189),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              assetName,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF405189),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 20,
            color: const Color(0xFF405189),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Text(
            year,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF405189),
            ),
          ),
        ],
      ),
    );
  }
}

// Model class untuk data asset
class AssetItem {
  final String name;
  final String year;

  AssetItem({required this.name, required this.year});
}

class UnscannedAssetsPage extends StatelessWidget {
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
              child: Center(
                child: Text(
                  'Unscanned Assets',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text(
            //   'Assets that need to be scanned:',
            //   style: TextStyle(
            //     fontFamily: 'Poppins',
            //     fontSize: 16,
            //     fontWeight: FontWeight.w500,
            //     color: Color(0xFF405189),
            //   ),
            // ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: UnscannedAssetsWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget yang dapat disesuaikan dengan data dinamis
class CustomUnscannedAssetsWidget extends StatelessWidget {
  final List<AssetItem> customAssets;

  const CustomUnscannedAssetsWidget({
    Key? key,
    required this.customAssets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: customAssets
          .map((asset) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildAssetItem(asset.name, asset.year, context),
              ))
          .toList(),
    );
  }

  Widget _buildAssetItem(String assetName, String year, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Aksi ketika item diklik
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: $assetName ($year)'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: const Color(0xFF405189),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                assetName,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF405189),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 20,
              color: const Color(0xFF405189),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            Text(
              year,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF405189),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
