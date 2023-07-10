import 'package:contacts/ui/add_contact/add_contacts_page.dart';
import 'package:contacts/ui/profile_page.dart';
import 'package:contacts/ui/search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../local/data/db.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  bool isASC = true;
  bool _showOptions = false;
  bool _showsorts = false;

  Future updateScreen() async {
    setState(() {
      _readAllContacts(isASC);
    });
  }

  Future _readAllContacts(bool isASC) async {
    // final contacts =

    return await ContactsDatabase.instance
        .readAllContacts(isASC ? "ASC" : "DESC");
    // setState(() {
    //   _contacts = contacts;
    // });
  }

  @override
  void initState() {
    _readAllContacts(isASC);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.search,
            ),
            color: Colors.black,
          ),
          IconButton(
            color: Colors.black,
            onPressed: () {
              setState(() {
                _showOptions = !_showOptions;
              });
            },
            icon: const Icon(
              Icons.more_vert,
            ),
          ),
        ],
        backgroundColor: Colors.white,
        title: const Text(
          "Contacts",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder(
              future: _readAllContacts(isASC),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final contacts = snapshot.data;
                  // return _buildContactList(contacts!, context);
                  if (contacts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/svg/nothing_box.svg",
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "You have no contacts yet",
                            style:
                                TextStyle(color: Colors.black38, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ListTile(
                          leading: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            height: 60,
                            width: 70,
                            child: CircleAvatar(
                              backgroundImage: AssetImage(
                                contact.imagePth.toString(),
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                  child: Text(contact.name,
                                      overflow: TextOverflow.ellipsis)),
                              const SizedBox(
                                width: 5,
                              ),
                              Flexible(
                                child: Text(contact.surname,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          subtitle: Text(contact.phoneNumber),
                          trailing: IconButton(
                              onPressed: () async {
                                // print(contact.imagePth);
                                final nnumber =
                                    contact.phoneNumber.replaceAll(' ', '');
                                final number = nnumber.replaceAll(')', '');
                                final number1 = number.replaceAll('(', '');
                                final number2 = number1.replaceAll('-', '');
                                await FlutterPhoneDirectCaller.callNumber(
                                    number2);
                              },
                              icon: SvgPicture.asset("assets/svg/phone.svg")),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    // Rassmmm(
                                    //       id: contact.id,
                                    //     )
                                    ProfilePage(
                                  forSearch: false,
                                  idd: contact.id,
                                  isUpdated: updateScreen,
                                ),
                              ),
                            );
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         UpdatePage(id: contact.id),
                            //   ),
                            // );
                            print(contact.id);
                            // Perform an action when the contact is tapped.
                            // For example, navigate to a contact details page.
                            // You can access the contact's properties using `contact.name`, `contact.surname`, etc.
                          },
                        );
                      },
                    );
                  }
                }

                //
              },
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: AnimatedOpacity(
              opacity: _showsorts ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: ClipRRect(
                child: AnimatedContainer(
                  height: _showsorts ? 120.0 : 0.0,
                  width: _showsorts ? 150.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    color: Colors.white,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text('A-Z'),
                            onTap: () {
                              setState(() {
                                isASC = true;
                                _showsorts = false;
                              });
                              // Perform sorting logic
                            },
                          ),
                          ListTile(
                            title: const Text('Z-A'),
                            onTap: () {
                              setState(() {
                                isASC = false;
                                _showsorts = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: AnimatedOpacity(
              opacity: _showOptions ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: AnimatedContainer(
                height: _showOptions ? 120.0 : 0.0,
                width: _showOptions ? 150.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Sort'),
                          onTap: () {
                            setState(() {
                              _showsorts = !_showsorts;
                              _showOptions = false;
                            });
                            // Perform sorting logic
                          },
                        ),
                        ListTile(
                          title: const Text('Delete All'),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete All Data'),
                                  content: const Text(
                                      'Are you sure you want to delete everything?'),
                                  actions: [
                                    TextButton(
                                      child: const Text('No'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Yes'),
                                      onPressed: () {
                                        setState(() {
                                          _deleteAllContacts();
                                          _showOptions = false;
                                        });
                                        // Perform deletion logic
                                        // ...
                                        Navigator.of(context).pop();

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Barcha Contactlar O'chirildi",
                                            ),
                                          ),
                                        );
                                        // Close the dialog
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddContactPage(isUpdated: updateScreen),
              ),
            );
          },
          child: const Icon(Icons.add)),
    );
  }
}

// Widget _buildContactList(List<Contact> contacts, BuildContext context) {}

Future<void> _deleteAllContacts() async {
  try {
    await ContactsDatabase.instance.deleteAllContacts();
    // Show success message (optional)
  } catch (e) {
    // Show error message (optional)
  }
}
