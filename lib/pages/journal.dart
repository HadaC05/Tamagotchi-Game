import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tamago/components/appbar.dart';

class JournalListPage extends StatefulWidget {
  const JournalListPage({super.key});

  @override
  _JournalListPageState createState() => _JournalListPageState();
}

class _JournalListPageState extends State<JournalListPage> {
  @override
  Widget build(BuildContext context) {
    var usersBox = Hive.box('users');
    Map userData =
        usersBox.get('user_data', defaultValue: {"journalEntries": []});
    List journals = userData['journalEntries'];

    return Scaffold(
      appBar: CustomAppBar(title: 'Journal Entries'),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 219, 242, 114),
              Color.fromARGB(255, 153, 227, 6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: journals.isEmpty
              ? Center(
                  child: Text(
                    "No journal entries yet!",
                    style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  ),
                )
              : ListView.builder(
                  itemCount: journals.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            spreadRadius: 2,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            journals[index]['date'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            journals[index]['content'],
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Function to add a new journal entry
        },
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
