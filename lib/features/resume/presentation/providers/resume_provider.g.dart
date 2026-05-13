// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$resumeNotifierHash() => r'3e99281561c7b9e58c23bb8d67772af785e7f17e';

/// See also [ResumeNotifier].
@ProviderFor(ResumeNotifier)
final resumeNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ResumeNotifier, ResumeAnalysis?>.internal(
  ResumeNotifier.new,
  name: r'resumeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$resumeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ResumeNotifier = AutoDisposeAsyncNotifier<ResumeAnalysis?>;
String _$selectedJobRoleNotifierHash() =>
    r'7f7a029eeeccdae34c8b788c04fbac3ae7ee053b';

/// See also [SelectedJobRoleNotifier].
@ProviderFor(SelectedJobRoleNotifier)
final selectedJobRoleNotifierProvider =
    AutoDisposeNotifierProvider<SelectedJobRoleNotifier, String>.internal(
  SelectedJobRoleNotifier.new,
  name: r'selectedJobRoleNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedJobRoleNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedJobRoleNotifier = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
