// ignore_for_file: file_names

import '../model_scalar.dart';
import 'action+from.dart';
import 'action.dart';

extension Action$Distinct<Unserialized, Model, Where, OrderBy, Cursor,
        Pagination, Distinct extends ModelScalar, Having, Create, Update>
    on Action<Unserialized, Model, Where, OrderBy, Cursor, Pagination, Distinct,
        Having, Create, Update> {
  Action<Unserialized, Model, Where, OrderBy, Cursor, Pagination, Distinct,
      Having, Create, Update> distinct(Distinct input) {
    return switch (arguments['distinct']) {
      String previous => from({
          ...arguments,
          'distinct': [previous, input.name],
        }),
      Iterable<String> previous => from({
          ...arguments,
          'distinct': [...previous, input.name],
        }),
      _ => from({...arguments, 'distinct': input.name}),
    };
  }
}