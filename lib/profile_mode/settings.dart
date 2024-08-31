import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:willow/child/bottom_page.dart';
import 'package:willow/components/primary_button.dart';

import 'package:willow/child/bottom_screens/profile_page.dart';
import '../utils/constants.dart';

class ProfileItem {
  final String? item;
  final String? title;

  ProfileItem({this.item, this.title});
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<ProfileItem> _infoItems = [
    ProfileItem(item: 'personal', title: 'Personal information'),
    ProfileItem(item: 'settings', title: 'Settings'),
    ProfileItem(item: 'admin', title: 'Admin Login'),
    ProfileItem(
        item: displayName == null ? 'login' : "logout",
        title: displayName == null ? 'login' : "logout"),
    // ProfileItem(item: 'logout', title: 'logout'),
  ];
  static String? displayName;
  Future<String?> getName() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;

      var snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(auth.currentUser!.uid)
          .get();

      displayName = snapshot['name'];
      return displayName;
    } catch (e) {
      print('Error getting display name: $e');
      return null;
    }
  }

  @override
  void initState() {
    // getName();
    super.initState();
  }

  void infoButtonOnTap(ProfileItem item) {
    switch (item.item) {
      case 'personal':
        if (displayName == null) {
          Fluttertoast.showToast(msg: "Please login first to see information");
        } else {
          goTo(context, const ProfilePage());
        }
        // Navigator.pushNamed(context, PersonalInfoPage.id);
        break;
      case 'settings':
      // Navigator.pushNamed(context, VehicleInfoPage.id);
        break;
    // transfer ammount
      case 'admin':
      // Navigator.pushNamed(context, VehicleInfoPage.id);

        break;
      case 'login':
        goTo(context, const CheckUserStatusBeforeChatOnProfile());

        break;
      case 'about':
      // _launchUrl();
        break;
      case 'logout':
        logout();
        break;

      default:
        break;
    }
  }

  logout() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Are you sure you want to logout "),
          actions: [
            PrimaryButton(
                title: "Confirm",
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    setState(() {
                      displayName == null;
                    });
                    goTo(context, const BottomPage());
                  } on FirebaseAuthException catch (e) {
                    dialogueBox(context, e.toString());
                  }
                }),
            Center(
              child: TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              const CircleAvatar(radius: 60),
              const SizedBox(height: 30),
              FutureBuilder(
                future: getName(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  _infoItems;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return displayName == null
                        ? const Text("Data")
                        : Text(displayName!);
                  }
                },
              ),
              // displayName == null ? Text("Data") : Text(displayName!),
              const SizedBox(height: 30),
              Flexible(
                child: ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        infoButtonOnTap(_infoItems[index]);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.pink,
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              _infoItems[index].title!,
                              style:
                              const TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            const Icon(
                              Icons.navigate_next,
                              size: 20,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 10.0);
                  },
                  itemCount: _infoItems.length,
                  // shrinkWrap: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget title() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: ListTile(
        shape: StadiumBorder(),
        tileColor: Colors.pinkAccent,
        title: Text("data"),
        trailing: Icon(Icons.navigate_next_outlined),
      ),
    );
  }
}
