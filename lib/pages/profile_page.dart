// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexus/components/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  late String username;
  late String updatedValue; // Declare updatedValue as a class-level variable

  Future<void> editField(String field) async {
    var userCollection = FirebaseFirestore.instance.collection('users');
    var userQuery = userCollection.where('email', isEqualTo: currentUser.email);

    var querySnapshot = await userQuery.get();

    if (querySnapshot.size > 0) {
      var userDocument = querySnapshot.docs[0];

      updatedValue =
          userDocument[field]; // Initialize updatedValue with the current value

      String? newValue = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            "Edit $field",
            style: const TextStyle(color: Colors.white),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return TextField(
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter new $field",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  setState(() {
                    updatedValue = value; // Update the updatedValue variable
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(updatedValue),
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (newValue != null && newValue.trim().isNotEmpty) {
        await userDocument.reference.update({field: newValue});
        setState(() {
          username = newValue;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var docRef = FirebaseFirestore.instance
        .collection("users")
        .where('email', isEqualTo: currentUser.email)
        .get();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text("P R O F I L E  P A G E"),
      ),
      body: FutureBuilder<QuerySnapshot>(
          future: docRef,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.size == 0) {
              return Center(child: Text('No matching user found.'));
            }

            var userDocument = snapshot.data!.docs[0];
            username = userDocument['username'];

            return ListView(
              children: [
                const SizedBox(height: 50),
                Icon(
                  Icons.person,
                  size: 72,
                ),
                const SizedBox(height: 50),
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My Details',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                MyTextBox(
                  text: username, // Now you can use the username variable here
                  sectionName: 'username',
                  onPressed: () => editField("username"),
                ),
                MyTextBox(
                  text: userDocument['bio'],
                  sectionName: 'bio',
                  onPressed: () => editField("bio"),
                ),
                //Padding(
                //  padding: const EdgeInsets.only(left: 25.0),
                //  child: Text(
                //    'My posts',
                //    style: TextStyle(
                //      color: Colors.grey[600],
                //    ),
                //  ),
                //),
              ],
            );
          }),
    );
  }
}
