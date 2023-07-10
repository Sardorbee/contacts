import 'dart:math';

import 'package:contacts/local/data/db.dart';
import 'package:contacts/ui/add_contact/jpg_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:masked_text/masked_text.dart';

class AddContactPage extends StatefulWidget {
  AsyncCallback isUpdated;
  AddContactPage({
    super.key,
    required this.isUpdated,
  });

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final random = Random();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _surnameFocusNode = FocusNode();
  FocusNode _phoneNumberFocusNode = FocusNode();

  String imagePath = '';

  Future<void> _createContact() async {
    final name = _nameController.text;
    final surname = _surnameController.text;
    final phoneNumber = "+998 ${_phoneController.text}";

    // Validate input fields (optional)
    if (name.isEmpty || surname.isEmpty || phoneNumber.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please fill in all fields.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Create the contact
    final contact = Contact(
      name: name,
      surname: surname,
      phoneNumber: phoneNumber,
      imagePth: imagePath as String,
    );

    try {
      // Save the contact to the database
      await ContactsDatabase.instance.create(contact);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Contact Created Successfully',
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Show success message (optional)
      // ignore: use_build_context_synchronously
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString()),
          duration: const Duration(seconds: 2),
        ),
      );

      // Show error message (optional)
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            color: Colors.black,
            Icons.arrow_back,
          ),
        ),
        backgroundColor: Colors.white,
        title: const Text(
          "Add",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Name"),
            const SizedBox(
              height: 10,
            ),
            TextField(
              focusNode: _nameFocusNode,
              textInputAction: TextInputAction.next,
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter Name",
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text("Surname"),
            const SizedBox(
              height: 10,
            ),
            TextField(
              textInputAction: TextInputAction.next,
              focusNode: _surnameFocusNode,
              controller: _surnameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter Surname",
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text("Phone Number"),
            const SizedBox(
              height: 10,
            ),
            MaskedTextField(
              textInputAction: TextInputAction.done,

              focusNode: _phoneNumberFocusNode,
              controller: _phoneController,
              mask: "(##) ### - ## - ##",
              // maxLength: 19,
              decoration: InputDecoration(
                prefixIcon: Container(
                    padding: const EdgeInsets.only(top: 14.5, left: 7),
                    child: const Text(
                      '+998',
                      style: TextStyle(fontSize: 16),
                    )),
                border: const OutlineInputBorder(),
                hintText: "(_ _) _ _ _-_ _-_ _",
              ),

              keyboardType: TextInputType.number,
            ),
            // TextField(
            //   controller: _phoneController,
            //   maxLength: 9,
            //   keyboardType: TextInputType.phone,
            //   inputFormatters: [
            //     maskFormatter
            //   ],
            //   decoration: const InputDecoration(
            //     border: OutlineInputBorder(),
            //     hintText: "Enter Phone Number",
            //   ),
            // ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: Container(
                          width: 350, // Specify the desired width
                          height: 600, // Specify the desired height
                          child: GridView.builder(
                            itemCount: jpgFileNames.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                            itemBuilder: (context, index) => Container(
                                child: InkWell(
                              onTap: () {
                                setState(() {
                                  imagePath = jpgFileNames[index];
                                });
                                print(imagePath);
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                height: 100,
                                width: 100,
                                child: Image.asset(jpgFileNames[index]),
                              ),
                            )),
                          ),
                        ),
                      );
                    },
                  );
                }, // Call the create contact function
                child: const Text("Choose Picture"),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (imagePath!.isNotEmpty &&
                      _nameController.text.isNotEmpty &&
                      _surnameController.text.isNotEmpty &&
                      _phoneController.text.length == 18) {
                    _createContact();
                    widget.isUpdated.call();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            "Hamma Qatorlar to'ldirilib rasm tanlaganingizga ishonch hosil qiling")));
                  }
                }, // Call the create contact function
                child: const Text("Create Contact"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
