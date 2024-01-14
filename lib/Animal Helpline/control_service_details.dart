import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ControlServicesScreen extends StatelessWidget {
  const ControlServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Control Services'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('ANIMAL HELPLINES')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          var shelters = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: shelters.length,
            itemBuilder: (context, index) {
              var shelterData = shelters[index].data() as Map<String, dynamic>;
              var shelter = Shelter(
                name: shelterData['name'],
                address: shelterData['Address'],
                phoneNumber: shelterData['number'],
              );

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: ListTile(
                    title: Text(shelter.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shelter.address),
                        Text(shelter.phoneNumber),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.phone,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        _makePhoneCall(shelter.phoneNumber);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    try {
      String cleanedPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
      String url = 'tel:$cleanedPhoneNumber';

      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } on PlatformException catch (e) {
      print('Platform Exception: ${e.message}');
    } catch (e) {
      print('Error making phone call: $e');
    }
  }
}

class Shelter {
  final String name;
  final String address;
  final String phoneNumber;

  Shelter({
    required this.name,
    required this.address,
    required this.phoneNumber,
  });
}
