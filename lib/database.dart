import 'dart:math';

import 'package:drift/drift.dart';
import 'dart:io';

// These imports are used to open the database
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;


part 'database.g.dart';


// Splitting a task list into completed and non-completed tasks
extension TaskPartition on List<Task> {
  Map<String, List<Task>> separateCompleted() => {
    "tasks": where((t) => !t.isDone!).toList(),
    "completedTasks": where((t) => t.isDone!).toList(),
  };
}

@DriftDatabase(
  include: {'tables.drift'}
)
class AppDB extends _$AppDB{
  AppDB() : super(_openConnection());


  Stream<Map<dynamic, int>> watchTaskCountPerList() {
    return select(tasks).watch().map((allTasks) {
      
      final Map<dynamic, int> counts = {};

      for (final task in allTasks) {
        if (task.parentId != null) continue; // Skip subtasks

        final inMyDay = task.addedToMyDay ?? false;
        final starred = task.isStarred ?? false;

        if (inMyDay || task.listsId == 1) {
          counts["myday"] = (counts["myday"] ?? 0) + 1;
        }

        if (starred || task.listsId == 2) {
          counts["starred"] = (counts["starred"] ?? 0) + 1;
        }
        
        counts[task.listsId!] = (counts[task.listsId] ?? 0) + 1;
      }

      return counts;
    });
  }


  Stream<List<TodoList>> watchUserLists() {
    return (select(todoLists)..where((t) => t.id.isBiggerThanValue(3))).watch();
  }

  Stream<List<Task>> watchTasks() {
    return select(tasks).watch();
  }

  // "Regular"" List
  Stream<List<Task>> watchTasksByListId(int listId) {
    return (select(tasks)..where((t) => t.listsId.equals(listId) & t.parentId.isNull() )).watch();
  }

  // MyDay
  Stream<List<Task>> watchMyDayTasks() {
    return (select(tasks)..where((t) => t.addedToMyDay.equals(true) & t.parentId.isNull() )).watch();
  }

  // Important/Starred
  Stream<List<Task>> watchStarredTasks() {
    return (select(tasks)..where((t) => t.isStarred.equals(true) & t.parentId.isNull() )).watch();
  }


  Stream<List<Task>> watchTaskByIdWithSubTasks(int id) {
    return (select(tasks)..where((t) => t.id.equals(id) | t.parentId.equals(id) )).watch();
  }



  Future<void> insertTask(
    {
      required int listID, //! Maybe just default to "Tasks" if none were specified
      required String title,
      required int position,
      bool? addedToMyDay, // in case we are adding from "My Day".
      bool? isStarred, // in case we are adding from "Important".
      int? parentID, //NULL == parent task
    }

    ) async {
      
      final now = DateTime.now();

      await transaction(() async {
        
        await into(tasks).insert(
          TasksCompanion(
            listsId: Value(listID),
            title: Value(title),
            addedToMyDay: Value(addedToMyDay),
            isStarred: Value(isStarred),
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
      Value<bool>? addedToMyDay,
      Value<bool>? isStarred,
      Value<DateTime?>? reminder,
      Value<DateTime?>? dueDate,
      Value<String?>? repeat,
      Value<String?>? notes,
      Value<int>? position,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAT,
    }) async {
      
      final now = DateTime.now();

      await transaction(() async {
        await (update(tasks)..where((t) => t.id.equals(id))).write(
          TasksCompanion(
            title: title ?? const Value.absent(),
            isDone: isDone ?? const Value.absent(),
            addedToMyDay: addedToMyDay ?? const Value.absent(),
            isStarred: isStarred ?? const Value.absent(),
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

  Future<void> copyingTasksToList({
    required int fromListID,
    required int toListID
  }) async {

    final List<Task> tasksToDuplicate = await (select(tasks)..where((task) => task.listsId.equals(fromListID))).get();

    DateTime now = DateTime.now();


    await batch((b) {
      b.insertAll(
        tasks,
        tasksToDuplicate.map((row) => TasksCompanion.insert(
          title: row.title,
          listsId: Value(toListID),
          isDone: Value(row.isDone),
          addedToMyDay: Value(row.addedToMyDay),
          isStarred: Value(row.isStarred),
          reminder: Value(row.reminder),
          dueDate: Value(row.dueDate),
          repeat: Value(row.repeat),
          notes: Value(row.notes),
          position: row.position,
          createdAt: Value(now),
          updatedAt: Value(now),
        ))
      );
    });
    
  }

  Future<void> updateList(
    int id,{
    Value<String>? name,
    Value<int>? position,
  }) async {

    await transaction(() async {
        await (update(todoLists)..where((list) => list.id.equals(id))).write(
          TodoListsCompanion(
            name: name ?? const Value.absent(),
            position: position ?? const Value.absent(),
          ),
        );
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
            TodoListsCompanion.insert(name: Value("Myday"), position: 1),
            TodoListsCompanion.insert(name: Value("Important"), position: 2),
            TodoListsCompanion.insert(name: Value("Tasks"), position: 3),
          ]);
        });
      },
      //! When data matters and I want to add new columns, dont forget to change schemaversion as well. (Example)
      // onUpgrade: (m, from, to) async {
      //   if (from < 2) {
      //     await m.addColumn(todoLists, todoLists.position);
      //   }
      // }
    );
  }

}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db_v2.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}