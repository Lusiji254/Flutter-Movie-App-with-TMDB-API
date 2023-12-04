import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _image;

  User? _user;
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _profilePic = '';

  Future<void> _loadUserInfo() async {
    // Get the currently signed-in user
    _user = _auth.currentUser;

    if (_user != null) {
      // Fetch additional user information from Firestore
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(_user!.uid).get();

      if (userDoc.exists) {
        setState(() {
          _firstName = userDoc['firstName'];
          _lastName = userDoc['lastName'];
          _email = userDoc['email'];
          _profilePic = userDoc['profilePictureUrl'];
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserInfo();
  }

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Get.offAll(() => Login());

                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('isLogin', true);

                Fluttertoast.showToast(
                  msg: 'Logged out successfully',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.blueGrey,
                  textColor: Colors.white,
                );
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectImage() async {
    final picture = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picture != null) {
      debugPrint(picture.path);
      setState(() {
        _image = File(picture.path);
      });

      debugPrint('>>>>>>>IMAGE${_image?.path}');

      // Upload image to Firebase Storage
      final storageRef =
      _storage.ref().child('profile_pictures/${_user?.uid}.jpg');
      await storageRef.putFile(_image!);

      // Get the download URL
      final String downloadUrl = await storageRef.getDownloadURL();
      debugPrint('>>>>>>THE URL ${downloadUrl}');

      // Update user data in Firestore with the download URL
      await _firestore
          .collection('users')
          .doc(_user?.uid)
          .update({'profilePic': downloadUrl});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 33, 10, 18),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User Image
          SizedBox(
            height: 20,
          ),
          Stack(
            children: [
              CircleAvatar(
                backgroundColor: Colors.deepOrange,
                radius: 100,
                backgroundImage: _image != null
                    ? FileImage(_image!) as ImageProvider<Object>?
                    : NetworkImage(_profilePic) as ImageProvider<Object>?,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 20,
                  // Adjust the radius as needed
                  backgroundColor: Colors.white,
                  // Background color of the inner circle
                  child: IconButton(
                    icon: Icon(Icons.add, color: Colors.deepOrange,),
                    onPressed: () {
                      _selectImage();
                      // Handle the IconButton press
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, color: Colors.deepOrange,),
              SizedBox(width: 20),
              Text(
                '$_firstName $_lastName',
                style: GoogleFonts.lato(
                    fontSize: 20, fontWeight: FontWeight.normal, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email, color: Colors.deepOrange,),
              SizedBox(width: 20),
              Text(
                '$_email',
                style: GoogleFonts.lato(fontSize: 20, color: Colors.white),
              ),
            ],
          ),
          Spacer(),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () async {
                _showLogoutDialog();
              },
              child: Text('Sign Out'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ),
          SizedBox(height: 20,)
        ],
      ),
    );
  }
}