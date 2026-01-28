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

  Stream<List<Task>> watchTasks() {
    return select(tasks).watch();
  }

  Stream<List<Task>> watchTasksByListId(int listId) {
    return (select(tasks)..where((t) => t.listsId.equals(listId) & t.parentId.isNull() )).watch();
  }

  Stream<List<Task>> watchTaskByIdWithSubTasks(int id) {
    return (select(tasks)..where((t) => t.id.equals(id) | t.parentId.equals(id) )).watch();
  }

  //! Seems to work on linux.
  Future<void> updateTaskDone(int id, bool done) {
    return customUpdate("UPDATE tasks SET is_done = ?, updated_at = ? WHERE id = ?",
    variables: [
      Variable<int>(done ? 1 : 0),
      Variable(DateTime.now()),
      Variable<int>(id),
    ],
    updates: {tasks}
    );
  }

  Future<void> updateTaskTitle(int id, String title) {
    return customUpdate("UPDATE tasks SET title = ?, updated_at = ? WHERE id = ?",
    variables: [
      Variable.withString(title),
      Variable(DateTime.now()),
      Variable.withInt(id),
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