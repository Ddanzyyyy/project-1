// import 'package:Simba/screens/setting_screen/notification_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';


// class SettingsNotificationCard extends StatefulWidget {
//   final bool notificationsEnabled;
//   final bool pushNotifications;
//   final ValueChanged<bool> onNotificationsChanged;
//   final ValueChanged<bool> onPushChanged;

//   const SettingsNotificationCard({
//     Key? key,
//     required this.notificationsEnabled,
//     required this.pushNotifications,
//     required this.onNotificationsChanged,
//     required this.onPushChanged,
//   }) : super(key: key);

//   @override
//   _SettingsNotificationCardState createState() => _SettingsNotificationCardState();
// }

// class _SettingsNotificationCardState extends State<SettingsNotificationCard> {
//   bool _isInitializing = false;
//   bool _automaticNotifications = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadAutomaticSetting();
//   }

//   Future<void> _loadAutomaticSetting() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _automaticNotifications = prefs.getBool('automatic_notifications') ?? false;
//     });
//   }

//   Future<void> _handleAutomaticToggle(bool value) async {
//     if (value) {
//       await NotificationService.enableAutomaticNotifications();
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Notifikasi otomatis diaktifkan (9 AM daily & Monday weekly)',
//               style: TextStyle(fontFamily: 'Maison Bold'),
//             ),
//             backgroundColor: Colors.green,
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//         );
//       }
//     } else {
//       await NotificationService.disableAutomaticNotifications();
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Notifikasi otomatis dinonaktifkan',
//               style: TextStyle(fontFamily: 'Maison Book'),
//             ),
//             backgroundColor: Colors.grey[600],
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//         );
//       }
//     }
    
//     setState(() {
//       _automaticNotifications = value;
//     });
    
//     HapticFeedback.lightImpact();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           _buildSwitchTile(
//             icon: Icons.notifications_outlined,
//             title: 'Enable Notifications',
//             subtitle: 'Receive app notifications',
//             value: widget.notificationsEnabled,
//             onChanged: (value) {
//               widget.onNotificationsChanged(value);
//               HapticFeedback.lightImpact();
//             },
//             isLoading: _isInitializing,
//           ),
//           if (widget.notificationsEnabled) ...[
//             const Divider(height: 1, indent: 60),
//             _buildSwitchTile(
//               icon: Icons.phone_android,
//               title: 'Push Notifications',
//               subtitle: 'Asset status notifications',
//               value: widget.pushNotifications,
//               onChanged: (value) {
//                 widget.onPushChanged(value);
//                 HapticFeedback.lightImpact();
//               },
//             ),
//           ],
//           if (widget.notificationsEnabled && widget.pushNotifications) ...[
//             const Divider(height: 1, indent: 60),
//             _buildSwitchTile(
//               icon: Icons.schedule,
//               title: 'Automatic Notifications',
//               subtitle: 'Daily 9AM & Weekly Monday 8AM',
//               value: _automaticNotifications,
//               onChanged: _handleAutomaticToggle,
//             ),
//             const Divider(height: 1, indent: 60),
//             _buildManualCheckButton(),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildSwitchTile({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required bool value,
//     required ValueChanged<bool> onChanged,
//     bool isLoading = false,
//   }) {
//     return ListTile(
//       contentPadding: const EdgeInsets.all(16),
//       leading: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: const Color(0xFF405189).withOpacity(0.13),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Icon(
//           icon,
//           color: Color(0xFF405189),
//           size: 22,
//         ),
//       ),
//       title: Text(
//         title,
//         style: const TextStyle(
//           fontFamily: 'Maison Bold',
//           fontSize: 14,
//           fontWeight: FontWeight.w700,
//           color: Color(0xFF405189),
//         ),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: TextStyle(
//           fontFamily: 'Maison Book',
//           fontSize: 11,
//           color: Colors.grey[600],
//         ),
//       ),
//       trailing: isLoading
//           ? SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 color: Color(0xFF405189),
//               ),
//             )
//           : Switch(
//               value: value,
//               onChanged: onChanged,
//               activeColor: const Color(0xFF405189),
//               inactiveThumbColor: Colors.grey[400],
//               inactiveTrackColor: Colors.grey[300],
//             ),
//     );
//   }

//   Widget _buildManualCheckButton() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: SizedBox(
//         width: double.infinity,
//         child: ElevatedButton.icon(
//           icon: const Icon(Icons.notifications_active, size: 18),
//           label: const Text(
//             'Periksa Sekarang',
//             style: TextStyle(
//               fontFamily: 'Maison Bold',
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF405189),
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//           onPressed: () async {
//             await NotificationService.checkAndSendAssetNotifications();
//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: const Text(
//                     'Pemeriksaan notifikasi asset selesai!',
//                     style: TextStyle(fontFamily: 'Maison Bold'),
//                   ),
//                   backgroundColor: Colors.green,
//                   behavior: SnackBarBehavior.floating,
//                   margin: const EdgeInsets.all(16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }
// }