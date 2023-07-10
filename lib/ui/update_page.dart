import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:masked_text/masked_text.dart';

import '../local/data/db.dart';

class UpdatePage extends StatefulWidget {
  int? id;

  AsyncCallback? isUpdated;
  UpdatePage({super.key, this.isUpdated, this.id});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  Contact? a;
  @override
  void initState() {
    super.initState();
    showingContacts();
  }

  showingContacts() async {
    Contact? cont =
        await ContactsDatabase.instance.getContactById(widget.id!.toInt());
    if (cont != null) {
      _nameController.text = cont.name;
      _surnameController.text = cont.surname;
      _phoneController.text = cont.phoneNumber;
      setState(() {
        a = cont;
      });
    }
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
              controller: _phoneController,
              mask: "+998 (##) ###-##-##",
              // maxLength: 19,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "+998 (__) ___-__-__",
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
                onPressed: () async {
                  final yangii = Contact(
                    id: widget.id,
                    name: _nameController.text,
                    surname: _surnameController.text,
                    phoneNumber: _phoneController.text, imagePth: a!.imagePth,
                  );
                  await ContactsDatabase.instance
                      .updateContactById( yangii);

                  setState(() {
                    print("updated : $_nameController");
                  });

                  widget.isUpdated!.call();
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }, // Call the create contact function
                child: const Text("Update Contact"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
