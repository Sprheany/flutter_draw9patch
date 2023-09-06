// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$imageFileHash() => r'964775f97aa2419ab39816ddc79efe36acf6b3db';

/// See also [ImageFile].
@ProviderFor(ImageFile)
final imageFileProvider =
    AutoDisposeNotifierProvider<ImageFile, XFile?>.internal(
  ImageFile.new,
  name: r'imageFileProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$imageFileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ImageFile = AutoDisposeNotifier<XFile?>;
String _$fileNameHash() => r'2ddc5a1b45c4ee2fcd8d42183d50d0543fe50580';

/// See also [FileName].
@ProviderFor(FileName)
final fileNameProvider = AutoDisposeNotifierProvider<FileName, String>.internal(
  FileName.new,
  name: r'fileNameProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$fileNameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FileName = AutoDisposeNotifier<String>;
String _$createImageDataHash() => r'2530223e7bc88433104f91ec7bb4c1f093b9c609';

/// See also [CreateImageData].
@ProviderFor(CreateImageData)
final createImageDataProvider =
    AutoDisposeAsyncNotifierProvider<CreateImageData, ImageData?>.internal(
  CreateImageData.new,
  name: r'createImageDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createImageDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CreateImageData = AutoDisposeAsyncNotifier<ImageData?>;
String _$createTextureHash() => r'0fcbf038578ecc024428b6cfbc6c8690849a37dd';

/// See also [CreateTexture].
@ProviderFor(CreateTexture)
final createTextureProvider =
    AutoDisposeAsyncNotifierProvider<CreateTexture, Image>.internal(
  CreateTexture.new,
  name: r'createTextureProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createTextureHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CreateTexture = AutoDisposeAsyncNotifier<Image>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
