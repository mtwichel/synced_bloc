---
sidebar_position: 2
title: 📦 Partitioned Blocs
---

# Partitioned Blocs

In most application, it's common to want to create multiple _partitions_ to have multiple states for the same bloc. For example:

- Separate documents
- Unique social feeds

## Making a Bloc Partitioned

Simply override the `id` getter in your bloc to be the unique ID for that state:

```dart
import 'package:blocsync/blocsync.dart';

class DocumentBloc extends SyncedBloc<DocumentEvent, DocumentState> {
  DocumentBloc({
    required String documentId,
  }) : _documentId = documentId,
   super(DocumentState.initial()) {
    on<UpdateTheme>((event, emit) => emit(state.copyWith(theme: event.theme)));
    on<UpdateLanguage>((event, emit) => emit(state.copyWith(language: event.language)));
  }

  final String _documentId;

  @override
  bool get id => _documentId; // This makes the bloc store each document separately

  @override
  DocumentState fromJson(Map<String, dynamic> json) => DocumentState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(DocumentState state) => state.toJson();
}
```

:::note
Blocs can be private **and** partitioned. For more information on private blocs, see [Private Blocs](/docs/basics/private-blocs)
:::
