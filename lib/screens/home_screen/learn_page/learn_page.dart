import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color primaryColor = Color(0xFF405189);

class LearnPage extends StatefulWidget {
  @override
  _LearnPageState createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final PageController _pageController = PageController();

  final List<LearnSection> _sections = [
    LearnSection(
      title: "Welcome to SIMAP",
      subtitle: "Your Complete Asset Management Solution",
      description:
          "SIMAP helps you manage, track, and monitor your assets efficiently with powerful features designed for modern businesses.",
      icon: Icons.inventory_2_outlined,
      steps: [
        "Sistem pelacakan aset modern",
        "Manajemen inventaris real-time",
        "Analisis & pelaporan aset",
        "Mobilitas & akses di mana saja"
      ],
    ),
    LearnSection(
      title: "Logistic Assets",
      subtitle: "Import & Manage Your Assets",
      description:
          "Learn how to import your assets from Excel files and manage them effectively.",
      icon: Icons.upload_file_outlined,
      steps: [
        "Buka 'Logistic Assets' di beranda",
        "Tekan tombol 'Impor Excel'",
        "Pilih berkas Excel Anda dengan data aset",
        "Pastikan Kolom Excel sesuai format",
        "Jika tidak sesuai, edit di Excel lalu impor ulang",
        "Lihat aset Anda yang diimpor dalam list"
      ],
    ),
    LearnSection(
      title: "Scanning Assets",
      subtitle: "QR Code & Barcode Scanning",
      description:
          "Master the art of scanning asset QR codes and barcodes for quick identification.",
      icon: Icons.qr_code_scanner_outlined,
      steps: [
        "Arahkan ke 'Scan Logistic Asset'",
        "Ketuk tombol 'Open Scanner'",
        "Arahkan kamera ke kode QR/Barcode",
        "Tunggu deteksi otomatis",
        "Tinjau detail aset yang dipindai, Import Gambar Aset dari Galeri maupun Kamera"
      ],
    ),
    LearnSection(
      title: "Search & Filter",
      subtitle: "Find Assets Quickly",
      description:
          "Use powerful search and filtering options to locate specific assets instantly.",
      icon: Icons.search_outlined,
      steps: [
        "Masukkan name, code, or category",
        "Telusuri hasil pencarian",
        "Ketuk aset apa pun untuk tampilan detail"
      ],
    ),
    LearnSection(
      title: "Asset Analytics",
      subtitle: "Monitor & Analyze",
      description:
          "Get insights into your asset performance with comprehensive analytics and reports.",
      icon: Icons.analytics_outlined,
      steps: [
        "Access 'Analytics Asset' from home",
        "View asset distribution charts",
        "Monitor status summaries",
        "Track available, broken, and lost assets",
        "Generate custom reports"
      ],
    ),
    LearnSection(
      title: "Best Practices",
      subtitle: "Tips for Effective Asset Management",
      description:
          "Follow these best practices to get the most out of your SIMAP experience.",
      icon: Icons.lightbulb_outlined,
      steps: [
        "Regularly scan and update asset status",
        "Keep asset information up to date",
        "Use consistent naming conventions",
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: primaryColor,
      statusBarIconBrightness: Brightness.light, 
      statusBarBrightness: Brightness.dark, 
    ));
  }

  @override
void dispose() {
  _pageController.dispose();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: primaryColor,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: Text(
          'Tutorial',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            fontFamily: 'Maison Bold',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: primaryColor,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Color(0xFFE2E8F0),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              itemCount: _sections.length,
              separatorBuilder: (_, __) => SizedBox(height: 10),
              itemBuilder: (context, index) {
                final section = _sections[index];
                return _buildListItem(section, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total: ${_sections.length} topik',
            style: TextStyle(
              color: primaryColor.withOpacity(0.7),
              fontSize: 12,
              fontFamily: 'Maison Book',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(LearnSection section, int index) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 4, // Tambahkan shadow
      shadowColor: Colors.black.withOpacity(0.15),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => _buildDetailSheet(section),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(section.icon, size: 22, color: primaryColor),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: TextStyle(
                        fontFamily: 'Maison Bold',
                        fontSize: 14,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      section.subtitle,
                      style: TextStyle(
                        fontFamily: 'Maison Book',
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: primaryColor, size: 26),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSheet(LearnSection section) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 24,
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(section.icon, size: 26, color: primaryColor),
                    ),
                    SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title,
                            style: TextStyle(
                              fontFamily: 'Maison Bold',
                              fontSize: 15,
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            section.subtitle,
                            style: TextStyle(
                              fontFamily: 'Maison Book',
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14),
                Text(
                  section.description,
                  style: TextStyle(
                    fontFamily: 'Maison Book',
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 22),
                Text(
                  'Panduan langkah-langkah:',
                  style: TextStyle(
                    fontFamily: 'Maison Bold',
                    color: primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                ...section.steps.asMap().entries.map((entry) {
                  int idx = entry.key;
                  String step = entry.value;
                  return _buildStepItem(idx + 1, step);
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepItem(int number, String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.13),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  fontFamily: 'Maison Bold',
                  color: primaryColor,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Maison Book',
                color: Color(0xFF343B4E),
                fontSize: 13,
                height: 1.28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LearnSection {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<String> steps;

  LearnSection({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.steps,
  });
}