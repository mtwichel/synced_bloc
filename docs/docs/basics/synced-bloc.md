---
sidebar_position: 1
title: 🔄 SyncedBloc
---
# 🔄 SyncedBloc

Using `SyncedBloc` is incredibly simple - just follow these three steps to get your bloc states syncing across devices!

## Step 1: Extend SyncedBloc

Instead of extending the regular `Bloc` class, extend `SyncedBloc`:

```dart
import 'package:blocsync/blocsync.dart';

class CounterBloc extends SyncedBloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<Increment>((event, emit) => emit(state + 1));
    on<Decrement>((event, emit) => emit(state - 1));
  }
  
  // Add toJson and fromJson methods next...
}
```

## Step 2: Implement State Serialization

Add `toJson` and `fromJson` methods to transform your state to and from JSON:

```dart
class CounterBloc extends SyncedBloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<Increment>((event, emit) => emit(state + 1));
    on<Decrement>((event, emit) => emit(state - 1));
  }

  @override
  int fromJson(Map<String, dynamic> json) => json['value'] as int;

  @override
  Map<String, dynamic>? toJson(int state) => {'value': state};
}
```

:::tip Selective Syncing
If you don't want certain parts of your state to be synced, simply don't include them in the JSON! Only the data you serialize in `toJson` will be synchronized across devices.
:::

### Complex State Example

For more complex states, just serialize the parts you want synced:

```dart
class TodoBloc extends SyncedBloc<TodoEvent, TodoState> {
  // ... bloc implementation

  @override
  TodoState fromJson(Map<String, dynamic> json) {
    return TodoState(
      todos: (json['todos'] as List)
          .map((todo) => Todo.fromJson(todo))
          .toList(),
      filter: TodoFilter.values[json['filter'] as int],
      // Note: we're not syncing 'isLoading' - it stays local
    );
  }

  @override
  Map<String, dynamic>? toJson(TodoState state) {
    return {
      'todos': state.todos.map((todo) => todo.toJson()).toList(),
      'filter': state.filter.index,
      // 'isLoading' is intentionally omitted from sync
    };
  }
}
```

## Step 3: That's It! 🎉

Your states will now automatically sync across devices! No additional setup required - `SyncedBloc` handles all the synchronization logic behind the scenes.

- **Real-time sync**: Changes are pushed to other devices immediately
- **Offline support**: Changes are queued and synced when connection is restored  
- **Conflict resolution**: Latest write wins for simplicity
- **Efficient**: Only sends state diffs when possible

Your bloc works exactly like a regular bloc, but with the added superpower of cross-device synchronization!
