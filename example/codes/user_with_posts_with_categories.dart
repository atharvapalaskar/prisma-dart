import 'package:orm/orm.dart';

import '../prisma.dart';
import '../prisma/generated_dart_client/prisma.dart';

void main(List<String> args) {
  providePrisma((prisma) async {
    // #region snippet
    final user = await prisma.user.findFirst(
      include: UserInclude(
        posts: PrismaUnion.$2(
          UserPostsArgs(
            include: PostInclude(
              categories: PrismaUnion.$1(true),
            ),
          ),
        ),
      ),
    );
    // #endregion snippet

    print(user);
  });
}
