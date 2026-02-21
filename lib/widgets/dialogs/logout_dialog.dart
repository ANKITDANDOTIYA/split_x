 import 'package:flutter/material.dart' show ElevatedButton, Navigator, TextButton, Colors, Icons, CircleAvatar, Theme, showModalBottomSheet;
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:split_expenses/services/auth_service.dart';

 Future<void> showLogoutBottomSheet(BuildContext context){
   return  showModalBottomSheet(
     context: context,
     shape: const RoundedRectangleBorder(
       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
     ),
     builder: (_) {
       return Padding(
         padding: const EdgeInsets.all(40),
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             // Handle bar
             Container(
               width: 40,
               height: 4,
               decoration: BoxDecoration(
                 color: Colors.grey[400],
                 borderRadius: BorderRadius.circular(4),
               ),
             ),
             const SizedBox(height: 20),

             // Icon
             CircleAvatar(
               radius: 28,
               backgroundColor: Colors.redAccent.withOpacity(0.15),
               child: const Icon(
                 Icons.logout_rounded,
                 color: Colors.redAccent,
                 size: 28,
               ),
             ),
             const SizedBox(height: 16),

             // Title
             Text(
               "Logout",
               style: Theme.of(context).textTheme.titleLarge,
             ),
             const SizedBox(height: 8),

             // Description
             Text(
               "Are you sure you want to logout?\nYou will need to login again.",
               textAlign: TextAlign.center,
               style: TextStyle(color: Colors.grey[600]),
             ),
             const SizedBox(height: 24),

             // Logout button
             ElevatedButton(
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.redAccent,
                 minimumSize: const Size.fromHeight(48),
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(16),
                 ),
               ),
               onPressed: () async {
                 Navigator.pop(context);
                 await Provider.of<AuthService>(context, listen: false).signOut();
               },
               child: const Text("Logout"),
             ),

             // Cancel
             TextButton(
               onPressed: () => Navigator.pop(context),
               child: const Text("Cancel"),
             ),
           ],
         ),
       );
     },
   );
 }