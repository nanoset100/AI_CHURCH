import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/public_sermon_model.dart';

typedef SermonPage = ({List<PublicSermonModel> sermons, bool fromCache});

class SermonService {
  static Future<SermonPage> published(
      {required int limit, String? region}) async {
    final now = Timestamp.now();
    var query = FirebaseFirestore.instance
        .collection('public_sermons')
        .where('isPublic', isEqualTo: true);
    if (region != null) {
      query = query.where('region', isEqualTo: region);
    }
    final ordered = query.orderBy('broadcastDate', descending: true);
    try {
      final snap = await ordered
          .where('broadcastDate', isLessThanOrEqualTo: now)
          .limit(limit)
          .get();
      return (
        sermons: snap.docs.map(PublicSermonModel.fromFirestore).toList(),
        fromCache: snap.metadata.isFromCache
      );
    } on FirebaseException catch (e) {
      if (e.code != 'failed-precondition') rethrow;
      // Some deployments only have the original public/date index.
      final results = <PublicSermonModel>[];
      var page = ordered.limit(limit);
      var fromCache = false;
      while (results.length < limit) {
        final snap = await page.get();
        fromCache = fromCache || snap.metadata.isFromCache;
        for (final doc in snap.docs) {
          final date = doc.data()['broadcastDate'];
          if (date is Timestamp && date.compareTo(now) <= 0) {
            results.add(PublicSermonModel.fromFirestore(doc));
            if (results.length == limit) break;
          }
        }
        if (snap.docs.length < limit) break;
        page = ordered.startAfterDocument(snap.docs.last).limit(limit);
      }
      return (sermons: results, fromCache: fromCache);
    }
  }
}
