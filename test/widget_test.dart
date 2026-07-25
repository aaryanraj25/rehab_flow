import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_flow/main.dart';

void main() {
  testWidgets('RehabFlow app boots with placeholder home', (tester) async {
    await tester.pumpWidget(const RehabFlowApp());
    expect(find.text('RehabFlow'), findsOneWidget);
    expect(find.text('Rehabilitation Exercise Management'), findsOneWidget);
  });
}
