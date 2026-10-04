import 'package:flashi/data/services/api_client.dart';
import 'package:flashi/data/study_repository.dart';

class SyncService {
  final ApiClient api;
  final StudyRepository repository;
  int _cursor = 0;

  SyncService(this.api, this.repository);

  Future<void> sync() async {
    final pending = await repository.pendingChanges('user');
    if (pending.isNotEmpty) {
      final response = await api.post(
        '/api/v1/sync',
        body: {'changes': pending.map((e) => e.toApi()).toList()},
      );
      final accepted = response['accepted'];
      if (accepted is List) {
        for (final ack in accepted) {
          if (ack is! Map) continue;
          final id = ack['id']?.toString();
          final revision = (ack['revision'] as num?)?.toInt();
          if (id == null || revision == null) continue;
          PendingChange? sent;
          for (final change in pending) {
            if (change.entityId == id) {
              sent = change;
              break;
            }
          }
          if (sent != null) {
            await repository.acknowledge(
              'user',
              id,
              revision,
              sent.localVersion,
            );
          }
        }
      }
    }

    while (true) {
      final response = await api.get(
        '/api/v1/sync?cursor=$_cursor',
        authenticated: true,
      );
      final entities = response['entities'];
      if (entities is List) {
        for (final entity in entities) {
          if (entity is! Map) continue;
          final map = Map<String, dynamic>.from(entity);
          await repository.applyRemote(
            id: map['id'].toString(),
            entityType: map['entityType'].toString(),
            deleted: map['deleted'] == true,
            payload: map['payload'] is Map
                ? Map<String, dynamic>.from(map['payload'] as Map)
                : null,
          );
        }
      }
      _cursor = (response['cursor'] as num?)?.toInt() ?? _cursor;
      if (response['hasMore'] != true) break;
    }
  }
}
