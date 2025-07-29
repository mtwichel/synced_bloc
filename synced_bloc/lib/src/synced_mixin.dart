import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:synced_bloc/src/synced_config.dart';

mixin SyncedMixin<State> on BlocBase<State> {
  Future<void> init() async {
    final json = await SyncedConfig.apiClient.fetch(
      storageToken,
      isPrivate: isPrivate,
    );
    final state = fromJson(json)!;
    emit(state);
  }

  @override
  Future<void> onChange(Change<State> change) async {
    super.onChange(change);

    final stateJson = toJson(change.nextState);
    if (stateJson != null) {
      await SyncedConfig.apiClient.save(
        storageToken,
        data: stateJson,
        isPrivate: isPrivate,
      );
    }
  }

  String get id => '';

  String get storagePrefix => runtimeType.toString();

  String get storageToken => '$storagePrefix$id';

  bool get isPrivate => false;

  State? fromJson(Map<String, dynamic> json);

  Map<String, dynamic>? toJson(State state);
}
