import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:yayvo/features/consumer/domain/entities/consumer_entity.dart';
import 'package:yayvo/features/consumer/data/repositories/consumer_repository_impl.dart';
import 'package:yayvo/features/consumer/data/datasources/local/consumer_local_datasource.dart';
import 'package:yayvo/core/utils/network_error_helper.dart';

/// State class for profile screen
class ProfileState {
  final ConsumerEntity? consumer;
  final bool isLoading;
  final bool isUploadingPic;
  final String? error;
  final int profilePicCacheKey;

  ProfileState({
    this.consumer,
    this.isLoading = true,
    this.isUploadingPic = false,
    this.error,
    this.profilePicCacheKey = 0,
  });

  ProfileState copyWith({
    ConsumerEntity? consumer,
    bool? isLoading,
    bool? isUploadingPic,
    String? error,
    int? profilePicCacheKey,
  }) {
    return ProfileState(
      consumer: consumer ?? this.consumer,
      isLoading: isLoading ?? this.isLoading,
      isUploadingPic: isUploadingPic ?? this.isUploadingPic,
      error: error ?? this.error,
      profilePicCacheKey: profilePicCacheKey ?? this.profilePicCacheKey,
    );
  }
}

/// View model for profile screen
class ProfileViewModel extends StateNotifier<ProfileState> {
  final Ref ref;

  ProfileViewModel({required this.ref}) : super(ProfileState());

  /// Load user profile
  Future<void> loadProfile(String authId) async {
    if (authId.isEmpty) {
      state = state.copyWith(isLoading: false, error: 'Not logged in');
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      // Try to load from local cache first
      final local = ref.read(consumerLocalProvider);
      final cached = local.getConsumerProfileCache(authId);
      if (cached != null) {
        state = state.copyWith(
          consumer: cached.toEntity(),
          isLoading: false,
          profilePicCacheKey: DateTime.now().millisecondsSinceEpoch,
        );
        return;
      }

      // Load from repository
      final usecase = ref.read(getConsumerProfileProvider);
      final result = await usecase.call(authId);

      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          error: normalizeNetworkErrorMessage(
            failure.message.contains('401') ||
                    failure.message.contains('Unauthorized')
                ? 'Session expired. Please log in again.'
                : failure.message,
          ),
        ),
        (consumer) => state = state.copyWith(
          isLoading: false,
          consumer: consumer,
          profilePicCacheKey: DateTime.now().millisecondsSinceEpoch,
          error: null,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: normalizeNetworkErrorMessage(e.toString()),
      );
    }
  }

  /// Refresh profile
  Future<void> refresh(String authId) async {
    if (authId.isEmpty) return;

    try {
      final repo = ref.read(consumerRepositoryProvider);
      final result = await repo.refreshConsumerProfile(authId);

      result.fold(
        (failure) => state = state.copyWith(
          error: normalizeNetworkErrorMessage(
            failure.message.contains('401') ||
                    failure.message.contains('Unauthorized')
                ? 'Session expired. Please log in again.'
                : failure.message,
          ),
        ),
        (consumer) => state = state.copyWith(
          consumer: consumer,
          profilePicCacheKey: DateTime.now().millisecondsSinceEpoch,
          error: null,
        ),
      );
    } catch (e) {
      state = state.copyWith(error: normalizeNetworkErrorMessage(e.toString()));
    }
  }

  /// Update consumer profile
  Future<void> updateProfile({
    required String authId,
    String? displayName,
    String? bio,
    String? phoneNumber,
    String? dob,
    String? gender,
    String? country,
  }) async {
    if (authId.isEmpty) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final repo = ref.read(consumerRepositoryProvider);
      final updated = state.consumer?.copyWith(
        displayName: displayName,
        bio: bio,
        phoneNumber: phoneNumber,
        dob: dob,
        gender: gender,
        country: country,
      );

      if (updated == null) return;

      final result = await repo.updateConsumer(authId, updated);

      result.fold(
        (failure) => state = state.copyWith(
          isLoading: false,
          error: normalizeNetworkErrorMessage(failure.message),
        ),
        (consumer) => state = state.copyWith(
          isLoading: false,
          consumer: consumer,
          error: null,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: normalizeNetworkErrorMessage(e.toString()),
      );
    }
  }

  /// Upload profile picture
  Future<void> uploadProfilePicture({
    required String authId,
    required File imageFile,
  }) async {
    if (authId.isEmpty) return;

    try {
      state = state.copyWith(isUploadingPic: true, error: null);

      final repo = ref.read(consumerRepositoryProvider);
      final result = await repo.uploadProfilePicture(authId, imageFile);

      result.fold(
        (failure) => state = state.copyWith(
          isUploadingPic: false,
          error: normalizeNetworkErrorMessage(failure.message),
        ),
        (consumer) => state = state.copyWith(
          isUploadingPic: false,
          consumer: consumer,
          profilePicCacheKey: DateTime.now().millisecondsSinceEpoch,
          error: null,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isUploadingPic: false,
        error: normalizeNetworkErrorMessage(e.toString()),
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provide the view model for profile screen
final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
      return ProfileViewModel(ref: ref);
    });

/// Internal provider for GetConsumerProfile usecase
final getConsumerProfileProvider = Provider((ref) {
  final repo = ref.read(consumerRepositoryProvider);
  return (String authId) async => await repo.getConsumerByAuthId(authId);
});
