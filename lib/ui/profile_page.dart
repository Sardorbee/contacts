import 'package:contacts/ui/contacts_page.dart';
import 'package:contacts/ui/update_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../local/data/db.dart';

// ignore: must_be_immutable
class ProfilePage extends StatefulWidget {
  bool? forSearch;
  AsyncCallback? isUpdated;
  int? idd;
  ProfilePage({super.key, this.idd, this.isUpdated, this.forSearch});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Contact? contact;
  String? name;
  String? surname;
  String? phone;
  String? imagePath;
  @override
  void initState() {
    super.initState();
    getContactById();
    // widget.isUpdated!.call();
  }

  Future<void> getContactById() async {
    final contacts =
        await ContactsDatabase.instance.readContact(widget.idd!.toInt());
    setState(() {
      name = contacts!.name;
      surname = contacts.surname;
      phone = contacts.phoneNumber;
      imagePath = contacts.imagePth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);

              widget.isUpdated!.call();
            }),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(
                        width: 80,
                      ),
                      Container(
                        margin: const EdgeInsets.all(1),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        // height: 100,
                        // width: 150,
                        child: FutureBuilder<Contact?>(
                          future: ContactsDatabase.instance
                              .readContact(widget.idd!.toInt()),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text(
                                  ''); // Display a loading indicator
                            } else if (snapshot.hasError) {
                              return Text(
                                  'Error: ${snapshot.error}'); // Display an error message
                            } else if (snapshot.hasData &&
                                snapshot.data != null) {
                              final cc = snapshot.data!;
                              return CircleAvatar(
                                  radius: 80,
                                  backgroundImage: AssetImage(cc.imagePth),
                                  backgroundColor: Colors.red,
                                  child: const Text(''));
                            } else {
                              return const Text('Contact not found');
                            }
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Delete Contact'),
                                    content: const Text(
                                        'Are you sure you want to delete this Contact?'),
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
                                            _deleteOneContact(widget.idd);
                                            widget.isUpdated!.call();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Text(
                                                  'Contact Deleted Successfully',
                                                ),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                            
                                          });
                                          Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => ContactsPage(),),
                                                (route) => false);
                                          // Perform deletion logic
                                          // ...

                                          // Close the dialog
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(
                              Icons.delete,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdatePage(
                                    id: widget.idd,
                                    isUpdated: getContactById,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.edit,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Flexible(
                  child: Text(
                    name.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Flexible(
                  child: Text(
                    surname.toString(),
                    overflow: TextOverflow.ellipsis,
                
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
              const SizedBox(
                height: 12,
              ),
              ListTile(
                title: Text(
                  phone.toString(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                trailing: SizedBox(
                  width: 95,
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 9),
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(
                            40,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            final nnumber = phone!.replaceAll(' ', '');
                            final number = nnumber.replaceAll(')', '');
                            final number1 = number.replaceAll('(', '');
                            final number2 = number1.replaceAll('-', '');
                            await FlutterPhoneDirectCaller.callNumber(number2);
                          },
                          icon: SvgPicture.asset(
                            "assets/svg/phone.svg",
                            // ignore: deprecated_member_use
                            color: Colors.white,
                            height: 150,
                          ),
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xffE9AD13),
                          borderRadius: BorderRadius.circular(
                            40,
                          ),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            Future<void> makesms(String phoneNumber) async {
                              final Uri launchUri = Uri(
                                scheme: 'sms',
                                path: phoneNumber,
                              );
                              await launchUrl(launchUri);
                            }

                            makesms(phone.toString());
                          },
                          icon: const Icon(
                            Icons.message,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _deleteOneContact(id) async {
  await ContactsDatabase.instance.deleteOne(id);
}
