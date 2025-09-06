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
              'SIMBA v0.0.1',
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Syarat dan Ketentuan",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF405189),
            ),
          ),
          SizedBox(height: 16),
          Text(
            "1. Persetujuan Syarat",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Dengan mengakses atau menggunakan SIMBA Asset Management App, Anda setuju untuk terikat oleh Syarat dan Ketentuan ini. Jika Anda tidak setuju dengan bagian manapun dari syarat ini, Anda tidak diperbolehkan mengakses layanan.",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 16),
          Text(
            "2. Penggunaan Layanan",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "SIMBA Asset Management App menyediakan alat untuk pelacakan, pengelolaan, dan pemeliharaan inventaris serta aset. Pengguna bertanggung jawab atas keakuratan data yang dimasukkan ke sistem dan harus memiliki otorisasi yang sesuai untuk melacak aset di organisasi.",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 16),
          Text(
            "3. Akun Pengguna",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Pengguna bertanggung jawab menjaga keamanan kredensial login dan segala aktivitas yang dilakukan di bawah akun mereka. Aplikasi tidak boleh digunakan untuk melacak aset tanpa izin yang sah dari pemilik atau organisasi.",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 16),
          Text(
            "4. Data dan Konten Aset",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Pengguna tetap memiliki hak penuh atas data aset mereka. Kami tidak mengklaim hak atas konten Anda. Anda bertanggung jawab atas keakuratan dan legalitas data yang dimasukkan ke sistem. Informasi sensitif harus diolah sesuai kebijakan data organisasi Anda.",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 16),
          Text(
            "5. Batasan Tanggung Jawab",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "SIMBA Asset Management App disediakan ‘sebagaimana adanya’ tanpa jaminan apapun. Kami tidak bertanggung jawab atas kerugian atau kerusakan akibat penggunaan layanan, termasuk namun tidak terbatas pada kehilangan data, kehilangan aset fisik, atau kerugian finansial akibat ketergantungan pada informasi aplikasi.",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 16),
          Text(
            "6. Perubahan Layanan",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Kami berhak mengubah atau menghentikan layanan kapan saja, dengan atau tanpa pemberitahuan. Kami tidak bertanggung jawab kepada Anda atau pihak ketiga atas perubahan, penangguhan, atau penghentian layanan.",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 16),
          Text(
            "7. Fitur QR Code dan Pemindaian",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Fitur pemindaian QR code hanya disediakan untuk keperluan pelacakan aset. Pengguna tidak diperbolehkan menggunakan fitur ini untuk memindai QR code atau barcode yang tidak sah. Kami tidak bertanggung jawab atas kerusakan akibat pemindaian QR code berbahaya dari luar sistem kami.",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 16),
          Text(
            "8. Hukum yang Berlaku",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Syarat dan Ketentuan ini diatur dan ditafsirkan berdasarkan hukum yang berlaku di Indonesia, tanpa memperhatikan pertentangan ketentuan hukum.",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicy() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Kebijakan Privasi",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF405189),
            ),
          ),
          SizedBox(height: 16),
          Text(
            "1. Informasi yang Kami Kumpulkan",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "SIMBA Asset Management App mengumpulkan informasi berikut:\n"
            "• Informasi akun: username, email, dan password\n"
            "• Data aset: deskripsi, lokasi, status, catatan perawatan\n"
            "• Informasi perangkat: tipe perangkat, sistem operasi, versi aplikasi\n"
            "• Data penggunaan: fitur yang digunakan, waktu penggunaan, aktivitas pemindaian",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 16),
          Text(
            "2. Cara Kami Menggunakan Informasi",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Kami menggunakan informasi yang dikumpulkan untuk:\n"
            "• Memberikan layanan manajemen aset\n"
            "• Mengirim notifikasi perubahan status aset\n"
            "• Membuat laporan penggunaan dan perawatan aset\n"
            "• Meningkatkan fungsi dan pengalaman aplikasi\n"
            "• Mendiagnosis masalah teknis dan mengoptimalkan performa",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 16),
          Text(
            "3. Penyimpanan Data",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Data aset disimpan di server yang aman. Sebagian data mungkin di-cache secara lokal di perangkat untuk fitur offline. Kami menerapkan langkah keamanan yang sesuai untuk melindungi dari akses atau perubahan tidak sah.",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 16),
          Text(
            "4. Akses Kamera dan Lokasi",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Aplikasi kami memerlukan akses kamera untuk pemindaian QR code dan foto aset. Layanan lokasi mungkin digunakan untuk pelacakan lokasi aset. Kedua izin ini opsional, namun dapat membatasi fungsi aplikasi jika tidak diberikan.",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 16),
          Text(
            "5. Berbagi Data",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Kami tidak menjual atau menyewakan data pengguna kepada pihak ketiga. Data aset dapat dibagikan dengan pengguna yang berwenang di organisasi Anda sesuai pengaturan izin. Kami dapat membagikan statistik penggunaan anonim untuk meningkatkan layanan.",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 16),
          Text(
            "6. Retensi Data",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Kami menyimpan data Anda selama akun aktif atau sesuai kebutuhan layanan. Anda dapat meminta penghapusan data akun, namun sebagian informasi mungkin disimpan untuk kepentingan hukum atau bisnis.",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 16),
          Text(
            "7. Notifikasi",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Aplikasi kami mengirim notifikasi terkait perubahan status aset, pengingat perawatan, dan pembaruan sistem. Anda dapat mengatur preferensi notifikasi di pengaturan aplikasi.",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 16),
          Text(
            "8. Hak Anda",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Anda berhak mengakses, mengoreksi, atau menghapus data pribadi Anda. Hubungi admin sistem atau tim dukungan kami untuk menggunakan hak ini.",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 16),
          Text(
            "9. Perubahan Kebijakan Privasi",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Kami dapat memperbarui Kebijakan Privasi dari waktu ke waktu. Kami akan memberitahu pengguna tentang perubahan signifikan melalui aplikasi atau email.",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 16),
          Text(
            "10. Kontak",
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Jika Anda memiliki pertanyaan atau kekhawatiran terkait Kebijakan Privasi ini, silakan hubungi Data Protection Officer kami di privacy@simba-app.id.",
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
