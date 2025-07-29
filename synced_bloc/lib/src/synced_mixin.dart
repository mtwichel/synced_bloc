import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:synced_bloc/src/synced_config.dart';

mixin SyncedMixin<State> on BlocBase<State> {
  State? _state;

  Future<void> init() async {
    final json = await SyncedConfig.apiClient.fetch(storageToken);
    _state = fromJson(json)!;
    // ignore: invalid_use_of_visible_for_testing_member
    emit(_state!);
  }

  @override
  Future<void> onChange(Change<State> change) async {
    super.onChange(change);

    final state = change.nextState;
    if (state == _state) return;
    _state = state;

    final stateJson = toJson(state);

    if (stateJson != null) {
      await SyncedConfig.apiClient.save(storageToken, data: stateJson);
    }
  }

  String get id => '';

  String get storagePrefix => runtimeType.toString();

  String get storageToken => '$storagePrefix$id';

  State? fromJson(Map<String, dynamic> json);

  Map<String, dynamic>? toJson(State state);
}
