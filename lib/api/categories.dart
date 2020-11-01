import 'package:flutter_event_bus/flutter_event_bus.dart';
import 'package:myfinance_app/api/authentication.dart';
import 'package:myfinance_app/utils/events.dart';
import 'package:myfinance_app/utils/keys.dart';
import 'package:myfinance_app/utils/models.dart';
import 'package:myfinance_app/utils/network.dart';
import 'package:myfinance_app/utils/static.dart';

class CategoriesHandler {
  static Future<ApiResponse<List<Category>>> _loadingProcess;
  static List<Category> loadedCategories;

  List<Category> _jsonParser(Map<String, dynamic> json, String rsaPrivateKey) =>
      json['categories']
          .map<Category>(
              (json) => Category.fromEncryptedJson(json, rsaPrivateKey))
          .toList();

  Future<ApiResponse<List<Category>>> loadCategories(EventBus eventBus) async {
    // Check if there is already a loading process going on
    // if so: wait until the process finished and return the result
    if (_loadingProcess != null) {
      print('Second category loader. Using results of first one...');
      return await _loadingProcess;
    }

    final auth = await AuthenticationHandler.getAuthentication();
    final rsaPrivateKey =
        await Static.storage.getSensitiveString(Keys.rsaPrivateKey);
    _loadingProcess = request<List<Category>>(
      '/overview',
      HttpMethod.GET,
      key: Keys.categories,
      eventBus: eventBus,
      authentication: auth,
      jsonParser: (json) => _jsonParser(json, rsaPrivateKey),
    );

    // Set the static loader and wait until it finished
    final result = await _loadingProcess;
    _loadingProcess = null;

    // Save data
    if (result.statusCode == StatusCode.success) {
      Static.storage.setString(Keys.categories, result.rawData);
      loadedCategories = result.data;
    }

    return result;
  }

  Future<List<Category>> loadOfflineCategories() async {
    final rawData = Static.storage.getString(Keys.categories);
    if (rawData != null) {
      final rsaPrivateKey =
          await Static.storage.getSensitiveString(Keys.rsaPrivateKey);
      final res = parseJson(
          Keys.categories, rawData, (json) => _jsonParser(json, rsaPrivateKey));

      if (res.statusCode == StatusCode.success) {
        loadedCategories = res.data;
        return res.data;
      }
      print('Failed to parse ${Keys.categories} offline data');
    }

    return null;
  }

  /// Updates or edits a category
  ///
  /// When the category id is set, it updates, otherwise it creates a category
  Future<ApiResponse<_CategoryResponse>> setCategory(Category category) async {
    final auth = await AuthenticationHandler.getAuthentication();
    final rsaPublicKey =
        await Static.storage.getSensitiveString(Keys.rsaPublicKey);
    return request<_CategoryResponse>(
      '/category',
      category.id == null ? HttpMethod.POST : HttpMethod.PUT,
      authentication: auth,
      data: category.toEncryptedJson(rsaPublicKey),
      jsonParser: (json) => _CategoryResponse.fromJson(json),
    );
  }

  /// Deletes a category
  Future<ApiResponse<bool>> deleteCategory(
      Category category) async {
    final auth = await AuthenticationHandler.getAuthentication();
    return request<bool>(
      '/category',
      HttpMethod.DELETE,
      authentication: auth,
      data: {'id': category.id},
      jsonParser: (json) => json['status'],
    );
  }
}

class _CategoryResponse {
  final bool status;
  final int id;

  _CategoryResponse(this.status, this.id);

  factory _CategoryResponse.fromJson(Map<String, dynamic> json) =>
      _CategoryResponse(
        json['status'],
        json['categoryID'],
      );
}
