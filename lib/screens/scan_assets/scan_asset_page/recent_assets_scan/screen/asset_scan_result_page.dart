// import 'package:flutter/material.dart';
// import 'asset.dart';
// import 'package:Simba/screens/home_screen/logistic_asset/logistic_asset_model.dart';
// import 'package:Simba/screens/home_screen/logistic_asset_scan_menu/asset_upload_dialog.dart';

// class AssetScanResultPage extends StatelessWidget {
//   final Asset asset;

//   const AssetScanResultPage({Key? key, required this.asset}) : super(key: key);

//   bool get assetDetected {
//     print("DEBUG assetDetected check: assetCode = '${asset.assetCode}'");
//     return asset.assetCode.trim().isNotEmpty;
//   }

//   LogisticAsset get logisticAsset {
//     final logAsset = LogisticAsset(
//       id: asset.id.toString(),
//       title: asset.name,
//       assetNo: asset.assetCode,
//       generalAccount: asset.generalAccount ?? '',
//       subsidiaryAccount: asset.subsidiaryAccount ?? '',
//       category: asset.category,
//       subCategory: asset.subCategory ?? '',
//       assetSpecification: asset.assetSpecification ?? '',
//       assetStatus: asset.status,
//       acquisitionDate: asset.acquisitionDate ?? asset.createdAt,
//       aging: asset.aging ?? '',
//       quantity: asset.quantity ?? 1,
//       department: asset.location,
//       controlDepartment: asset.controlDepartment ?? '',
//       costCenter: asset.costCenter ?? '',
//       available: asset.available ??
//           (asset.status.toLowerCase() == 'available' ? 1 : 0),
//       broken: asset.broken ??
//           (asset.status.toLowerCase() == 'broken' ||
//                   asset.status.toLowerCase() == 'damaged'
//               ? 1
//               : 0),
//       lost: asset.lost ?? (asset.status.toLowerCase() == 'lost' ? 1 : 0),
//       remarks: asset.remarks ?? asset.description,
//       createdAt: asset.createdAt ?? DateTime.now(),
//       updatedAt: asset.updatedAt ?? DateTime.now(),
//       photos: asset.photos,
//       primaryPhoto: asset.primaryPhoto,
//     );
//     print("DEBUG logisticAsset.id: ${logAsset.id}");
//     print("DEBUG logisticAsset.assetNo: '${logAsset.assetNo}'");
//     print("DEBUG logisticAsset.title: '${logAsset.title}'");
//     print("DEBUG logisticAsset.assetStatus: '${logAsset.assetStatus}'");
//     print("DEBUG logisticAsset.department: '${logAsset.department}'");
//     print("DEBUG logisticAsset.photos: ${logAsset.photos}");
//     print("DEBUG logisticAsset.primaryPhoto: ${logAsset.primaryPhoto}");
//     return logAsset;
//   }

//   void _openUploadDialog(BuildContext context) async {
//     print("DEBUG _openUploadDialog called");
//     await showDialog(
//       context: context,
//       builder: (_) => AssetUploadDialog(asset: logisticAsset),
//     );
//   }

//   void _scanAgain(BuildContext context) {
//     print("DEBUG _scanAgain called");
//     Navigator.of(context).pop(); 
//   }

//   Color _getStatusColor(String status) {
//     print("DEBUG _getStatusColor called with status: '$status'");
//     switch (status.toLowerCase()) {
//       case 'active':
//       case 'available':
//         return Colors.green;
//       case 'inactive':
//       case 'damaged':
//       case 'broken':
//         return Colors.orange;
//       case 'disposed':
//       case 'lost':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     print("DEBUG build called");
//     print("DEBUG asset.id: ${asset.id}");
//     print("DEBUG asset.assetCode: '${asset.assetCode}'");
//     print("DEBUG asset.name: '${asset.name}'");
//     print("DEBUG asset.status: '${asset.status}'");
//     print("DEBUG asset.assetSpecification: '${asset.assetSpecification}'");
//     print("DEBUG asset.description: '${asset.description}'");
//     print("DEBUG asset.location: '${asset.location}'");
//     print("DEBUG asset.photos: ${asset.photos}");
//     print("DEBUG asset.primaryPhoto: ${asset.primaryPhoto}");

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Hasil Scan Asset'),
//         backgroundColor: const Color(0xFF405189),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: assetDetected
//           ? SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Info Asset (mirror dari AssetInfoWidget)
//                   Text(
//                     'Informasi Asset',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey[800],
//                       fontFamily: 'Maison Bold',
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(7),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 12, vertical: 6),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF405189).withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(7),
//                               ),
//                               child: Text(
//                                 asset.assetCode,
//                                 style: const TextStyle(
//                                   fontFamily: 'Maison Bold',
//                                   fontSize: 14,
//                                   color: Color(0xFF405189),
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ),
//                             const Spacer(),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 12, vertical: 6),
//                               decoration: BoxDecoration(
//                                 color: _getStatusColor(asset.status)
//                                     .withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(7),
//                               ),
//                               child: Text(
//                                 asset.status,
//                                 style: TextStyle(
//                                   fontFamily: 'Maison Bold',
//                                   fontSize: 12,
//                                   color: _getStatusColor(asset.status),
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           asset.name,
//                           style: const TextStyle(
//                             fontFamily: 'Maison Bold',
//                             fontSize: 20,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           asset.assetSpecification ?? asset.description,
//                           style: TextStyle(
//                             fontFamily: 'Maison Book',
//                             fontSize: 14,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   // Tombol Upload Foto Asset
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.upload),
//                       label: const Text('Upload Foto Asset'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: const Color(0xFF405189),
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(7),
//                         ),
//                         elevation: 0,
//                       ),
//                       onPressed: () => _openUploadDialog(context),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             )
//           : Center(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 32),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.warning_amber, color: Colors.orange, size: 64),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Asset tidak ditemukan!',
//                       style: TextStyle(
//                         fontFamily: 'Maison Bold',
//                         fontSize: 18,
//                         color: Colors.orange[700],
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       'Silakan scan ulang QR atau masukkan kode asset secara manual.',
//                       style: TextStyle(
//                         fontFamily: 'Maison Book',
//                         fontSize: 14,
//                         color: Colors.orange[600],
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 32),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: () => _scanAgain(context),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orange,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(7),
//                           ),
//                         ),
//                         child: const Text('Scan Lagi'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }