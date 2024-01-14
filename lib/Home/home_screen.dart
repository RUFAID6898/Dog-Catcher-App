import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dog_catcher_app/Animal%20Helpline/CustomerCare_.dart';
import 'package:dog_catcher_app/Animal%20Helpline/control_service_details.dart';
import 'package:dog_catcher_app/Authentication%20Services/login_page.dart';

import 'package:dog_catcher_app/Home/widget/home_screen_widget.dart';
import 'package:dog_catcher_app/Notification%20Service/notification_screen.dart';
import 'package:dog_catcher_app/Report_Screen/Report_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          StreamBuilder(
            stream: _firestore.collection('reports').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationScreen(),
                          ));
                    },
                    icon: const Icon(
                      Icons.notifications_active_sharp,
                      color: Colors.red,
                    ));
              } else {
                return IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationScreen(),
                          ));
                    },
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.red,
                    ));
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _getUserInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              String userName = snapshot.data?['name'] ?? 'Guest';
              String userEmail = snapshot.data?['email'] ?? '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(userName),
                    accountEmail: Text(userEmail),
                    currentAccountPicture: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () async {
                      await _auth.signOut();

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
      body: ListView(
        children: <Widget>[
          HomeScreenWidget(
            image: 'assets/images/report.jpg',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportScreen()),
              );
            },
            ButtonName: 'Report Stray Dog',
            textcolor: Colors.red,
            iconvisibility: false,
            icons: Icons.call,
          ),
          HomeScreenWidget(
            image: 'assets/images/control.jpg',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ControlServicesScreen()),
              );
            },
            ButtonName: 'Animal Control Services',
            textcolor: Colors.green,
            iconvisibility: true,
            icons: Icons.call,
          ),
          HomeScreenWidget(
            image: 'assets/images/coustomerCare.jpg',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CustomerCareScreen()),
              );
            },
            ButtonName: 'Chat With Customer Care',
            textcolor: Colors.green,
            iconvisibility: true,
            icons: Icons.chat_outlined,
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserInfo() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userInfo =
          await _firestore.collection('users').doc(user.uid).get();

      if (userInfo.exists) {
        return userInfo.data() as Map<String, dynamic>;
      } else {
        return {'name': 'Guest', 'email': ''};
      }
    } else {
      return {'name': 'Guest', 'email': ''};
    }
  }
}
