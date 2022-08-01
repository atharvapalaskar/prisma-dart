import 'package:args/command_runner.dart';
import 'package:orm/orm.dart';
import 'package:orm/src/engine_options.dart';

import '../logger.dart';

class GenerateCommand extends Command<int> {
  GenerateCommand() {
    argParser.addOption(
      'schema',
      help: 'Custom path to your Prisma schema',
      valueHelp: 'path',
    );
    argParser.addFlag(
      'watch',
      help: 'Watch the Prisma schema and rerun after a change',
      defaultsTo: false,
    );
  }

  @override
  String get description => 'Generate artifacts';

  @override
  String get name => 'generate';

  /// Run handler for the generate command.
  @override
  Future<int> run() async {
    final EngineOptions options = EngineOptions(
      version: engineVersion,
      platform: EnginePlatform.darwin,
      binary: BinaryType.queryEngine,
    );
    final BinaryEngine engine = BinaryEngine(
      options,
    );

    return 0;
  }
}
