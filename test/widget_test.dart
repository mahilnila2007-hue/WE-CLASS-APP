import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_campus/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('WE Campus App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const WeCampusApp());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('WE'), findsWidgets);
    expect(find.text('WHO ARE YOU?'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('Staff'), findsOneWidget);
  });
}
