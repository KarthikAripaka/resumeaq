// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$resumeNotifierHash() => r'bee2907ffdb08aefdb8b607c64eb15dc514330d9';

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
    r'd6da7a8b4e6c7ab3eb6be366d6b621476ff5794f';

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
