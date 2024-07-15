import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sobar_app/utils/globals.dart';
import 'package:sobar_app/components/dialogs/delete_confirmation_dialog.dart';
import 'package:sobar_app/components/dialogs/sign_out_confirmation_dialog.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isEditing = false;
  String _displayName = '';
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _displayName = user!.displayName ?? '';
      _nameController.text = _displayName;
    }
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  Future<void> _updateUserName() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'name': _nameController.text,
      });

      await user!.updateDisplayName(_nameController.text);

      setState(() {
        _displayName = _nameController.text;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User name updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user name: $e')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).delete();
      await user!.delete();
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete account: $e')),
      );
    }
  }

  Future<void> _signOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(openCountKey, 0);
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(onConfirm: _deleteAccount);
      },
    );
  }

  void _showSignOutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SignOutConfirmationDialog(onConfirm: _signOut);
      },
    );
  }

  void _refreshUser() {
    user!.reload();
    setState(() {
      _displayName = user!.displayName ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvoked: (result) async {
          _refreshUser();
          return Future.value();
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            title: const Text(
              'Update Profile',
              style: TextStyle(
                fontFamily: 'Anton',
                letterSpacing: 1,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () {
                _refreshUser();
                Navigator.pop(context);
              },
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              const Text(
                                'name: ',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                _displayName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  _isEditing ? Icons.close : Icons.edit,
                                  color: _isEditing ? bottleColour : canColour,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isEditing = !_isEditing;
                                    if (!_isEditing) {
                                      _nameController.text = _displayName;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        if (_isEditing)
                          Container(
                            color: Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                      labelText: 'Name',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: const BorderSide(),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                                      ),
                                      floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    TextButton(
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 3, horizontal: 5)),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4.0),
                                            side: BorderSide(color: bottleColour, width: 1.0),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isEditing = false;
                                          _nameController.text = _displayName;
                                        });
                                      },
                                      child: Text(
                                        'cancel',
                                        style: TextStyle(color: bottleColour, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 3, horizontal: 5)),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4.0),
                                            side: const BorderSide(color: wineColour, width: 1.0),
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        if (_formKey.currentState?.validate() ?? false) {
                                          _updateUserName();
                                        }
                                      },
                                      child: const Text(
                                        'submit',
                                        style: TextStyle(color: wineColour, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'email: ',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          ' ${user?.email ?? ''}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'app Version: ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          _appVersion,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showSignOutConfirmationDialog,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: wineColour,
                      ),
                      child: Text(
                        "sign out",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Anton', fontSize: 50, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: _showDeleteConfirmationDialog,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 00),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: bottleColour,
                      ),
                      child: Text(
                        "delete account",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Anton', fontSize: 40, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
