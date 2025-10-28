import 'package:drift/drift.dart';


part 'database.g.dart';


class TodoItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 6, max: 30)();
  TextColumn get content => text().named("body")();
  DateTimeColumn get createdAt => dateTime().nullable()();

}

@DriftDatabase(
  include: (tables.drift)
)
class AppDatabase extends _$AppDatabase{

  
}