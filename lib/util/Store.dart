import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> updateFavorites(String uid, List<String> favorites) {
  DocumentReference favoritesReference =
      Firestore.instance.collection('users').document(uid);

  return Firestore.instance.runTransaction((Transaction tx) async {
    DocumentSnapshot postSnapshot = await tx.get(favoritesReference);

    if (postSnapshot.exists) {
      await tx.update(favoritesReference,
          <String, dynamic>{'favorites': favorites.toString()});
    } else {
      await tx.set(favoritesReference, {'favorites': favorites.toString()});
    }
  }).then((result) {
    return true;
  }).catchError((error) {
    print('Error: $error');

    return false;
  });
}

Future<List<String>> getFavorites(String uid) async {
  DocumentSnapshot querySnapshot = await Firestore.instance
      .collection('users')
      .document(uid)
      .get();

  if (querySnapshot.exists &&
      querySnapshot.data.containsKey('favorites')) {
    // Create a new List<String> from List<dynamic>

    String str = querySnapshot.data['favorites'].replaceAll('[' , '').replaceAll(']' , '');

    return str.length > 0 ? str.split(',') : [];
  }

  return [];
}
