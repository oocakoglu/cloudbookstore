import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Book"),
        ),
        body: BookList(),
      ),
    );
  }
}

class BookList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BookListState();
}

class _BookListState extends State {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("book").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        } else {
          return _buildBody(context, snapshot.data.documents);
        }
      },
    );

    //return _buildBody(context, dummySnapshot);
  }

  Widget _buildBody(
      //BuildContext context, List<Map<String, String>> dummySnapshot) {
      BuildContext context,
      List<DocumentSnapshot> dummySnapshot) {
    return ListView(
        padding: EdgeInsets.only(top: 20.0),
        children: dummySnapshot
            .map<Widget>((data) => _buildListItem(context, data))
            .toList());
  }
}

//_buildListItem(BuildContext context, Map<String, String> data) {
_buildListItem(BuildContext context, DocumentSnapshot data) {
  //final record = Book.fromMap(data);
  final record = Book.fromSnapshot(data);

  return Padding(
    key: ValueKey(record.author),
    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0)),
      child: ListTile(
          title: Text(record.author + " (" + record.title + ")"),
          trailing: Text("Tick : " + record.read.toString()),
          // onTap: () {
          //   record.reference.updateData({"read":record.read + 1});
          // } 
          onTap: () => Firestore.instance.runTransaction((transaction) async {
            final freshSnapshot = await transaction.get(record.reference);
            final fresh =Book.fromSnapshot(freshSnapshot);
            await transaction.update(record.reference, {'read':fresh.read + 1});
          })
          ),
    ),
  );
}

// class BookList extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: Firestore.instance.collection('book').snapshots(),
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
//         switch (snapshot.connectionState) {
//           case ConnectionState.waiting:
//             return new Text('Loading...');
//           default:
//             return new ListView(
//               children:
//                   snapshot.data.documents.map((DocumentSnapshot document) {
//                 return new ListTile(
//                   title: new Text(document['title']),
//                   subtitle: new Text(document['author']),
//                 );
//               }).toList(),
//             );
//         }
//       },
//     );
//   }
// }

final dummySnapshot = [
  {"author": "Omer Ocak", "title": "Software", "read": "31"},
  {"author": "Erol Parlak", "title": "Service", "read": "30"},
  {"author": "Ahmet Hamarat", "title": "Education", "read": "32"},
  {"author": "Mehmet Sülük", "title": "Judgement", "read": "30"},
  {"author": "Ugur Hamrat", "title": "Transportation", "read": "30"},
];

class Book {
  String author;
  String title;
  int read;
  DocumentReference reference;

  Book.fromMap(Map<String, dynamic> map, {this.reference})
      //:assert(map["author"] != null),
      : author = map["author"],
        title = map["title"],
        read = map["read"]; //int.parse();
//int.parse('12345')
  Book.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Kayit<$title : $author : $read>";
}
