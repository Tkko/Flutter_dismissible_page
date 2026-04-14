import 'package:example/app/app.dart';
import 'package:example/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
