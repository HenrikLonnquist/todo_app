// This is an example unit test.
//
// A unit test tests a single function, method, or class. To learn more about
// writing unit tests, visit
// https://flutter.dev/docs/cookbook/testing/unit/introduction

import 'dart:ffi';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/database.dart';
import "package:drift/native.dart";
import 'package:sqlite3/open.dart';


Future<void> persistMove(AppDB db, Task task, int? prev, int? next, int? prevID, int? nextID) async {

  int newPosition;

  if (prev == null) {
    print("no top neighbor");
    newPosition = (next! / 2).round();
  } else if (next == null) {
    print("no bottom neighbor");
    newPosition = prev + 1000;
  } else {
    newPosition = ((prev + next) / 2).round();
    if ( (newPosition - prev).abs() <= 10 || (next - newPosition).abs() <= 10 ) {
      
      print("renormalize tasks position");
      final (int prevNewPos, int nextNewPos) = await db.renormalizeAllTaskPosition(prevID, nextID);
      return persistMove(db, task, prevNewPos, nextNewPos, null, null);
    }
  }
  print("update task position");
  return db.updateTask(
    task.id,
    position: Value(newPosition),
  );
}


void main() {

  open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));

  late AppDB db;

  setUp(() {
    db = AppDB.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test("renormalize returns correct neighbor positions", () async {
    final listID = await db.into(db.todoLists).insertReturning(TodoListsCompanion(
      // id: Value(1234),
      name: Value("test_list"),
      position: Value(1234),
    ));

    final t1 = await db.into(db.tasks).insertReturning(TasksCompanion(
      listsId: Value(listID.id),
      title: Value("tst1"),
      position: Value(1000),
    ));
    final t2 = await db.into(db.tasks).insertReturning(TasksCompanion(
      listsId: Value(listID.id),
      title: Value("tst2"),
      position: Value(1001),
    ));
    final t3 = await db.into(db.tasks).insertReturning(TasksCompanion(
      listsId: Value(listID.id),
      title: Value("tst3"),
      position: Value(1002),
    ));


    final (prevPos, nextPos) = await db.renormalizeAllTaskPosition(t1.id, t3.id);

    expect(prevPos, 1000);
    expect(nextPos, 3000);

  });

  test("renormalize spaces positions correctly", () async {

    // insert two lists with tasks that have messsy positions
    final listID1 = await (db.into(db.todoLists).insertReturning(TodoListsCompanion(
      name: Value("testList1"),
      position: Value(1000),
    )));
    final listID2 = await (db.into(db.todoLists).insertReturning(TodoListsCompanion(
      name: Value("testList2"),
      position: Value(2000),
    )));

    await db.insertTask(listID: listID1.id, title: "test1", position: 1);
    await db.insertTask(listID: listID1.id, title: "test2", position: 2);
    await db.insertTask(listID: listID1.id, title: "test3", position: 3);

    await db.insertTask(listID: listID2.id, title: "test1", position: 1);
    await db.insertTask(listID: listID2.id, title: "test1", position: 2);

    await db.renormalizeAllTaskPosition(null, null);


    // check list 1
    final list1Tasks = await (db.select(db.tasks)
    ..where((t) => t.listsId.equals(listID1.id))
    ..orderBy([(t) => OrderingTerm.asc(t.position)])
    ).get();

    for (int i = 0; i < list1Tasks.length; i++) {
      expect(list1Tasks[i].position, (i +1) * 1000);
    }


    // check list 2
    final list2Tasks = await (db.select(db.tasks)
    ..where((t) => t.listsId.equals(listID2.id))
    ..orderBy([(t) => OrderingTerm.asc(t.position)])
    ).get();

    for (int i = 0; i < list2Tasks.length; i++) {
      expect(list2Tasks[i].position, (i +1) * 1000);
    }

  });


  test("persistMove calculates midpoint correctly", () async {
    final listID = await db.into(db.todoLists).insertReturning(TodoListsCompanion(
      name: Value("testList1"),
      position: Value(1000),
    ));

    await db.insertTask(listID: listID.id, title: "test1", position: 1000);
    await db.insertTask(listID: listID.id, title: "test3", position: 3000);

    final tasks = await (db.select(db.tasks)
    ..where((t) => t.listsId.equals(listID.id))
    ..orderBy([(t) => OrderingTerm.asc(t.position)]))
    .get();

    // move task at position 3000 between nothing and 1000 — midpoint should be 2000
    await persistMove(db, tasks[1], 1000, 3000, null, null);

    final updated = await (db.select(db.tasks)
    ..where((t) => t.id.equals(tasks[1].id)))
    .getSingle();


    expect(updated.position, 2000);

  });

  test("persistMove handles no top neighbor", () async {
    final listID = await db.into(db.todoLists).insertReturning(TodoListsCompanion(
      name: Value("testList"),
      position: Value(1000),
    ));

    await db.insertTask(listID: listID.id, title: "test1", position: 2000);
    
    final tasks = await (db.select(db.tasks)
    ..where((t) => t.listsId.equals(listID.id)))
    .get();

    // no prev neighbor, should be half of next
    await persistMove(db, tasks[0], null, 2000, null, null);

    final updated = await (db.select(db.tasks)
    ..where((t) => t.id.equals(tasks[0].id)))
    .getSingle();

    expect(updated.position, 1000);

  });

  test("persistMove handles no bottom neighbor", () async {
    final listID = await db.into(db.todoLists).insertReturning(TodoListsCompanion(
      name: Value("testList"),
      position: Value(1000),
    ));

    await db.insertTask(listID: listID.id, title: "test1", position: 1000);
    
    final tasks = await (db.select(db.tasks)
    ..where((t) => t.listsId.equals(listID.id)))
    .get();

    // no next neighbor, should be prev + 1000
    await persistMove(db, tasks[0], 1000, null, null, null);

    final updated = await (db.select(db.tasks)
    ..where((t) => t.id.equals(tasks[0].id)))
    .getSingle();

    expect(updated.position, 2000);

  });


  test("persistMove triggers renormalize when gap is too small", () async {
    final listID = await db.into(db.todoLists).insertReturning(TodoListsCompanion(
      name: Value("testList"),
      position: Value(1000),
    ));

    await db.insertTask(listID: listID.id, title: "test1", position: 1000);
    await db.insertTask(listID: listID.id, title: "test2", position: 1005);
    await db.insertTask(listID: listID.id, title: "test3", position: 3000);

    final tasks = await (db.select(db.tasks)
    ..where((t) => t.listsId.equals(listID.id)))
    .get();

    await persistMove(db, tasks[2], 1000, 1005, tasks[0].id, tasks[1].id);

    // after renormalize all positions should be clean multiples of 1000
    final allTasks = await (db.select(db.tasks)
    ..where((t) => t.listsId.equals(listID.id))
    ..orderBy([(t) => OrderingTerm.asc(t.position)]))
    .get();

    for (int i = 0; i < allTasks.length; i++) {
      if (allTasks[i].title == "test3") {
        print(allTasks[i]);
        expect(allTasks[i].position, 1500);
      } 
    }

  });

  test("renormalize returns correct neighbor", () async {
    final listID = await db.into(db.todoLists).insertReturning(TodoListsCompanion(
      name: Value("testList"),
      position: Value(1000),
    ));

    await db.insertTask(listID: listID.id, title: "test1", position: 1);
    await db.insertTask(listID: listID.id, title: "test1", position: 2);
    await db.insertTask(listID: listID.id, title: "test1", position: 3);

    final tasks = await (db.select(db.tasks)
    ..where((t) => t.listsId.equals(listID.id)))
    .get();

    final (prev, next) = await db.renormalizeAllTaskPosition(tasks[0].id, tasks[2].id);

    // first task → (0+1)*1000 = 1000, third task → (2+1)*1000 = 3000
    expect(prev, 1000);
    expect(next, 3000);

  });


  

}
