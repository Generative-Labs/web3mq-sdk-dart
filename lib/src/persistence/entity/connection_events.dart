// coverage:ignore-file

import 'package:drift/drift.dart';

import '../converter/map_converter.dart';

@DataClassName('ConnectionEventEntity')
class ConnectionEvents extends Table {
  /// event id
  IntColumn get id => integer()();

  /// event type
  TextColumn get type => text()();

  /// User object of the current user
  TextColumn get ownUser => text().nullable().map(MapConverter())();

  /// The number of unread messages for current user
  IntColumn get totalUnreadCount => integer().nullable()();

  /// User total unread channels for current user
  IntColumn get unreadChannels => integer().nullable()();

  /// DateTime of the last event
  DateTimeColumn get lastEventAt => dateTime().nullable()();

  /// DateTime of the last sync
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
