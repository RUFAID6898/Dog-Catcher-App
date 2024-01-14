import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<String> uniqueLocations = Set<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('reports').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var items = snapshot.data!.docs;

          List<Widget> itemList = [];
          for (var item in items) {
            var itemName = item['location'];

            if (itemName is GeoPoint) {
              var latitude = itemName.latitude;
              var longitude = itemName.longitude;
              itemName = 'Latitude: $latitude, Longitude: $longitude';
            }

            if (uniqueLocations.add(itemName.toString())) {
              itemList.add(
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      title: const Text(
                        'DangorZoons',
                        style: TextStyle(color: Colors.red),
                      ),
                      subtitle: Text(itemName.toString()),
                      trailing: const Icon(Icons.notifications_active),
                    ),
                  ),
                ),
              );
            }
          }

          uniqueLocations.clear();

          return ListView(
            children: itemList,
          );
        },
      ),
    );
  }
}
