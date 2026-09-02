// import 'package:convo/app/app.dart';
import 'package:convo/app/config/app_config.dart';
import 'package:convo/app/config/environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    const config = AppConfig(appTitle: 'ConVo', environment: Environment.dev);

    expect(config.appTitle, 'ConVo');
  });
}
