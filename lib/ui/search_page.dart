import 'package:contacts/ui/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../local/data/db.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Contact> _contacts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshContacts() async {
    final contacts = await ContactsDatabase.instance.readAllContacts("ASC");
    setState(() {
      _contacts = contacts;
    });
  }

  void _searchContacts(String query) async {
    final contacts = await ContactsDatabase.instance.searchContacts(query);
    setState(() {
      _contacts = contacts;
    });
  }

  void _handleSearch(String value) {
    if (value.isEmpty) {
      _refreshContacts();
    } else {
      _searchContacts(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon:const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
        backgroundColor: Colors.white,
        title: TextField(
          controller: _searchController,
          onChanged: _handleSearch,
          decoration: InputDecoration(
            hintText: 'Search',
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _handleSearch('');
              },
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return ListTile(
            leading: SvgPicture.asset("assets/svg/profile.svg"),
            title: Row(
              children: [
                Text(contact.name),
                const SizedBox(
                  width: 5,
                ),
                Text(contact.surname),
              ],
            ),
            subtitle: Text(contact.phoneNumber),
            trailing: SvgPicture.asset("assets/svg/phone.svg"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(
                    idd: contact.id,
                    forSearch: true,
                    isUpdated: () async {
                      
                    },
                  ),
                ),
              );
              // Perform an action when the contact is tapped.
              // For example, navigate to a contact details page.
              // You can access the contact's properties using `contact.name`, `contact.surname`, etc.
            },
          );
        },
      ),
    );
  }
}
