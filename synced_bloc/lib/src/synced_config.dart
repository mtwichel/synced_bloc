import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:synced_bloc/src/api_client.dart';

class SyncedConfig {
  static ApiClient? _apiClient;

  static set apiClient(ApiClient? apiClient) => _apiClient = apiClient;

  static ApiClient get apiClient {
    if (_apiClient == null) throw Exception('API client not found');
    return _apiClient!;
  }

  static set storage(Storage? storage) => HydratedBloc.storage = storage;

  static Storage get storage => HydratedBloc.storage;
}
