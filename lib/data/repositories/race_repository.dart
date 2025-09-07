import '../models/race_result.dart';
import '../datasources/database_helper.dart';

abstract class RaceRepository {
  Future<List<RaceResult>> getAllRaceResults({int? limit, int? offset});
  Future<List<RaceResult>> getRaceResultsByEvent({
    required String eventId,
    int? limit,
    int? offset,
  });
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
  });
  Future<RaceResult?> getRaceResultById(int id);
  Future<List<String>> getUniqueEvents();
  Future<List<String>> getUniqueDivisions();
  Future<List<String>> getUniqueAgeGroups();
  Future<List<String>> getUniqueNationalities();
  Future<int> getResultCount({
    String? eventId,
    String? division,
    String? gender,
    String? ageGroup,
  });
}

class RaceRepositoryImpl implements RaceRepository {
  final DatabaseHelper _databaseHelper;

  RaceRepositoryImpl({DatabaseHelper? databaseHelper}) 
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<List<RaceResult>> getAllRaceResults({int? limit, int? offset}) {
    return _databaseHelper.getAllRaceResults(limit: limit, offset: offset);
  }

  @override
  Future<List<RaceResult>> getRaceResultsByEvent({
    required String eventId,
    int? limit,
    int? offset,
  }) {
    return _databaseHelper.getRaceResultsByEvent(
      eventId: eventId,
      limit: limit,
      offset: offset,
    );
  }

  @override
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
  }) {
    return _databaseHelper.searchRaceResults(
      eventId: eventId,
      division: division,
      gender: gender,
      ageGroup: ageGroup,
      nationality: nationality,
      firstName: firstName,
      lastName: lastName,
      bibNumber: bibNumber,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<RaceResult?> getRaceResultById(int id) {
    return _databaseHelper.getRaceResultById(id);
  }

  @override
  Future<List<String>> getUniqueEvents() {
    return _databaseHelper.getUniqueEvents();
  }

  @override
  Future<List<String>> getUniqueDivisions() {
    return _databaseHelper.getUniqueDivisions();
  }

  @override
  Future<List<String>> getUniqueAgeGroups() {
    return _databaseHelper.getUniqueAgeGroups();
  }

  @override
  Future<List<String>> getUniqueNationalities() {
    return _databaseHelper.getUniqueNationalities();
  }

  @override
  Future<int> getResultCount({
    String? eventId,
    String? division,
    String? gender,
    String? ageGroup,
  }) {
    return _databaseHelper.getResultCount(
      eventId: eventId,
      division: division,
      gender: gender,
      ageGroup: ageGroup,
    );
  }
}