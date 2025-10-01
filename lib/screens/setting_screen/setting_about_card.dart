import 'package:flutter/material.dart';

class SettingsAboutCard extends StatelessWidget {
  const SettingsAboutCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF405189).withOpacity(0.13),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Color(0xFF405189),
                size: 22,
              ),
            ),
            title: const Text(
              'App Version',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF405189),
              ),
            ),
            subtitle: Text(
              'SIMAP Indocement v 1.0.1',
              style: TextStyle(
                fontFamily: 'Maison Book',
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Divider(height: 1, indent: 60),
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF405189).withOpacity(0.13),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.privacy_tip_outlined,
                color: Color(0xFF405189),
                size: 22,
              ),
            ),
            title: const Text(
              'Terms & Privacy',
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF405189),
              ),
            ),
            subtitle: Text(
              'Read our terms and privacy policy',
              style: TextStyle(
                fontFamily: 'Maison Book',
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF405189),
              size: 17,
            ),
            onTap: () {
              _showTermsAndPrivacyDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showTermsAndPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: TermsAndPrivacyContent(),
        );
      },
    );
  }
}

class TermsAndPrivacyContent extends StatefulWidget {
  @override
  _TermsAndPrivacyContentState createState() => _TermsAndPrivacyContentState();
}

class _TermsAndPrivacyContentState extends State<TermsAndPrivacyContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      width: MediaQuery.of(context).size.width * 0.9,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF405189),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Legal Information",
                        style: TextStyle(
                          fontFamily: 'Maison Bold',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor:
                      const Color.fromARGB(179, 255, 255, 255),
                  tabs: const [
                    Tab(text: "Terms of Service"),
                    Tab(text: "Privacy Policy"),
                  ],
                ),
              ],
            ),
          ),
          Flexible(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTermsOfService(),
                _buildPrivacyPolicy(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey, width: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF405189),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "I Understand",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsOfService() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Syarat dan Ketentuan SIMAP Indocement - Sistem Manajemen Asset",
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF405189),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "1. Persetujuan Penggunaan",
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Dengan menggunakan SIMAP Indocement, Anda setuju untuk mematuhi seluruh syarat dan ketentuan yang berlaku. Aplikasi ini dirancang khusus untuk kebutuhan manajemen Asset di lingkungan Logistic Division.",
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 16),
            Text(
              "2. Hak dan Akses Pengguna",
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Setiap pengguna wajib menjaga kerahasiaan akun dan bertanggung jawab atas setiap aktivitas yang dilakukan melalui akun tersebut. Akses aplikasi hanya diberikan kepada karyawan atau pihak yang telah mendapat izin resmi.",
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 16),
            Text(
              "3. Pengelolaan Data Asset dan Aset",
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Data yang dimasukkan ke dalam SIMAP sepenuhnya merupakan tanggung jawab pengguna. Setiap informasi Asset, lokasi, dan status harus akurat dan sesuai dengan kondisi sebenarnya di lapangan.",
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 16),
            Text(
              "4. Keamanan & Privasi",
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "SIMAP berkomitmen menjaga keamanan data pengguna dan aset perusahaan. Data akan diakses dan diproses sesuai kebijakan terkait privasi dan perlindungan data.",
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 16),
            Text(
              "5. Penggunaan Fitur Barcode",
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Fitur scan Barcode dalam aplikasi hanya boleh digunakan untuk keperluan inventarisasi dan pemeliharaan Asset di lingkungan Indocement.",
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 16),
            Text(
              "7. Perubahan dan Pengembangan Layanan",
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Pengembang berhak untuk memperbarui, mengubah, atau menghentikan fitur aplikasi kapan saja sesuai kebutuhan operasional tanpa pemberitahuan terlebih dahulu.",
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 16),
            // Text(
            //   "8. Hukum yang Berlaku",
            //   style: TextStyle(
            //     fontFamily: 'Maison Bold',
            //     fontSize: 13,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            // SizedBox(height: 8),
            // Text(
            //   "Syarat dan ketentuan ini tunduk pada hukum yang berlaku di Republik Indonesia.",
            //   style: TextStyle(fontSize: 12),
            // ),
            // SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicy() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Kebijakan Privasi SIMAP Indocement",
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF405189),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "1. Penggunaan Data",
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Data digunakan untuk mendukung operasional manajemen Asset, pelaporan, analisis, dan peningkatan proses inventarisasi.",
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 16),
            Text(
              "2. Penyimpanan dan Keamanan Data",
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Data disimpan secara aman di server internal. Sistem keamanan diterapkan sesuai standar perusahaan untuk mencegah akses tidak sah.",
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 16),
            Text(
              "3. Hak Akses dan Kontrol Pengguna",
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Pengguna dapat meminta akses, koreksi, atau penghapusan data pribadi melalui admin sistem atau Divisi IT.",
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 16),
            // Text(
            //   "4. Pembagian Data",
            //   style: TextStyle(
            //     fontFamily: 'Maison Bold',
            //     fontSize: 13,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            // SizedBox(height: 8),
            // Text(
            //   "Data tidak akan dibagikan ke pihak eksternal kecuali atas persetujuan manajemen Indocement atau sesuai peraturan yang berlaku.",
            //   style: TextStyle(fontSize: 12),
            // ),
            // SizedBox(height: 16),
            Text(
              "4. Perubahan Kebijakan",
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Tim berhak memperbarui Kebijakan Privasi sesuai kebutuhan dan akan menginformasikan pengguna melalui aplikasi.",
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 16),
            Text(
              "5. Kontak & Informasi Lebih Lanjut",
              style: TextStyle(
                fontFamily: 'Maison Bold',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Untuk pertanyaan atau permintaan terkait privasi dan aplikasi, silakan hubungi Contact person: wildansobah69@gmail.com",
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
