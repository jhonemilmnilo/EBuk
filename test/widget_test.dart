import 'package:ebuk/core/strings.dart';
import 'package:ebuk/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EBuk app launches and displays Home screen header without network requests', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: EBukApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify EBuk app title is visible
    expect(find.text(AppStrings.appName), findsOneWidget);

    // Verify search placeholder is rendered
    expect(find.text(AppStrings.searchPlaceholder), findsOneWidget);

    // Verify Popular Topics section exists
    expect(find.text(AppStrings.popularTopics), findsOneWidget);
  });
}
