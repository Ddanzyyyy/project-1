import 'package:flutter/material.dart';

const primaryColor = Color(0xFF405189);

class RegisteredLostAssetCard extends StatelessWidget {
  final Map asset;
  final VoidCallback onTap;

  const RegisteredLostAssetCard({
    Key? key,
    required this.asset,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String assetImageUrl = (asset['image_path'] != null &&
            asset['image_path'].toString().isNotEmpty)
        ? (asset['image_path'].toString().startsWith('http')
            ? asset['image_path']
            : 'http://192.168.1.8:8000/storage/' + asset['image_path'])
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: assetImageUrl.isNotEmpty
                      ? Image.network(
                          assetImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.inventory_2_outlined,
                              color: primaryColor,
                              size: 24,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                                strokeWidth: 2,
                              ),
                            );
                          },
                        )
                      : Icon(
                          Icons.inventory_2_outlined,
                          color: primaryColor,
                          size: 24,
                        ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset['name'] ?? '-',
                      style: TextStyle(
                        fontFamily: 'Maison Bold',
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            asset['category'] ?? "-",
                            style: TextStyle(
                              fontFamily: 'Maison Bold',
                              fontSize: 10,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Lost',
                            style: TextStyle(
                              fontFamily: 'Maison Bold',
                              fontSize: 10,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${asset['asset_code'] ?? '-'} • ${asset['location'] ?? '-'}',
                      style: TextStyle(
                        fontFamily: 'Maison Book',
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}