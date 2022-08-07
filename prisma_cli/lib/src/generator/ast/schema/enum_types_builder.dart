import 'package:prisma_cli/src/generator/ast/ast.dart';

import '../../../dmmf/schema/enum_types.dart';
import '../../../utils/string_camel_case.dart';

class SchemaEnumTypesBuilder extends CodeableAst {
  SchemaEnumTypesBuilder(super.ast);

  @override
  String get codeString {
    final StringBuffer enumCodes = StringBuffer();
    enumCodes.writeln(_enumBuilder(ast.dmmf.schema.enumTypes.prisma));
    enumCodes.writeln(_enumBuilder(ast.dmmf.schema.enumTypes.model));

    return enumCodes.toString();
  }

  /// Enum builder.
  String _enumBuilder(List<EnumType> enumTypes) {
    final StringBuffer enumCodes = StringBuffer();
    for (final element in enumTypes) {
      enumCodes.writeln('enum ${element.name} implements PrismaEnum {');
      for (final String value in element.values) {
        enumCodes
            .writeln('  ${firstLowerCamelCase(field(value))}(\'$value\'),');
      }
      enumCodes.writeln(';');
      enumCodes.writeln('  @override');
      enumCodes.writeln('  final String value;');
      enumCodes.writeln('  const ${element.name}(this.value);');

      enumCodes.writeln('}');
    }

    return enumCodes.toString();
  }
}