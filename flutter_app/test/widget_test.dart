import 'package:flutter_test/flutter_test.dart';

import 'package:ai_image_studio/features/generator/presentation/screens/home_screen.dart';
import 'package:ai_image_studio/main.dart';

void main() {
  testWidgets('app loads and displays home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AiImageStudioApp());

    expect(find.text('Matrix AI'), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
