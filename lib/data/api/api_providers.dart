import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ebuk/data/api/gutendex_api_client.dart';

final gutendexApiClientProvider = Provider<GutendexApiClient>((ref) {
  return GutendexApiClient();
});
