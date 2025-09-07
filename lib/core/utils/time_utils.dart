import 'dart:math' as math;

class TimeUtils {
  /// Parse time string (MM:SS or H:MM:SS) to Duration
  static Duration parseTimeString(String timeString) {
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

  /// Format Duration to string (H:MM:SS or MM:SS)
  static String formatDuration(Duration duration, {bool forceHours = false}) {
    if (duration == Duration.zero) return '0:00';
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0 || forceHours) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Format time string for display (ensure consistent formatting)
  static String formatTimeString(String timeString, {bool forceHours = false}) {
    final duration = parseTimeString(timeString);
    return formatDuration(duration, forceHours: forceHours);
  }

  /// Calculate pace (time per km) from time and distance
  static Duration calculatePace(Duration time, double distanceKm) {
    if (distanceKm <= 0) return Duration.zero;
    return Duration(seconds: (time.inSeconds / distanceKm).round());
  }

  /// Format pace as MM:SS/km
  static String formatPace(Duration pace) {
    final minutes = pace.inMinutes;
    final seconds = pace.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}/km';
  }

  /// Calculate average pace for runs (assuming 1km each)
  static Duration calculateAverageRunPace(List<Duration> runTimes) {
    if (runTimes.isEmpty) return Duration.zero;
    
    final totalSeconds = runTimes
        .where((time) => time > Duration.zero)
        .fold<int>(0, (sum, time) => sum + time.inSeconds);
    
    final validRuns = runTimes.where((time) => time > Duration.zero).length;
    if (validRuns == 0) return Duration.zero;
    
    return Duration(seconds: (totalSeconds / validRuns).round());
  }

  /// Calculate pace variation (standard deviation of run times)
  static Duration calculatePaceVariation(List<Duration> runTimes) {
    final validTimes = runTimes.where((time) => time > Duration.zero).toList();
    if (validTimes.length < 2) return Duration.zero;
    
    final mean = validTimes.fold<int>(0, (sum, time) => sum + time.inSeconds) / validTimes.length;
    
    final variance = validTimes.fold<double>(0, (sum, time) {
      final diff = time.inSeconds - mean;
      return sum + (diff * diff);
    }) / validTimes.length;
    
    return Duration(seconds: math.sqrt(variance).round());
  }

  /// Check if time string is valid
  static bool isValidTimeFormat(String timeString) {
    if (timeString.isEmpty) return false;
    
    final parts = timeString.split(':');
    if (parts.length != 2 && parts.length != 3) return false;
    
    for (final part in parts) {
      if (int.tryParse(part) == null) return false;
    }
    
    return true;
  }

  /// Convert time to decimal hours (for charts/calculations)
  static double timeToDecimalHours(Duration duration) {
    return duration.inSeconds / 3600.0;
  }

  /// Convert time to decimal minutes
  static double timeToDecimalMinutes(Duration duration) {
    return duration.inSeconds / 60.0;
  }

  /// Get time difference as percentage
  static double getTimeDifferencePercentage(Duration time1, Duration time2) {
    if (time2.inSeconds == 0) return 0.0;
    return ((time1.inSeconds - time2.inSeconds) / time2.inSeconds) * 100;
  }

  /// Format time difference with +/- prefix
  static String formatTimeDifference(Duration difference) {
    if (difference == Duration.zero) return '±0:00';
    
    final prefix = difference.isNegative ? '-' : '+';
    final absDifference = difference.abs();
    
    return '$prefix${formatDuration(absDifference)}';
  }

  /// Check if time is within expected range for HYROX events
  static bool isReasonableHyroxTime(Duration totalTime) {
    // HYROX total times typically range from 45 minutes to 3 hours
    const minTime = Duration(minutes: 30);
    const maxTime = Duration(hours: 4);
    
    return totalTime >= minTime && totalTime <= maxTime;
  }

  /// Calculate split times from cumulative times
  static List<Duration> calculateSplitTimes(List<Duration> cumulativeTimes) {
    if (cumulativeTimes.isEmpty) return [];
    
    final splits = <Duration>[];
    Duration previousTime = Duration.zero;
    
    for (final cumulativeTime in cumulativeTimes) {
      splits.add(cumulativeTime - previousTime);
      previousTime = cumulativeTime;
    }
    
    return splits;
  }

  /// Format multiple times for comparison display
  static String formatTimesComparison(List<Duration> times) {
    if (times.isEmpty) return '';
    if (times.length == 1) return formatDuration(times.first);
    
    final formattedTimes = times.map((time) => formatDuration(time)).toList();
    return formattedTimes.join(' | ');
  }

  /// Get time category (Fast, Average, Slow) based on percentile
  static String getTimeCategory(double percentile) {
    if (percentile >= 90) return 'Elite';
    if (percentile >= 75) return 'Excellent';
    if (percentile >= 50) return 'Good';
    if (percentile >= 25) return 'Average';
    return 'Needs Work';
  }

  /// Format time with appropriate precision
  static String formatTimeWithPrecision(Duration duration) {
    // Show milliseconds for very short times (< 10 seconds)
    if (duration.inSeconds < 10 && duration.inMilliseconds % 1000 != 0) {
      final seconds = duration.inMilliseconds / 1000;
      return '${seconds.toStringAsFixed(2)}s';
    }
    
    return formatDuration(duration);
  }
}

