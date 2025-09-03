import 'package:flutter/material.dart';
import 'package:Simba/screens/home_screen/lost_assets/lost_asset_service.dart';

const primaryColor = Color(0xFF405189);

class LostAssetDetailPage extends StatefulWidget {
  final Map asset;
  final LostAssetService service;
  final String currentUser;

  const LostAssetDetailPage({
    required this.asset,
    required this.service,
    required this.currentUser,
    Key? key,
  }) : super(key: key);

  @override
  _LostAssetDetailPageState createState() => _LostAssetDetailPageState();
}

class _LostAssetDetailPageState extends State<LostAssetDetailPage> {
  bool isLoading = true;
  bool isRefreshing = false;
  Map? currentAsset;

  @override
  void initState() {
    super.initState();
    currentAsset = widget.asset;
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() => isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil diperbarui', style: TextStyle(fontFamily: 'Inter')),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(Icons.broken_image, color: Colors.white, size: 48),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getImageUrl() {
    if (currentAsset?['lost_evidence_path'] != null &&
        currentAsset!['lost_evidence_path'].toString().isNotEmpty) {
      final path = currentAsset!['lost_evidence_path'].toString();
      return path.startsWith('http') ? path : 'http://192.168.1.8:8000/storage/$path';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = _getImageUrl();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Aset Hilang',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: isRefreshing ? null : _refreshData,
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Text('Tandai Ditemukan', style: TextStyle(fontFamily: 'Inter')),
                value: 'found',
              ),
            ],
            onSelected: (value) async {
              if (value == 'found') {
                final success = await widget.service.markAssetFound(currentAsset?['id']);
                if (success) {
                  Navigator.pop(context, 'found');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Aset berhasil ditandai ditemukan', style: TextStyle(fontFamily: 'Inter')),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? _buildLoadingContent()
          : _buildContent(imageUrl),
    );
  }

  Widget _buildLoadingContent() {
    return Center(
      child: CircularProgressIndicator(color: primaryColor),
    );
  }

  Widget _buildContent(String imageUrl) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(imageUrl),
            const SizedBox(height: 20),
            _buildCard(
              icon: Icons.info_outline,
              color: primaryColor,
              title: "Informasi Aset",
              child: _buildAssetInfo(),
            ),
            const SizedBox(height: 16),
            _buildCard(
              icon: Icons.report_gmailerrorred,
              color: Colors.red[700]!,
              title: "Informasi Kehilangan",
              child: _buildLostInfo(),
            ),
            const SizedBox(height: 16),
            _buildEvidenceAndReporterCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(String imageUrl) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: imageUrl.isNotEmpty
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showFullImage(context, imageUrl),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildNoImage(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                      );
                    },
                  ),
                ),
              )
            : _buildNoImage(),
      ),
    );
  }

  Widget _buildNoImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade100, Colors.grey.shade50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.image_not_supported, size: 48, color: Color(0xFFBDBDBD)),
            SizedBox(height: 8),
            Text(
              'Tidak ada gambar',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color color,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 9,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildAssetInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currentAsset?['name'] ?? '-',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
            color: Color(0xFF222B45),
          ),
        ),
        const SizedBox(height: 10),
        _buildInfoRow('Kode Aset', currentAsset?['asset_code']),
        _buildInfoRow('Kategori', currentAsset?['category']),
        _buildInfoRow('Lokasi', currentAsset?['location']),
        _buildInfoRow('PIC', currentAsset?['pic']),
      ],
    );
  }

  Widget _buildLostInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Tanggal Hilang', _formatDate(currentAsset?['lost_date'])),
        _buildInfoRow('Penyebab', currentAsset?['lost_cause']),
        const SizedBox(height: 10),
        Text(
          'Kronologi:',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            color: Color(0xFF405189),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFFF6F7FB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFFE9ECEF)),
          ),
          child: Text(
            currentAsset?['lost_chronology'] ?? '-',
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Inter',
              color: Color(0xFF222B45),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceAndReporterCard() {
    bool hasEvidence = currentAsset?['lost_evidence_path'] != null &&
        (currentAsset?['lost_evidence_path']?.toString().isNotEmpty ?? false);
    String reporter = currentAsset?['lost_reported_by'] ?? widget.currentUser;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 9,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Evidence Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: hasEvidence ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              hasEvidence ? Icons.check : Icons.close,
              color: hasEvidence ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Evidence Text
          Expanded(
            flex: 2,
            child: Text(
              hasEvidence ? 'Bukti tersedia (lihat gambar)' : 'Tidak ada bukti',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: hasEvidence ? Colors.green : Colors.red,
                fontSize: 14,
              ),
            ),
          ),
          // Divider
          Container(width: 1, height: 38, color: Colors.grey[200]),
          const SizedBox(width: 12),
          // Reporter
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.13),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                reporter.isNotEmpty ? reporter[0].toUpperCase() : '-',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  color: primaryColor,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              reporter,
              style: const TextStyle(
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: Color(0xFF222B45),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(': ', style: const TextStyle(color: Color(0xFF6B7280))),
          Expanded(
            child: Text(
              value?.toString().isNotEmpty == true ? value.toString() : '-',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                fontFamily: 'Inter',
                color: Color(0xFF222B45),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr.toString());
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }
}