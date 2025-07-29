import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:synced_bloc/src/synced_mixin.dart';

abstract class SyncedBloc<Event, State> extends Bloc<Event, State>
    with HydratedMixin<State>, SyncedMixin<State> {
  SyncedBloc(super.initialState) {
    hydrate();
    init();
  }
}

abstract class SyncedCubit<State> extends Cubit<State>
    with HydratedMixin<State>, SyncedMixin<State> {
  SyncedCubit(super.initialState) {
    hydrate();
    init();
  }
}
