import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// A thin wrapper around Supabase Storage APIs that exposes
/// the most common operations with consistent error handling.
class StorageService extends GetxService {
  final SupabaseService _supabaseService = Get.find();

  SupabaseStorageClient get _storage => _supabaseService.storage;

  /// Creates a new storage bucket.
  Future<String> createBucket(String bucketId, {BucketOptions? options}) async {
    try {
      return await _storage.createBucket(
        bucketId,
        options ?? const BucketOptions(public: false),
      );
    } catch (e) {
      _logError('createBucket', e);
      rethrow;
    }
  }

  /// Retrieves an existing bucket.
  Future<Bucket> getBucket(String bucketId) async {
    try {
      return await _storage.getBucket(bucketId);
    } catch (e) {
      _logError('getBucket', e);
      rethrow;
    }
  }

  /// Lists all available storage buckets.
  Future<List<Bucket>> listBuckets() async {
    try {
      return await _storage.listBuckets();
    } catch (e) {
      _logError('listBuckets', e);
      rethrow;
    }
  }

  /// Updates an existing bucket (e.g. make it public/private).
  Future<String> updateBucket(
    String bucketId, {
    required BucketOptions options,
  }) async {
    try {
      return await _storage.updateBucket(bucketId, options);
    } catch (e) {
      _logError('updateBucket', e);
      rethrow;
    }
  }

  /// Deletes a bucket. Bucket must be empty beforehand.
  Future<String> deleteBucket(String bucketId) async {
    try {
      return await _storage.deleteBucket(bucketId);
    } catch (e) {
      _logError('deleteBucket', e);
      rethrow;
    }
  }

  /// Removes all objects inside the specified bucket.
  Future<String> emptyBucket(String bucketId) async {
    try {
      return await _storage.emptyBucket(bucketId);
    } catch (e) {
      _logError('emptyBucket', e);
      rethrow;
    }
  }

  /// Uploads a [File] to the provided bucket/path.
  Future<String> uploadFile(
    String bucketId,
    String path,
    File file, {
    FileOptions? fileOptions,
    int? retryAttempts,
    StorageRetryController? retryController,
  }) async {
    try {
      return await _storage
          .from(bucketId)
          .upload(
            path,
            file,
            fileOptions: fileOptions ?? const FileOptions(),
            retryAttempts: retryAttempts,
            retryController: retryController,
          );
    } catch (e) {
      _logError('uploadFile', e);
      rethrow;
    }
  }

  /// Uploads raw bytes to the specified bucket/path.
  Future<String> uploadBytes(
    String bucketId,
    String path,
    Uint8List data, {
    FileOptions? fileOptions,
    int? retryAttempts,
    StorageRetryController? retryController,
  }) async {
    try {
      return await _storage
          .from(bucketId)
          .uploadBinary(
            path,
            data,
            fileOptions: fileOptions ?? const FileOptions(),
            retryAttempts: retryAttempts,
            retryController: retryController,
          );
    } catch (e) {
      _logError('uploadBytes', e);
      rethrow;
    }
  }

  /// Downloads the file at [path] as raw bytes.
  Future<Uint8List> downloadFile(String bucketId, String path) async {
    try {
      return await _storage.from(bucketId).download(path);
    } catch (e) {
      _logError('downloadFile', e);
      rethrow;
    }
  }

  /// Lists objects within a bucket (optionally filtered by folder/path).
  Future<List<FileObject>> listFiles(
    String bucketId, {
    String path = '',
    SearchOptions? searchOptions,
  }) async {
    try {
      return await _storage
          .from(bucketId)
          .list(
            path: path,
            searchOptions: searchOptions ?? const SearchOptions(),
          );
    } catch (e) {
      _logError('listFiles', e);
      rethrow;
    }
  }

  /// Replaces an existing file at [path].
  Future<String> updateFile(
    String bucketId,
    String path,
    File file, {
    FileOptions? fileOptions,
    int? retryAttempts,
    StorageRetryController? retryController,
  }) async {
    try {
      return await _storage
          .from(bucketId)
          .update(
            path,
            file,
            fileOptions: fileOptions ?? const FileOptions(),
            retryAttempts: retryAttempts,
            retryController: retryController,
          );
    } catch (e) {
      _logError('updateFile', e);
      rethrow;
    }
  }

  /// Moves/renames a file within the same bucket.
  Future<String> moveFile(
    String bucketId,
    String fromPath,
    String toPath,
  ) async {
    try {
      return await _storage.from(bucketId).move(fromPath, toPath);
    } catch (e) {
      _logError('moveFile', e);
      rethrow;
    }
  }

  /// Deletes one or more files.
  Future<List<FileObject>> deleteFiles(
    String bucketId,
    List<String> paths,
  ) async {
    try {
      return await _storage.from(bucketId).remove(paths);
    } catch (e) {
      _logError('deleteFiles', e);
      rethrow;
    }
  }

  /// Creates a signed URL for a file valid for [expiresIn] seconds.
  Future<String> createSignedUrl(
    String bucketId,
    String path,
    int expiresIn, {
    TransformOptions? transform,
  }) async {
    try {
      final response = await _storage
          .from(bucketId)
          .createSignedUrl(path, expiresIn, transform: transform);
      return response;
    } catch (e) {
      _logError('createSignedUrl', e);
      rethrow;
    }
  }

  /// Retrieves a public URL for a file in a public bucket.
  String getPublicUrl(
    String bucketId,
    String path, {
    TransformOptions? transform,
  }) {
    try {
      return _storage.from(bucketId).getPublicUrl(path, transform: transform);
    } catch (e) {
      _logError('getPublicUrl', e);
      rethrow;
    }
  }

  void _logError(String method, Object error) {
    // ignore: avoid_print
    print('[StorageService] $method error: $error');
  }
}
