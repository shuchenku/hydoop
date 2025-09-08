import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

void main() {
  group('CSV Parsing Tests', () {
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('CSV can be parsed correctly', () async {
      // Load the CSV file
      final csvString = await rootBundle.loadString('assets/data/S8 2025 Beijing.csv');
      
      // Test with Unix line endings (correct format)
      final converter = const CsvToListConverter(eol: '\n');
      final data = converter.convert(csvString);
      
      expect(data.length, greaterThan(1), reason: 'CSV should have more than just header row');
      expect(data.length, greaterThan(1000), reason: 'Beijing CSV should have over 1000 race results');
    });
  });
}