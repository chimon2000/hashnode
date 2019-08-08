import 'package:flutter_dotenv/flutter_dotenv.dart';

Future setupConfig() async {
  await DotEnv().load('.env');
}
