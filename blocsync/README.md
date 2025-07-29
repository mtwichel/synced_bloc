# BlocSync

A package for syncing data between multiple devices.

## Features

- Uses [hydrated bloc](https://pub.dev/packages/hydrated_bloc) to cache locally.
- Uploads states to server for in-cloud caching.

## Usage

```dart
import 'package:blocsync/blocsync.dart';

class MyBloc extends SyncedBloc<MyEvent, MyState> {
  MyBloc() : super(MyState.initial());
}

class MyEvent {}

class MyState {}
```