import 'package:flutter/material.dart';
import 'package:Simba/screens/NoImplementedHere/lost_assets/lost_asset_service.dart';

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
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Data berhasil diperbarui',
                  style: TextStyle(fontFamily: 'Maison Book')),
            ],
          ),
          backgroundColor: Colors.green[600],
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Center(
                child:
                    Icon(Icons.broken_image, color: Colors.white70, size: 48),
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
      return path.startsWith('http')
          ? path
          : 'http://192.168.8.144:8000/storage/$path';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = _getImageUrl();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 1,
        title: Text(
          'Detail Aset Hilang',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            fontFamily: 'Maison Bold',
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 22),
            onPressed: isRefreshing ? null : _refreshData,
            tooltip: "Refresh",
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white, size: 22),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            offset: Offset(0, 48),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'found',
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 18),
                    SizedBox(width: 10),
                    Text(
                      'Tandai Ditemukan',
                      style: TextStyle(fontFamily: 'Maison Bold', fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'found') {
                _showMarkFoundDialog();
              }
            },
          ),
        ],
      ),
      body: isLoading ? _buildLoadingContent() : _buildContent(imageUrl),
    );
  }

  Widget _buildLoadingContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor, strokeWidth: 3),
          SizedBox(height: 16),
          Text(
            'Memuat detail aset...',
            style: TextStyle(
              fontFamily: 'Maison Book',
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String imageUrl) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: primaryColor,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(imageUrl),
            SizedBox(height: 16),
            _buildSimpleInfoCard(),
            SizedBox(height: 18),
            _buildSimpleLostInfoCard(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(String imageUrl) {
    return Container(
      height: 170,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageUrl.isNotEmpty
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showFullImage(context, imageUrl),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildNoImage(),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primaryColor,
                          ),
                        );
                      },
                    )))
            : _buildNoImage(),
      ),
    );
  }

  Widget _buildNoImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined,
                size: 48, color: Colors.grey[300]),
            SizedBox(height: 8),
            Text(
              'Tidak ada bukti gambar',
              style: TextStyle(
                color: Colors.grey[500],
                fontFamily: 'Maison Book',
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetNameCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentAsset?['name'] ?? '-',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Maison Bold',
              color: primaryColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            currentAsset?['asset_code'] ?? '-',
            style: TextStyle(
              fontFamily: 'Maison Book',
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Asset
          Text(
            currentAsset?['name'] ?? '-',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Maison Bold',
              color: primaryColor,
            ),
          ),
          SizedBox(height: 4),
          // ID Asset
          Text(
            'Kode: ' + (currentAsset?['asset_code'] ?? '-'),
            style: TextStyle(
              fontFamily: 'Maison Book',
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 10),
          _buildInfoRow('Kategori', currentAsset?['category']),
          _buildInfoRow('Lokasi', currentAsset?['location']),
          _buildInfoRow('PIC', currentAsset?['pic']),
        ],
      ),
    );
  }

  Widget _buildSimpleLostInfoCard() {
    bool hasEvidence = currentAsset?['lost_evidence_path'] != null &&
        (currentAsset?['lost_evidence_path']?.toString().isNotEmpty ?? false);
    String reporter = currentAsset?['lost_reported_by'] ?? widget.currentUser;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
              'Tanggal Hilang', _formatDate(currentAsset?['lost_date'])),
          _buildInfoRow('Penyebab', currentAsset?['lost_cause']),
          SizedBox(height: 10),
          Text(
            'Kronologi Kejadian',
            style: TextStyle(
              fontFamily: 'Maison Bold',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              currentAsset?['lost_chronology'] ?? '-',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Maison Book',
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Icon(
                hasEvidence ? Icons.check_circle : Icons.cancel,
                color: hasEvidence ? Colors.green : Colors.red,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                hasEvidence ? 'Bukti Ada' : 'Tanpa Bukti',
                style: TextStyle(
                  fontFamily: 'Maison Bold',
                  fontSize: 13,
                  color: hasEvidence ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Icon(Icons.person, color: primaryColor, size: 18),
              SizedBox(width: 6),
              Text(
                reporter,
                style: TextStyle(
                  fontFamily: 'Maison Book',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: primaryColor,
                fontSize: 13,
                fontFamily: 'Maison Bold',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            ': ',
            style:
                TextStyle(color: Colors.grey[700], fontFamily: 'Maison Book'),
          ),
          Expanded(
            child: Text(
              value?.toString().isNotEmpty == true ? value.toString() : '-',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 13,
                fontFamily: 'Maison Book',
                color: Colors.grey[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkFoundDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 22),
            SizedBox(width: 10),
            Text('Tandai Ditemukan',
                style: TextStyle(fontFamily: 'Maison Bold', fontSize: 17)),
          ],
        ),
        content: Text(
          'Aset ini sudah ditemukan? Tindakan ini akan menghapus laporan kehilangan.',
          style: TextStyle(fontFamily: 'Maison Book', fontSize: 13),
        ),
        actions: [
          TextButton(
            child: Text('Batal',
                style: TextStyle(
                    fontFamily: 'Maison Book', color: Colors.grey[600])),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            ),
            child: Text('Ya, Ditemukan',
                style:
                    TextStyle(fontFamily: 'Maison Bold', color: Colors.white)),
            onPressed: () async {
              Navigator.pop(
                  dialogContext); 
              final success =
                  await widget.service.markAssetFound(currentAsset?['id']);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Aset berhasil ditandai ditemukan',
                        style: TextStyle(fontFamily: 'Maison Book')),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 1),
                  ),
                );
                await Future.delayed(const Duration(milliseconds: 400));
                if (mounted) Navigator.pop(context, 'found');
              }
            },
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
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }
}
