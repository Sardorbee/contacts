import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ContactsDatabase {
  final random = Random();

  static final ContactsDatabase instance = ContactsDatabase._init();

  static Database? _database;

  ContactsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('contacts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        surname TEXT,
        phoneNumber TEXT,
        imagePth TEXT
      )
    ''');
  }

  Future<Contact?> create(Contact contact) async {
    final db = await instance.database;
    await db.insert('Contacts', contact.toMap());
  }

  Future<Contact?> getContactById(int? id) async {
    final db = await instance.database;
    final maps = await db.query(
      'Contacts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Contact(
        id: maps.first['id'] as int?,
        name: maps.first['name'] as String,
        surname: maps.first['surname'] as String,
        phoneNumber: maps.first['phoneNumber'] as String,
        imagePth: maps.first['imagePth'] as String,
      );
    } else {
      return null;
    }
  }

  Future<void> update(Contact contact) async {
    final db = await instance.database;
    await db.update(
      'Contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> updateContactById(Contact updatedContact) async {
    final db = await instance.database;
    return await db.update(
      'Contacts',
      updatedContact.toMap(),
      where: 'id = ?',
      whereArgs: [updatedContact.id],
    );
  }

  Future<void> deleteAllContacts() async {
    final db = await instance.database;
    await db.delete('Contacts');
  }

  Future<void> deleteOne(int id) async {
    final db = await instance.database;
    await db.delete(
      'Contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Contact>> searchContacts(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'Contacts',
      where: 'name LIKE ? OR surname LIKE ? OR phoneNumber LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return result
        .map((map) => Contact(
              id: map['id'] as int?,
              name: map['name'] as String,
              surname: map['surname'] as String,
              phoneNumber: map['phoneNumber'] as String,
              imagePth: map['imagePth'] as String,
            ))
        .toList();
  }

  Future<List<Contact>> readAllContacts(String ascOrDesc) async {
    final db = await instance.database;
    final orderBy = 'name $ascOrDesc';
    final result = await db.query('Contacts', orderBy: orderBy);
    return result
        .map((map) => Contact(
              id: map['id'] as int?,
              name: map['name'] as String,
              surname: map['surname'] as String,
              phoneNumber: map['phoneNumber'] as String,
              imagePth: map['imagePth'] as String,
            ))
        .toList();
  }

  Future<Contact?> readContact(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'Contacts',
      columns: ['id', 'name', 'surname', 'phoneNumber', 'imagePth'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Contact(
        id: maps.first['id'] as int?,
        name: maps.first['name'] as String,
        surname: maps.first['surname'] as String,
        phoneNumber: maps.first['phoneNumber'] as String,
        imagePth: maps.first['imagePth'] as String,
      );
    } else {
      null; // throw Exception('Contact not found!');
    }
  }
}
// 'assets/image/${random.nextInt(26) + 1}.jpg'

class Contact {
  final int? id;
  final String name;
  final String surname;
  final String phoneNumber;
  final String imagePth;

  Contact({
    this.id,
    required this.name,
    required this.surname,
    required this.phoneNumber,
    required this.imagePth,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'phoneNumber': phoneNumber,
      'imagePth': imagePth,
    };
  }
}
