import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/race_result.dart';

class DatabaseHelper {
  static const _databaseName = 'hydoop.db';
  static const _databaseVersion = 1;
  static const _tableName = 'race_results';

  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._privateConstructor();
  
  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._privateConstructor();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        internal_id INTEGER PRIMARY KEY AUTOINCREMENT,
        event_id TEXT NOT NULL,
        event_name TEXT NOT NULL,
        id INTEGER NOT NULL,
        name TEXT NOT NULL,
        gender TEXT NOT NULL,
        nationality TEXT NOT NULL,
        age_group TEXT NOT NULL,
        division TEXT NOT NULL,
        total_time TEXT NOT NULL,
        work_time TEXT NOT NULL,
        roxzone_time TEXT NOT NULL,
        run_time TEXT NOT NULL,
        run_1 TEXT NOT NULL,
        work_1 TEXT NOT NULL,
        roxzone_1 TEXT NOT NULL,
        run_2 TEXT NOT NULL,
        work_2 TEXT NOT NULL,
        roxzone_2 TEXT NOT NULL,
        run_3 TEXT NOT NULL,
        work_3 TEXT NOT NULL,
        roxzone_3 TEXT NOT NULL,
        run_4 TEXT NOT NULL,
        work_4 TEXT NOT NULL,
        roxzone_4 TEXT NOT NULL,
        run_5 TEXT NOT NULL,
        work_5 TEXT NOT NULL,
        roxzone_5 TEXT NOT NULL,
        run_6 TEXT NOT NULL,
        work_6 TEXT NOT NULL,
        roxzone_6 TEXT NOT NULL,
        run_7 TEXT NOT NULL,
        work_7 TEXT NOT NULL,
        roxzone_7 TEXT NOT NULL,
        run_8 TEXT NOT NULL,
        work_8 TEXT NOT NULL,
        roxzone_8 TEXT NOT NULL
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_event_id ON $_tableName(event_id)');
    await db.execute('CREATE INDEX idx_division ON $_tableName(division)');
    await db.execute('CREATE INDEX idx_gender ON $_tableName(gender)');
    await db.execute('CREATE INDEX idx_age_group ON $_tableName(age_group)');
    await db.execute('CREATE INDEX idx_nationality ON $_tableName(nationality)');
    
    // Create unique constraint on event_id + id to prevent true duplicates
    await db.execute('CREATE UNIQUE INDEX idx_event_bib ON $_tableName(event_id, id)');
    
    // Import initial data
    await _importInitialData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades here
    if (oldVersion < newVersion) {
      // For now, recreate the table
      await db.execute('DROP TABLE IF EXISTS $_tableName');
      await _onCreate(db, newVersion);
    }
  }

  Future<void> _importInitialData(Database db) async {
    try {
      // Import S8 Beijing data
      await _importCsvFile(db, 'assets/data/S8 2025 Beijing.csv');
      
      // Import S7 Shanghai data
      await _importCsvFile(db, 'assets/data/S7 2025 Shanghai.csv');
      
      // Check final count
      final count = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
      print('Successfully imported initial race data. Total records: ${count.first['count']}');
    } catch (e) {
      print('Error importing initial data: $e');
    }
  }

  Future<void> _importCsvFile(Database db, String assetPath) async {
    try {
      final csvString = await rootBundle.loadString(assetPath);
      final List<List<dynamic>> csvData = const CsvToListConverter(eol: '\n').convert(csvString);
      
      // Skip header row
      final dataRows = csvData.skip(1);
      
      // Process in batches for better performance
      const batchSize = 100;
      final batches = <List<List<dynamic>>>[];
      
      for (int i = 0; i < dataRows.length; i += batchSize) {
        final end = (i + batchSize < dataRows.length) ? i + batchSize : dataRows.length;
        batches.add(dataRows.skip(i).take(end - i).toList());
      }
      
      int totalImported = 0;
      int totalErrors = 0;
      
      for (int batchIndex = 0; batchIndex < batches.length; batchIndex++) {
        final batch = batches[batchIndex];
        await db.transaction((txn) async {
          for (final row in batch) {
            try {
              final rowStrings = row.map((e) => e?.toString() ?? '').toList();
              final raceResult = RaceResult.fromCsvRow(rowStrings);
              await txn.insert(_tableName, raceResult.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
              totalImported++;
            } catch (e) {
              totalErrors++;
              if (totalErrors <= 5) {
                print('Error importing row: $e');
              }
              continue;
            }
          }
        });
      }
      
      print('Import complete for $assetPath: $totalImported imported, $totalErrors errors');
    } catch (e) {
      print('Error importing CSV file $assetPath: $e');
      throw e;
    }
  }

  // CRUD operations
  Future<int> insertRaceResult(RaceResult raceResult) async {
    final db = await database;
    return await db.insert(_tableName, raceResult.toMap());
  }

  Future<List<RaceResult>> getAllRaceResults({
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      limit: limit,
      offset: offset,
      orderBy: 'total_time ASC',
    );
    
    return List.generate(maps.length, (i) {
      return RaceResult.fromMap(maps[i]);
    });
  }

  Future<List<RaceResult>> getRaceResultsByEvent({
    required String eventId,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'event_id = ?',
      whereArgs: [eventId],
      limit: limit,
      offset: offset,
      orderBy: 'total_time ASC',
    );
    
    return List.generate(maps.length, (i) {
      return RaceResult.fromMap(maps[i]);
    });
  }

  Future<List<RaceResult>> searchRaceResults({
    String? eventId,
    String? division,
    String? gender,
    String? ageGroup,
    String? nationality,
    String? firstName,
    String? lastName,
    String? bibNumber,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    
    final conditions = <String>[];
    final args = <dynamic>[];
    
    if (eventId != null && eventId.isNotEmpty) {
      conditions.add('event_id = ?');
      args.add(eventId);
    }
    
    if (division != null && division.isNotEmpty) {
      conditions.add('division = ?');
      args.add(division);
    }
    
    if (gender != null && gender.isNotEmpty) {
      conditions.add('gender = ?');
      args.add(gender);
    }
    
    if (ageGroup != null && ageGroup.isNotEmpty) {
      conditions.add('age_group = ?');
      args.add(ageGroup);
    }
    
    if (nationality != null && nationality.isNotEmpty) {
      conditions.add('nationality = ?');
      args.add(nationality);
    }
    
    if (firstName != null && firstName.isNotEmpty) {
      conditions.add('name LIKE ?');
      args.add('$firstName%');
    }
    
    if (lastName != null && lastName.isNotEmpty) {
      conditions.add('name LIKE ?');
      args.add('%$lastName%');
    }
    
    if (bibNumber != null && bibNumber.isNotEmpty) {
      conditions.add('id = ?');
      args.add(int.tryParse(bibNumber) ?? -1);
    }
    
    final whereClause = conditions.isEmpty ? null : conditions.join(' AND ');
    
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: whereClause,
      whereArgs: args.isEmpty ? null : args,
      limit: limit,
      offset: offset,
      orderBy: 'total_time ASC',
    );
    
    return List.generate(maps.length, (i) {
      return RaceResult.fromMap(maps[i]);
    });
  }

  Future<RaceResult?> getRaceResultById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return RaceResult.fromMap(maps.first);
    }
    return null;
  }

  Future<List<String>> getUniqueEvents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      columns: ['DISTINCT event_id', 'event_name'],
      orderBy: 'event_name ASC',
    );
    
    return maps.map((map) => map['event_name'] as String).toList();
  }

  Future<List<String>> getUniqueDivisions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      columns: ['DISTINCT division'],
      orderBy: 'division ASC',
    );
    
    return maps.map((map) => map['division'] as String).toList();
  }

  Future<List<String>> getUniqueAgeGroups() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      columns: ['DISTINCT age_group'],
      orderBy: 'age_group ASC',
    );
    
    return maps.map((map) => map['age_group'] as String).toList();
  }

  Future<List<String>> getUniqueNationalities() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      columns: ['DISTINCT nationality'],
      orderBy: 'nationality ASC',
    );
    
    return maps.map((map) => map['nationality'] as String).toList();
  }

  Future<int> getResultCount({
    String? eventId,
    String? division,
    String? gender,
    String? ageGroup,
  }) async {
    final db = await database;
    
    final conditions = <String>[];
    final args = <dynamic>[];
    
    if (eventId != null && eventId.isNotEmpty) {
      conditions.add('event_id = ?');
      args.add(eventId);
    }
    
    if (division != null && division.isNotEmpty) {
      conditions.add('division = ?');
      args.add(division);
    }
    
    if (gender != null && gender.isNotEmpty) {
      conditions.add('gender = ?');
      args.add(gender);
    }
    
    if (ageGroup != null && ageGroup.isNotEmpty) {
      conditions.add('age_group = ?');
      args.add(ageGroup);
    }
    
    final whereClause = conditions.isEmpty ? null : conditions.join(' AND ');
    
    final result = await db.query(
      _tableName,
      columns: ['COUNT(*) as count'],
      where: whereClause,
      whereArgs: args.isEmpty ? null : args,
    );
    
    return result.first['count'] as int;
  }

  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete(_tableName);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}