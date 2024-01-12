import '../prisma.dart';
import '../prisma/generated_dart_client/prisma.dart';

void main(List<String> args) {
  providePrisma((prisma) async {
    // #region snippet
    final user = await prisma.user.findUnique(
      where: UserWhereUniqueInput(email: "seven@odroe.com"),
      select: UserSelect(
        name: true,
        email: true,
      ),
    );
    // #endregion snippet

    print(user);
  });
}
