import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'query_engine_bindings.dart' as bindings;

const String _libName = 'prisma_flutter';

DynamicLibrary get _dylib {
  if (Platform.isIOS) {
    return DynamicLibrary.open("$_libName.framework/$_libName");
  }

  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}

final _bindingsInstance = bindings.QueryEngineBindings(_dylib);
int _evalEngineId = 0;

enum LogLevel { error, warn, info, debug, trace }

class QueryEngine implements Finalizable {
  final Pointer<bindings.QueryEngine> _engine;
  final void Function() _cleanup;

  const QueryEngine._(this._engine, this._cleanup);

  factory QueryEngine({
    required String schema,
    String? basePath,
    LogLevel logLevel = LogLevel.info,
    bool logQueries = false,
    void Function(String id, String message)? logCallback,
    Map<String, String>? env,
    bool ignoreEnvVarErrors = false,
    String nativeConfigDir = '',
  }) {
    void logCallbackProxy(Pointer<Char> id, Pointer<Char> message) =>
        logCallback?.call(id.cast<Utf8>().toDartString(),
            message.cast<Utf8>().toDartString());
    final logNativeCallable =
        NativeCallable<Void Function(Pointer<Char>, Pointer<Char>)>.listener(
            logCallbackProxy);

    final native = Struct.create<bindings.ConstructorOptionsNative>()
      ..config_dir = nativeConfigDir.toNativeUtf8().cast();

    final options = Struct.create<bindings.ConstructorOptions>()
      ..id = _evalEngineId.toString().toNativeUtf8().cast()
      ..datamodel = schema.toNativeUtf8().cast()
      ..base_path = basePath?.toNativeUtf8().cast() ?? nullptr
      ..log_level = logLevel.name.toNativeUtf8().cast()
      ..log_queries = logQueries
      ..log_callback = logNativeCallable.nativeFunction
      ..env = json.encode(env ?? const <String, String>{}).toNativeUtf8().cast()
      ..ignore_env_var_errors = ignoreEnvVarErrors
      ..native = native
      ..datasource_overrides =
          json.encode(<String, String>{}).toNativeUtf8().cast();

    final enginePtr = malloc<Pointer<bindings.QueryEngine>>();
    final errorPtr = malloc<Pointer<Char>>();

    void cleanup() {
      malloc.free(errorPtr);
      malloc.free(enginePtr);
      logNativeCallable.close();
    }

    final status = _bindingsInstance.create(options, enginePtr, errorPtr);

    if (status == bindings.Status.ok) {
      _evalEngineId++;
      malloc.free(errorPtr);

      return QueryEngine._(enginePtr.value);
    } else if (status == bindings.Status.err) {
      final message = errorPtr.value.cast<Utf8>().toDartString();
      cleanup();

      throw StateError('Failed to create query engine: $message');
    } else if (status == bindings.Status.miss) {
      cleanup();
      throw StateError('Missing create query engine.');
    }

    cleanup();
    throw StateError('Unknown create query engine error.');
  }

  void destroy() {
    final status = _bindingsInstance.destroy(_engine);
    if (status != bindings.Status.ok) {
      throw StateError('Destory engine fail.');
    }
  }

  void start({String? trace}) {
    final errorPtr = malloc<Pointer<Char>>();
    final status = _bindingsInstance.start(
        _engine, trace?.toNativeUtf8().cast() ?? nullptr, errorPtr);
    if (status != bindings.Status.ok) {
      if (status == bindings.Status.miss) {
        malloc.free(errorPtr);
        throw StateError('Start query engine fail.');
      }

      final message = errorPtr.value.cast<Utf8>().toDartString();
      malloc.free(errorPtr);
      throw StateError(message);
    }

    malloc.free(errorPtr);
  }

  void stop({String? header}) {
    final status = _bindingsInstance.stop(
        _engine, header?.toNativeUtf8().cast() ?? nullptr);
    if (status != bindings.Status.ok) {
      throw StateError('Could not stop from prisma query engine');
    }
  }

  void applyMigrations({required String path}) {
    final errorPtr = malloc<Pointer<Char>>();
    final status = _bindingsInstance.applyMigrations(
        _engine, path.toNativeUtf8().cast(), errorPtr);
    if (status != bindings.Status.ok) {
      final message = errorPtr.value.cast<Utf8>().toDartString();
      malloc.free(errorPtr);

      throw StateError(message);
    }

    malloc.free(errorPtr);
  }
}
