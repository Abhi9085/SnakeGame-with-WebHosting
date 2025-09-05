// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class HighscoreTile extends StatelessWidget {
//   final String documentId;

//   const HighscoreTile({super.key, required this.documentId});

//   @override
//   Widget build(BuildContext context) {
//     CollectionReference highscores =
//         FirebaseFirestore.instance.collection('highscores');

//     return FutureBuilder<DocumentSnapshot>(
//       future: highscores.doc(documentId).get(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const SizedBox.shrink();
//         }

//         if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
//           return const ListTile(
//             title: Text(
//               "Error loading",
//               style: TextStyle(color: Colors.redAccent),
//             ),
//           );
//         }

//         final data = snapshot.data!.data() as Map<String, dynamic>?;

//         // safe fallback values
//         final name = (data?['name'] ?? "Unknown").toString();
//         final score = (data?['score'] ?? 0).toString();

//         return ListTile(
//           title: Text(
//             name,
//             style: const TextStyle(color: Colors.white),
//           ),
//           trailing: Text(
//             score,
//             style: const TextStyle(
//               color: Colors.amber,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HighscoreTile extends StatelessWidget {
  final String documentId;
  const HighscoreTile({Key? key, required this.documentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CollectionReference highscores =
        FirebaseFirestore.instance.collection('highscores');

    return FutureBuilder<DocumentSnapshot>(
      future: highscores.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // return const Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: Text(
          //     "Loading...",
          //     style: TextStyle(color: Colors.white),
          //   ),
          // );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Error loading score",
              style: TextStyle(color: Colors.redAccent),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "No Data",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>? ?? {};

        // Safely get name and score
        String name = data['name']?.toString() ?? 'Anonymous';
        int score = data['score'] is int ? data['score'] : 0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                score.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}
