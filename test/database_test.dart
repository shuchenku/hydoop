import 'package:flutter_test/flutter_test.dart';
import 'package:hydoop/data/repositories/race_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() {
  group('Database Tests', () {
    setUpAll(() {
      // Initialize Flutter binding for asset loading
      TestWidgetsFlutterBinding.ensureInitialized();

      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    test('Database loads CSV data correctly', () async {
      // Delete existing database to force recreation
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'hydoop.db');
      try {
        await deleteDatabase(path);
      } catch (e) {
        // Database doesn't exist, which is fine
      }

      // Now test through repository
      final repository = RaceRepositoryImpl();

      // Try to get all race results
      final results = await repository.getAllRaceResults();

      // Verify we have data
      expect(results.length, greaterThan(0),
          reason: 'No race results were loaded from CSV files');
      expect(results.length, greaterThan(400),
          reason:
              'Should have loaded race data from CSV files (duplicates are expected)');

      // Verify a few sample records
      final firstResult = results.first;

      expect(firstResult.name, isNotEmpty);
      expect(firstResult.eventId, isNotEmpty);
      expect(firstResult.totalTime, isNotEmpty);

      // Check unique events
      final events = await repository.getUniqueEvents();
      expect(events.length, greaterThan(0));

      // Check specific event data
      const expectedEventId = 'HPRO_LR3MS4JICA9'; // S8 Beijing
      final beijingResults = await repository.getRaceResultsByEvent(
        eventId: expectedEventId,
      );
      expect(beijingResults.length, greaterThan(0));
    });
  });
}
