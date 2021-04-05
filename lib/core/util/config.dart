import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

Future setupConfig() async {
  await DotEnv.load(fileName: '.env');
}
