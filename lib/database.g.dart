// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class TodoLists extends Table with TableInfo<TodoLists, TodoList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TodoLists(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [id, name, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todo_lists';
  @override
  VerificationContext validateIntegrity(Insertable<TodoList> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TodoList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoList(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position']),
    );
  }

  @override
  TodoLists createAlias(String alias) {
    return TodoLists(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class TodoList extends DataClass implements Insertable<TodoList> {
  final int id;
  final String? name;
  final int? position;
  const TodoList({required this.id, this.name, this.position});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<int>(position);
    }
    return map;
  }

  TodoListsCompanion toCompanion(bool nullToAbsent) {
    return TodoListsCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
    );
  }

  factory TodoList.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoList(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      position: serializer.fromJson<int?>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String?>(name),
      'position': serializer.toJson<int?>(position),
    };
  }

  TodoList copyWith(
          {int? id,
          Value<String?> name = const Value.absent(),
          Value<int?> position = const Value.absent()}) =>
      TodoList(
        id: id ?? this.id,
        name: name.present ? name.value : this.name,
        position: position.present ? position.value : this.position,
      );
  TodoList copyWithCompanion(TodoListsCompanion data) {
    return TodoList(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodoList(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoList &&
          other.id == this.id &&
          other.name == this.name &&
          other.position == this.position);
}

class TodoListsCompanion extends UpdateCompanion<TodoList> {
  final Value<int> id;
  final Value<String?> name;
  final Value<int?> position;
  const TodoListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
  });
  TodoListsCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
  });
  static Insertable<TodoList> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
    });
  }

  TodoListsCompanion copyWith(
      {Value<int>? id, Value<String?>? name, Value<int?>? position}) {
    return TodoListsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodoListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class Tasks extends Table with TableInfo<Tasks, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Tasks(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _listsIdMeta =
      const VerificationMeta('listsId');
  late final GeneratedColumn<int> listsId = GeneratedColumn<int>(
      'lists_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES todo_lists(id)ON DELETE SET NULL');
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES tasks(id)ON DELETE CASCADE');
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
      'is_done', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      $customConstraints: 'DEFAULT 0',
      defaultValue: const CustomExpression('0'));
  static const VerificationMeta _reminderMeta =
      const VerificationMeta('reminder');
  late final GeneratedColumn<DateTime> reminder = GeneratedColumn<DateTime>(
      'reminder', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _repeatMeta = const VerificationMeta('repeat');
  late final GeneratedColumn<String> repeat = GeneratedColumn<String>(
      'repeat', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints:
          'CHECK (repeat IN (\'daily\', \'weekly\', \'monthly\'))');
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints: '');
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [
        id,
        listsId,
        parentId,
        title,
        isDone,
        reminder,
        dueDate,
        repeat,
        notes,
        position,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lists_id')) {
      context.handle(_listsIdMeta,
          listsId.isAcceptableOrUnknown(data['lists_id']!, _listsIdMeta));
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_done')) {
      context.handle(_isDoneMeta,
          isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta));
    }
    if (data.containsKey('reminder')) {
      context.handle(_reminderMeta,
          reminder.isAcceptableOrUnknown(data['reminder']!, _reminderMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('repeat')) {
      context.handle(_repeatMeta,
          repeat.isAcceptableOrUnknown(data['repeat']!, _repeatMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      listsId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lists_id']),
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}parent_id']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      isDone: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_done']),
      reminder: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}reminder']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      repeat: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}repeat']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  Tasks createAlias(String alias) {
    return Tasks(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final int? listsId;
  final int? parentId;
  final String title;
  final bool? isDone;
  final DateTime? reminder;
  final DateTime? dueDate;
  final String? repeat;
  final String? notes;
  final int? position;

  ///sorting within list
  final DateTime? createdAt;

  ///DEFAULT CURRENT_TIMESTAMP: not working, format error
  final DateTime? updatedAt;
  const Task(
      {required this.id,
      this.listsId,
      this.parentId,
      required this.title,
      this.isDone,
      this.reminder,
      this.dueDate,
      this.repeat,
      this.notes,
      this.position,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || listsId != null) {
      map['lists_id'] = Variable<int>(listsId);
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || isDone != null) {
      map['is_done'] = Variable<bool>(isDone);
    }
    if (!nullToAbsent || reminder != null) {
      map['reminder'] = Variable<DateTime>(reminder);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || repeat != null) {
      map['repeat'] = Variable<String>(repeat);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<int>(position);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      listsId: listsId == null && nullToAbsent
          ? const Value.absent()
          : Value(listsId),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      title: Value(title),
      isDone:
          isDone == null && nullToAbsent ? const Value.absent() : Value(isDone),
      reminder: reminder == null && nullToAbsent
          ? const Value.absent()
          : Value(reminder),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      repeat:
          repeat == null && nullToAbsent ? const Value.absent() : Value(repeat),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      listsId: serializer.fromJson<int?>(json['lists_id']),
      parentId: serializer.fromJson<int?>(json['parent_id']),
      title: serializer.fromJson<String>(json['title']),
      isDone: serializer.fromJson<bool?>(json['is_done']),
      reminder: serializer.fromJson<DateTime?>(json['reminder']),
      dueDate: serializer.fromJson<DateTime?>(json['due_date']),
      repeat: serializer.fromJson<String?>(json['repeat']),
      notes: serializer.fromJson<String?>(json['notes']),
      position: serializer.fromJson<int?>(json['position']),
      createdAt: serializer.fromJson<DateTime?>(json['created_at']),
      updatedAt: serializer.fromJson<DateTime?>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lists_id': serializer.toJson<int?>(listsId),
      'parent_id': serializer.toJson<int?>(parentId),
      'title': serializer.toJson<String>(title),
      'is_done': serializer.toJson<bool?>(isDone),
      'reminder': serializer.toJson<DateTime?>(reminder),
      'due_date': serializer.toJson<DateTime?>(dueDate),
      'repeat': serializer.toJson<String?>(repeat),
      'notes': serializer.toJson<String?>(notes),
      'position': serializer.toJson<int?>(position),
      'created_at': serializer.toJson<DateTime?>(createdAt),
      'updated_at': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Task copyWith(
          {int? id,
          Value<int?> listsId = const Value.absent(),
          Value<int?> parentId = const Value.absent(),
          String? title,
          Value<bool?> isDone = const Value.absent(),
          Value<DateTime?> reminder = const Value.absent(),
          Value<DateTime?> dueDate = const Value.absent(),
          Value<String?> repeat = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          Value<int?> position = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      Task(
        id: id ?? this.id,
        listsId: listsId.present ? listsId.value : this.listsId,
        parentId: parentId.present ? parentId.value : this.parentId,
        title: title ?? this.title,
        isDone: isDone.present ? isDone.value : this.isDone,
        reminder: reminder.present ? reminder.value : this.reminder,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        repeat: repeat.present ? repeat.value : this.repeat,
        notes: notes.present ? notes.value : this.notes,
        position: position.present ? position.value : this.position,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      listsId: data.listsId.present ? data.listsId.value : this.listsId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      title: data.title.present ? data.title.value : this.title,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      reminder: data.reminder.present ? data.reminder.value : this.reminder,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      repeat: data.repeat.present ? data.repeat.value : this.repeat,
      notes: data.notes.present ? data.notes.value : this.notes,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('listsId: $listsId, ')
          ..write('parentId: $parentId, ')
          ..write('title: $title, ')
          ..write('isDone: $isDone, ')
          ..write('reminder: $reminder, ')
          ..write('dueDate: $dueDate, ')
          ..write('repeat: $repeat, ')
          ..write('notes: $notes, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, listsId, parentId, title, isDone,
      reminder, dueDate, repeat, notes, position, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.listsId == this.listsId &&
          other.parentId == this.parentId &&
          other.title == this.title &&
          other.isDone == this.isDone &&
          other.reminder == this.reminder &&
          other.dueDate == this.dueDate &&
          other.repeat == this.repeat &&
          other.notes == this.notes &&
          other.position == this.position &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<int?> listsId;
  final Value<int?> parentId;
  final Value<String> title;
  final Value<bool?> isDone;
  final Value<DateTime?> reminder;
  final Value<DateTime?> dueDate;
  final Value<String?> repeat;
  final Value<String?> notes;
  final Value<int?> position;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.listsId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.title = const Value.absent(),
    this.isDone = const Value.absent(),
    this.reminder = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.repeat = const Value.absent(),
    this.notes = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    this.listsId = const Value.absent(),
    this.parentId = const Value.absent(),
    required String title,
    this.isDone = const Value.absent(),
    this.reminder = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.repeat = const Value.absent(),
    this.notes = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<int>? listsId,
    Expression<int>? parentId,
    Expression<String>? title,
    Expression<bool>? isDone,
    Expression<DateTime>? reminder,
    Expression<DateTime>? dueDate,
    Expression<String>? repeat,
    Expression<String>? notes,
    Expression<int>? position,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listsId != null) 'lists_id': listsId,
      if (parentId != null) 'parent_id': parentId,
      if (title != null) 'title': title,
      if (isDone != null) 'is_done': isDone,
      if (reminder != null) 'reminder': reminder,
      if (dueDate != null) 'due_date': dueDate,
      if (repeat != null) 'repeat': repeat,
      if (notes != null) 'notes': notes,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TasksCompanion copyWith(
      {Value<int>? id,
      Value<int?>? listsId,
      Value<int?>? parentId,
      Value<String>? title,
      Value<bool?>? isDone,
      Value<DateTime?>? reminder,
      Value<DateTime?>? dueDate,
      Value<String?>? repeat,
      Value<String?>? notes,
      Value<int?>? position,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt}) {
    return TasksCompanion(
      id: id ?? this.id,
      listsId: listsId ?? this.listsId,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      reminder: reminder ?? this.reminder,
      dueDate: dueDate ?? this.dueDate,
      repeat: repeat ?? this.repeat,
      notes: notes ?? this.notes,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (listsId.present) {
      map['lists_id'] = Variable<int>(listsId.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (reminder.present) {
      map['reminder'] = Variable<DateTime>(reminder.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (repeat.present) {
      map['repeat'] = Variable<String>(repeat.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('listsId: $listsId, ')
          ..write('parentId: $parentId, ')
          ..write('title: $title, ')
          ..write('isDone: $isDone, ')
          ..write('reminder: $reminder, ')
          ..write('dueDate: $dueDate, ')
          ..write('repeat: $repeat, ')
          ..write('notes: $notes, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class TaskHistory extends Table with TableInfo<TaskHistory, TaskHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TaskHistory(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT');
  static const VerificationMeta _tasksIdMeta =
      const VerificationMeta('tasksId');
  late final GeneratedColumn<int> tasksId = GeneratedColumn<int>(
      'tasks_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES tasks(id)ON DELETE CASCADE');
  @override
  List<GeneratedColumn> get $columns => [id, tasksId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_history';
  @override
  VerificationContext validateIntegrity(Insertable<TaskHistoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tasks_id')) {
      context.handle(_tasksIdMeta,
          tasksId.isAcceptableOrUnknown(data['tasks_id']!, _tasksIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskHistoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      tasksId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tasks_id']),
    );
  }

  @override
  TaskHistory createAlias(String alias) {
    return TaskHistory(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class TaskHistoryData extends DataClass implements Insertable<TaskHistoryData> {
  final int id;
  final int? tasksId;
  const TaskHistoryData({required this.id, this.tasksId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || tasksId != null) {
      map['tasks_id'] = Variable<int>(tasksId);
    }
    return map;
  }

  TaskHistoryCompanion toCompanion(bool nullToAbsent) {
    return TaskHistoryCompanion(
      id: Value(id),
      tasksId: tasksId == null && nullToAbsent
          ? const Value.absent()
          : Value(tasksId),
    );
  }

  factory TaskHistoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskHistoryData(
      id: serializer.fromJson<int>(json['id']),
      tasksId: serializer.fromJson<int?>(json['tasks_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tasks_id': serializer.toJson<int?>(tasksId),
    };
  }

  TaskHistoryData copyWith(
          {int? id, Value<int?> tasksId = const Value.absent()}) =>
      TaskHistoryData(
        id: id ?? this.id,
        tasksId: tasksId.present ? tasksId.value : this.tasksId,
      );
  TaskHistoryData copyWithCompanion(TaskHistoryCompanion data) {
    return TaskHistoryData(
      id: data.id.present ? data.id.value : this.id,
      tasksId: data.tasksId.present ? data.tasksId.value : this.tasksId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskHistoryData(')
          ..write('id: $id, ')
          ..write('tasksId: $tasksId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tasksId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskHistoryData &&
          other.id == this.id &&
          other.tasksId == this.tasksId);
}

class TaskHistoryCompanion extends UpdateCompanion<TaskHistoryData> {
  final Value<int> id;
  final Value<int?> tasksId;
  const TaskHistoryCompanion({
    this.id = const Value.absent(),
    this.tasksId = const Value.absent(),
  });
  TaskHistoryCompanion.insert({
    this.id = const Value.absent(),
    this.tasksId = const Value.absent(),
  });
  static Insertable<TaskHistoryData> custom({
    Expression<int>? id,
    Expression<int>? tasksId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tasksId != null) 'tasks_id': tasksId,
    });
  }

  TaskHistoryCompanion copyWith({Value<int>? id, Value<int?>? tasksId}) {
    return TaskHistoryCompanion(
      id: id ?? this.id,
      tasksId: tasksId ?? this.tasksId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tasksId.present) {
      map['tasks_id'] = Variable<int>(tasksId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskHistoryCompanion(')
          ..write('id: $id, ')
          ..write('tasksId: $tasksId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDB extends GeneratedDatabase {
  _$AppDB(QueryExecutor e) : super(e);
  $AppDBManager get managers => $AppDBManager(this);
  late final TodoLists todoLists = TodoLists(this);
  late final Tasks tasks = Tasks(this);
  late final TaskHistory taskHistory = TaskHistory(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [todoLists, tasks, taskHistory];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('todo_lists',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('tasks', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tasks',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('task_history', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $TodoListsCreateCompanionBuilder = TodoListsCompanion Function({
  Value<int> id,
  Value<String?> name,
  Value<int?> position,
});
typedef $TodoListsUpdateCompanionBuilder = TodoListsCompanion Function({
  Value<int> id,
  Value<String?> name,
  Value<int?> position,
});

final class $TodoListsReferences
    extends BaseReferences<_$AppDB, TodoLists, TodoList> {
  $TodoListsReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Tasks, List<Task>> _tasksRefsTable(_$AppDB db) =>
      MultiTypedResultKey.fromTable(db.tasks,
          aliasName: $_aliasNameGenerator(db.todoLists.id, db.tasks.listsId));

  $TasksProcessedTableManager get tasksRefs {
    final manager = $TasksTableManager($_db, $_db.tasks)
        .filter((f) => f.listsId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $TodoListsFilterComposer extends Composer<_$AppDB, TodoLists> {
  $TodoListsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  Expression<bool> tasksRefs(
      Expression<bool> Function($TasksFilterComposer f) f) {
    final $TasksFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.listsId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $TasksFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $TodoListsOrderingComposer extends Composer<_$AppDB, TodoLists> {
  $TodoListsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));
}

class $TodoListsAnnotationComposer extends Composer<_$AppDB, TodoLists> {
  $TodoListsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  Expression<T> tasksRefs<T extends Object>(
      Expression<T> Function($TasksAnnotationComposer a) f) {
    final $TasksAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.listsId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $TasksAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $TodoListsTableManager extends RootTableManager<
    _$AppDB,
    TodoLists,
    TodoList,
    $TodoListsFilterComposer,
    $TodoListsOrderingComposer,
    $TodoListsAnnotationComposer,
    $TodoListsCreateCompanionBuilder,
    $TodoListsUpdateCompanionBuilder,
    (TodoList, $TodoListsReferences),
    TodoList,
    PrefetchHooks Function({bool tasksRefs})> {
  $TodoListsTableManager(_$AppDB db, TodoLists table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TodoListsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TodoListsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TodoListsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<int?> position = const Value.absent(),
          }) =>
              TodoListsCompanion(
            id: id,
            name: name,
            position: position,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<int?> position = const Value.absent(),
          }) =>
              TodoListsCompanion.insert(
            id: id,
            name: name,
            position: position,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $TodoListsReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tasksRefs) db.tasks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedData<TodoList, TodoLists, Task>(
                        currentTable: table,
                        referencedTable:
                            $TodoListsReferences._tasksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $TodoListsReferences(db, table, p0).tasksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.listsId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $TodoListsProcessedTableManager = ProcessedTableManager<
    _$AppDB,
    TodoLists,
    TodoList,
    $TodoListsFilterComposer,
    $TodoListsOrderingComposer,
    $TodoListsAnnotationComposer,
    $TodoListsCreateCompanionBuilder,
    $TodoListsUpdateCompanionBuilder,
    (TodoList, $TodoListsReferences),
    TodoList,
    PrefetchHooks Function({bool tasksRefs})>;
typedef $TasksCreateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  Value<int?> listsId,
  Value<int?> parentId,
  required String title,
  Value<bool?> isDone,
  Value<DateTime?> reminder,
  Value<DateTime?> dueDate,
  Value<String?> repeat,
  Value<String?> notes,
  Value<int?> position,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
});
typedef $TasksUpdateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  Value<int?> listsId,
  Value<int?> parentId,
  Value<String> title,
  Value<bool?> isDone,
  Value<DateTime?> reminder,
  Value<DateTime?> dueDate,
  Value<String?> repeat,
  Value<String?> notes,
  Value<int?> position,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
});

final class $TasksReferences extends BaseReferences<_$AppDB, Tasks, Task> {
  $TasksReferences(super.$_db, super.$_table, super.$_typedResult);

  static TodoLists _listsIdTable(_$AppDB db) => db.todoLists
      .createAlias($_aliasNameGenerator(db.tasks.listsId, db.todoLists.id));

  $TodoListsProcessedTableManager? get listsId {
    final $_column = $_itemColumn<int>('lists_id');
    if ($_column == null) return null;
    final manager = $TodoListsTableManager($_db, $_db.todoLists)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_listsIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<TaskHistory, List<TaskHistoryData>>
      _taskHistoryRefsTable(_$AppDB db) => MultiTypedResultKey.fromTable(
          db.taskHistory,
          aliasName: $_aliasNameGenerator(db.tasks.id, db.taskHistory.tasksId));

  $TaskHistoryProcessedTableManager get taskHistoryRefs {
    final manager = $TaskHistoryTableManager($_db, $_db.taskHistory)
        .filter((f) => f.tasksId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskHistoryRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $TasksFilterComposer extends Composer<_$AppDB, Tasks> {
  $TasksFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDone => $composableBuilder(
      column: $table.isDone, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get reminder => $composableBuilder(
      column: $table.reminder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get repeat => $composableBuilder(
      column: $table.repeat, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $TodoListsFilterComposer get listsId {
    final $TodoListsFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.listsId,
        referencedTable: $db.todoLists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $TodoListsFilterComposer(
              $db: $db,
              $table: $db.todoLists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> taskHistoryRefs(
      Expression<bool> Function($TaskHistoryFilterComposer f) f) {
    final $TaskHistoryFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskHistory,
        getReferencedColumn: (t) => t.tasksId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $TaskHistoryFilterComposer(
              $db: $db,
              $table: $db.taskHistory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $TasksOrderingComposer extends Composer<_$AppDB, Tasks> {
  $TasksOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDone => $composableBuilder(
      column: $table.isDone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get reminder => $composableBuilder(
      column: $table.reminder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get repeat => $composableBuilder(
      column: $table.repeat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $TodoListsOrderingComposer get listsId {
    final $TodoListsOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.listsId,
        referencedTable: $db.todoLists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $TodoListsOrderingComposer(
              $db: $db,
              $table: $db.todoLists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $TasksAnnotationComposer extends Composer<_$AppDB, Tasks> {
  $TasksAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<DateTime> get reminder =>
      $composableBuilder(column: $table.reminder, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get repeat =>
      $composableBuilder(column: $table.repeat, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $TodoListsAnnotationComposer get listsId {
    final $TodoListsAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.listsId,
        referencedTable: $db.todoLists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $TodoListsAnnotationComposer(
              $db: $db,
              $table: $db.todoLists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> taskHistoryRefs<T extends Object>(
      Expression<T> Function($TaskHistoryAnnotationComposer a) f) {
    final $TaskHistoryAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.taskHistory,
        getReferencedColumn: (t) => t.tasksId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $TaskHistoryAnnotationComposer(
              $db: $db,
              $table: $db.taskHistory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $TasksTableManager extends RootTableManager<
    _$AppDB,
    Tasks,
    Task,
    $TasksFilterComposer,
    $TasksOrderingComposer,
    $TasksAnnotationComposer,
    $TasksCreateCompanionBuilder,
    $TasksUpdateCompanionBuilder,
    (Task, $TasksReferences),
    Task,
    PrefetchHooks Function({bool listsId, bool taskHistoryRefs})> {
  $TasksTableManager(_$AppDB db, Tasks table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TasksFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TasksOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TasksAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> listsId = const Value.absent(),
            Value<int?> parentId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<bool?> isDone = const Value.absent(),
            Value<DateTime?> reminder = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String?> repeat = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> position = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            listsId: listsId,
            parentId: parentId,
            title: title,
            isDone: isDone,
            reminder: reminder,
            dueDate: dueDate,
            repeat: repeat,
            notes: notes,
            position: position,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> listsId = const Value.absent(),
            Value<int?> parentId = const Value.absent(),
            required String title,
            Value<bool?> isDone = const Value.absent(),
            Value<DateTime?> reminder = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String?> repeat = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> position = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            listsId: listsId,
            parentId: parentId,
            title: title,
            isDone: isDone,
            reminder: reminder,
            dueDate: dueDate,
            repeat: repeat,
            notes: notes,
            position: position,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $TasksReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({listsId = false, taskHistoryRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (taskHistoryRefs) db.taskHistory],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (listsId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.listsId,
                    referencedTable: $TasksReferences._listsIdTable(db),
                    referencedColumn: $TasksReferences._listsIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (taskHistoryRefs)
                    await $_getPrefetchedData<Task, Tasks, TaskHistoryData>(
                        currentTable: table,
                        referencedTable:
                            $TasksReferences._taskHistoryRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $TasksReferences(db, table, p0).taskHistoryRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tasksId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $TasksProcessedTableManager = ProcessedTableManager<
    _$AppDB,
    Tasks,
    Task,
    $TasksFilterComposer,
    $TasksOrderingComposer,
    $TasksAnnotationComposer,
    $TasksCreateCompanionBuilder,
    $TasksUpdateCompanionBuilder,
    (Task, $TasksReferences),
    Task,
    PrefetchHooks Function({bool listsId, bool taskHistoryRefs})>;
typedef $TaskHistoryCreateCompanionBuilder = TaskHistoryCompanion Function({
  Value<int> id,
  Value<int?> tasksId,
});
typedef $TaskHistoryUpdateCompanionBuilder = TaskHistoryCompanion Function({
  Value<int> id,
  Value<int?> tasksId,
});

final class $TaskHistoryReferences
    extends BaseReferences<_$AppDB, TaskHistory, TaskHistoryData> {
  $TaskHistoryReferences(super.$_db, super.$_table, super.$_typedResult);

  static Tasks _tasksIdTable(_$AppDB db) => db.tasks
      .createAlias($_aliasNameGenerator(db.taskHistory.tasksId, db.tasks.id));

  $TasksProcessedTableManager? get tasksId {
    final $_column = $_itemColumn<int>('tasks_id');
    if ($_column == null) return null;
    final manager = $TasksTableManager($_db, $_db.tasks)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tasksIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $TaskHistoryFilterComposer extends Composer<_$AppDB, TaskHistory> {
  $TaskHistoryFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  $TasksFilterComposer get tasksId {
    final $TasksFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tasksId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $TasksFilterComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $TaskHistoryOrderingComposer extends Composer<_$AppDB, TaskHistory> {
  $TaskHistoryOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  $TasksOrderingComposer get tasksId {
    final $TasksOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tasksId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $TasksOrderingComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $TaskHistoryAnnotationComposer extends Composer<_$AppDB, TaskHistory> {
  $TaskHistoryAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $TasksAnnotationComposer get tasksId {
    final $TasksAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tasksId,
        referencedTable: $db.tasks,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $TasksAnnotationComposer(
              $db: $db,
              $table: $db.tasks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $TaskHistoryTableManager extends RootTableManager<
    _$AppDB,
    TaskHistory,
    TaskHistoryData,
    $TaskHistoryFilterComposer,
    $TaskHistoryOrderingComposer,
    $TaskHistoryAnnotationComposer,
    $TaskHistoryCreateCompanionBuilder,
    $TaskHistoryUpdateCompanionBuilder,
    (TaskHistoryData, $TaskHistoryReferences),
    TaskHistoryData,
    PrefetchHooks Function({bool tasksId})> {
  $TaskHistoryTableManager(_$AppDB db, TaskHistory table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TaskHistoryFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TaskHistoryOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TaskHistoryAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> tasksId = const Value.absent(),
          }) =>
              TaskHistoryCompanion(
            id: id,
            tasksId: tasksId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> tasksId = const Value.absent(),
          }) =>
              TaskHistoryCompanion.insert(
            id: id,
            tasksId: tasksId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $TaskHistoryReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({tasksId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (tasksId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tasksId,
                    referencedTable: $TaskHistoryReferences._tasksIdTable(db),
                    referencedColumn:
                        $TaskHistoryReferences._tasksIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $TaskHistoryProcessedTableManager = ProcessedTableManager<
    _$AppDB,
    TaskHistory,
    TaskHistoryData,
    $TaskHistoryFilterComposer,
    $TaskHistoryOrderingComposer,
    $TaskHistoryAnnotationComposer,
    $TaskHistoryCreateCompanionBuilder,
    $TaskHistoryUpdateCompanionBuilder,
    (TaskHistoryData, $TaskHistoryReferences),
    TaskHistoryData,
    PrefetchHooks Function({bool tasksId})>;

class $AppDBManager {
  final _$AppDB _db;
  $AppDBManager(this._db);
  $TodoListsTableManager get todoLists =>
      $TodoListsTableManager(_db, _db.todoLists);
  $TasksTableManager get tasks => $TasksTableManager(_db, _db.tasks);
  $TaskHistoryTableManager get taskHistory =>
      $TaskHistoryTableManager(_db, _db.taskHistory);
}
