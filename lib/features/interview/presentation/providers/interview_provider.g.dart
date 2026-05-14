// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interview_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$interviewNotifierHash() => r'1adbbed060dfe727089698a48c83553e25aa64d9';

/// See also [InterviewNotifier].
@ProviderFor(InterviewNotifier)
final interviewNotifierProvider = AutoDisposeAsyncNotifierProvider<
    InterviewNotifier, InterviewSession?>.internal(
  InterviewNotifier.new,
  name: r'interviewNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$interviewNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InterviewNotifier = AutoDisposeAsyncNotifier<InterviewSession?>;
String _$interviewProgressNotifierHash() =>
    r'a4c5f3ce5ad7e9925f47b3b7a07f08a0311c6b73';

/// See also [InterviewProgressNotifier].
@ProviderFor(InterviewProgressNotifier)
final interviewProgressNotifierProvider = AutoDisposeNotifierProvider<
    InterviewProgressNotifier, InterviewProgress>.internal(
  InterviewProgressNotifier.new,
  name: r'interviewProgressNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$interviewProgressNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InterviewProgressNotifier = AutoDisposeNotifier<InterviewProgress>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
