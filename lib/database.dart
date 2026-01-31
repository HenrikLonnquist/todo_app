import 'dart:math';

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

  Stream<List<TodoList>> watchUserLists() {
    return (select(todoLists)..where((t) => t.id.isBiggerThanValue(2))).watch();
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

  Future<void> insertTask(
    {
      required int listID,
      required String title,
      required int position,
      int? parentID, //NULL == parent task
    }

    ) async {
      
      final now = DateTime.now();

      await transaction(() async {
        
        await into(tasks).insert(
          TasksCompanion(
            listsId: Value(listID),
            title: Value(title),
            position: Value(position),
            parentId: Value(parentID),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

        if (parentID != null) {
          await customUpdate("UPDATE tasks SET updated_at = ? WHERE id = ?",
          variables: [
            Variable(now),
            Variable.withInt(parentID),
          ],
          updates: {tasks}
          );
        }

      });
          
  }
  Future<void> updateTask(
    int id,{
      int? parentID,
      Value<int>? listID,
      Value<String>? title,
      Value<bool>? isDone,
      Value<DateTime>? reminder,
      Value<DateTime>? dueDate,
      Value<String>? repeat,
      Value<String>? notes,
      Value<int>? position,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAT
    }) async {
      
      final now = DateTime.now();

      await transaction(() async {
        await (update(tasks)..where((t) => t.id.equals(id))).write(
          TasksCompanion(
            title: title ?? const Value.absent(),
            isDone: isDone ?? const Value.absent(),
            reminder: reminder ?? const Value.absent(),
            dueDate: dueDate ?? const Value.absent(),
            repeat: repeat ?? const Value.absent(),
            notes: notes ?? const Value.absent(),
            position: position ?? const Value.absent(),
            updatedAt: Value(now),
          ),
        );

        if (parentID != null) {
          await customUpdate("UPDATE tasks SET updated_at = ? WHERE id = ?",
          variables: [
            Variable(now),
            Variable.withInt(parentID),
          ],
          updates: {tasks}
          );
        }

      });
          
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