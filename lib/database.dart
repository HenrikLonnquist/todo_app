import 'package:drift/drift.dart';
import 'dart:io';

// These imports are used to open the database
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;


part 'database.g.dart';

@DriftDatabase(
  include: {'tables.drift'}
)
class AppDB extends _$AppDB{
  AppDB() : super(_openConnection());

  Stream<List<TodoList>> watchLists() {
    return select(todoLists).watch();
  }

  //! What to do you call these? Just methods? Maybe ask gipity - Check chat = Modify database... or Flutter Data...
  Stream<List<Task>> watchTasks() {
    return select(tasks).watch();
  }

  Stream<List<Task>> watchTasksById(int id) {
    return (select(tasks)..where((t) => t.id.equals(id))).watch();
  }

  Stream<Task?> watchTaskById(int id) {
    return (select(tasks)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<void> updateTaskDone(int id, bool done) {
    return customUpdate("UPDATE tasks SET is_done = ? WHERE id = ?",
    variables: [
      Variable<int>(done ? 1 : 0),
      Variable<int>(id),
    ],
    updates: {tasks}
    );
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();

        await batch((b) {
          b.insertAll(todoLists, [
            TodoListsCompanion.insert(name: Value("Myday")),
            TodoListsCompanion.insert(name: Value("Important")),
            TodoListsCompanion.insert(name: Value("Tasks")),
          ]);
        });
      }
    );
  }

}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}