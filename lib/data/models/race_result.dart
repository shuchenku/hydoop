import 'package:equatable/equatable.dart';

class RaceResult extends Equatable {
  final String eventId;
  final String eventName;
  final int id;
  final String name;
  final String gender;
  final String nationality;
  final String ageGroup;
  final String division;
  final String totalTime;
  final String workTime;
  final String roxzoneTime;
  final String runTime;
  final List<String> runs; // run_1 through run_8
  final List<String> works; // work_1 through work_8
  final List<String> roxzones; // roxzone_1 through roxzone_8

  const RaceResult({
    required this.eventId,
    required this.eventName,
    required this.id,
    required this.name,
    required this.gender,
    required this.nationality,
    required this.ageGroup,
    required this.division,
    required this.totalTime,
    required this.workTime,
    required this.roxzoneTime,
    required this.runTime,
    required this.runs,
    required this.works,
    required this.roxzones,
  });

  // Factory constructor for creating from CSV row
  factory RaceResult.fromCsvRow(List<String> row) {
    if (row.length < 35) {
      throw ArgumentError('CSV row must have at least 35 columns');
    }

    return RaceResult(
      eventId: row[0],
      eventName: row[1],
      id: int.tryParse(row[2]) ?? 0,
      name: row[3],
      gender: row[4],
      nationality: row[5],
      ageGroup: row[6],
      division: row[7],
      totalTime: row[8],
      workTime: row[9],
      roxzoneTime: row[10],
      runTime: row[11],
      runs: [
        row[12], row[15], row[18], row[21], row[24], row[27], row[30], row[33]
      ], // run_1, run_2, ..., run_8
      works: [
        row[13], row[16], row[19], row[22], row[25], row[28], row[31], row[34]
      ], // work_1, work_2, ..., work_8
      roxzones: [
        row[14], row[17], row[20], row[23], row[26], row[29], row[32], row[35]
      ], // roxzone_1, roxzone_2, ..., roxzone_8
    );
  }

  // Factory constructor for creating from database map
  factory RaceResult.fromMap(Map<String, dynamic> map) {
    return RaceResult(
      eventId: map['event_id'] as String,
      eventName: map['event_name'] as String,
      id: map['id'] as int,
      name: map['name'] as String,
      gender: map['gender'] as String,
      nationality: map['nationality'] as String,
      ageGroup: map['age_group'] as String,
      division: map['division'] as String,
      totalTime: map['total_time'] as String,
      workTime: map['work_time'] as String,
      roxzoneTime: map['roxzone_time'] as String,
      runTime: map['run_time'] as String,
      runs: [
        map['run_1'] as String,
        map['run_2'] as String,
        map['run_3'] as String,
        map['run_4'] as String,
        map['run_5'] as String,
        map['run_6'] as String,
        map['run_7'] as String,
        map['run_8'] as String,
      ],
      works: [
        map['work_1'] as String,
        map['work_2'] as String,
        map['work_3'] as String,
        map['work_4'] as String,
        map['work_5'] as String,
        map['work_6'] as String,
        map['work_7'] as String,
        map['work_8'] as String,
      ],
      roxzones: [
        map['roxzone_1'] as String,
        map['roxzone_2'] as String,
        map['roxzone_3'] as String,
        map['roxzone_4'] as String,
        map['roxzone_5'] as String,
        map['roxzone_6'] as String,
        map['roxzone_7'] as String,
        map['roxzone_8'] as String,
      ],
    );
  }

  // Convert to map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'event_id': eventId,
      'event_name': eventName,
      'id': id,
      'name': name,
      'gender': gender,
      'nationality': nationality,
      'age_group': ageGroup,
      'division': division,
      'total_time': totalTime,
      'work_time': workTime,
      'roxzone_time': roxzoneTime,
      'run_time': runTime,
      'run_1': runs[0],
      'run_2': runs[1],
      'run_3': runs[2],
      'run_4': runs[3],
      'run_5': runs[4],
      'run_6': runs[5],
      'run_7': runs[6],
      'run_8': runs[7],
      'work_1': works[0],
      'work_2': works[1],
      'work_3': works[2],
      'work_4': works[3],
      'work_5': works[4],
      'work_6': works[5],
      'work_7': works[6],
      'work_8': works[7],
      'roxzone_1': roxzones[0],
      'roxzone_2': roxzones[1],
      'roxzone_3': roxzones[2],
      'roxzone_4': roxzones[3],
      'roxzone_5': roxzones[4],
      'roxzone_6': roxzones[5],
      'roxzone_7': roxzones[6],
      'roxzone_8': roxzones[7],
    };
  }

  // Convenience getters
  String get season {
    // Extract season from event name (e.g., "S8 2025 Beijing" -> "S8")
    final seasonMatch = RegExp(r'S(\d+)').firstMatch(eventName);
    return seasonMatch?.group(0) ?? 'Unknown';
  }

  String get location {
    // Extract location from event name (e.g., "S8 2025 Beijing" -> "Beijing")
    final parts = eventName.split(' ');
    return parts.length >= 3 ? parts.sublist(2).join(' ') : eventName;
  }

  String get year {
    // Extract year from event name (e.g., "S8 2025 Beijing" -> "2025")
    final yearMatch = RegExp(r'\b(20\d{2})\b').firstMatch(eventName);
    return yearMatch?.group(1) ?? 'Unknown';
  }

  // Time parsing utilities
  Duration parseTime(String timeString) {
    if (timeString.isEmpty || timeString == '0:00:00') return Duration.zero;
    
    final parts = timeString.split(':');
    if (parts.length == 2) {
      // MM:SS format
      return Duration(
        minutes: int.tryParse(parts[0]) ?? 0,
        seconds: int.tryParse(parts[1]) ?? 0,
      );
    } else if (parts.length == 3) {
      // H:MM:SS format
      return Duration(
        hours: int.tryParse(parts[0]) ?? 0,
        minutes: int.tryParse(parts[1]) ?? 0,
        seconds: int.tryParse(parts[2]) ?? 0,
      );
    }
    return Duration.zero;
  }

  Duration get totalDuration => parseTime(totalTime);
  Duration get workDuration => parseTime(workTime);
  Duration get roxzoneDuration => parseTime(roxzoneTime);
  Duration get runDuration => parseTime(runTime);

  List<Duration> get runDurations => runs.map(parseTime).toList();
  List<Duration> get workDurations => works.map(parseTime).toList();
  List<Duration> get roxzoneDurations => roxzones.map(parseTime).toList();

  @override
  List<Object?> get props => [
        eventId,
        eventName,
        id,
        name,
        gender,
        nationality,
        ageGroup,
        division,
        totalTime,
        workTime,
        roxzoneTime,
        runTime,
        runs,
        works,
        roxzones,
      ];

  RaceResult copyWith({
    String? eventId,
    String? eventName,
    int? id,
    String? name,
    String? gender,
    String? nationality,
    String? ageGroup,
    String? division,
    String? totalTime,
    String? workTime,
    String? roxzoneTime,
    String? runTime,
    List<String>? runs,
    List<String>? works,
    List<String>? roxzones,
  }) {
    return RaceResult(
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      ageGroup: ageGroup ?? this.ageGroup,
      division: division ?? this.division,
      totalTime: totalTime ?? this.totalTime,
      workTime: workTime ?? this.workTime,
      roxzoneTime: roxzoneTime ?? this.roxzoneTime,
      runTime: runTime ?? this.runTime,
      runs: runs ?? this.runs,
      works: works ?? this.works,
      roxzones: roxzones ?? this.roxzones,
    );
  }
}