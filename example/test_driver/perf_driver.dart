import 'dart:convert';
import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart' as driver;
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
      responseDataCallback: (data) async {
        if (data == null || data.isEmpty) {
          stderr.writeln('No performance data collected.');
          return;
        }

        final summaryList = <Map<String, dynamic>>[];
        var totalMissedBuildBudgets = 0;
        var totalMissedRasterBudgets = 0;

        stdout.writeln(
            '\n===========================================================================================================================');
        stdout.writeln(
            '                                             E2E PERFORMANCE BENCHMARK REPORT                                              ');
        stdout.writeln(
            '===========================================================================================================================');
        stdout.writeln(
          sprintfHeader(
            'Scenario',
            'Avg Build',
            'Worst Build',
            'Worst Raster',
            'Build Budget',
            'Raster Target',
            'Status',
          ),
        );
        stdout.writeln(
            '---------------------------------------------------------------------------------------------------------------------------');

        for (final entry in data.entries) {
          if (entry.value is! Map<String, dynamic>) continue;
          final reportData = entry.value as Map<String, dynamic>;

          Map<String, dynamic> summaryJson;

          // If the entry contains raw timeline events from binding.traceAction,
          // summarize with TimelineSummary as described in Flutter Cookbook.
          if (reportData.containsKey('traceEvents')) {
            final timeline = driver.Timeline.fromJson(reportData);
            final summary = driver.TimelineSummary.summarize(timeline);

            await summary.writeTimelineToFile(
              entry.key,
              pretty: true,
              includeSummary: true,
            );
            summaryJson = summary.summaryJson;
          } else {
            summaryJson = reportData;
          }

          final avgBuild =
              (summaryJson['average_frame_build_time_millis'] as num?)
                      ?.toDouble() ??
                  0.0;
          final p90Build = (summaryJson['p90_frame_build_time_millis'] as num?)
                  ?.toDouble() ??
              0.0;
          final worstBuild =
              (summaryJson['worst_frame_build_time_millis'] as num?)
                      ?.toDouble() ??
                  0.0;
          final missedBuild =
              (summaryJson['missed_frame_build_budget_count'] as num?)
                      ?.toInt() ??
                  0;

          final avgRaster =
              (summaryJson['average_frame_rasterizer_time_millis'] as num?)
                      ?.toDouble() ??
                  0.0;
          final p90Raster =
              (summaryJson['90th_percentile_frame_rasterizer_time_millis']
                          as num?)
                      ?.toDouble() ??
                  (summaryJson['p90_frame_rasterizer_time_millis'] as num?)
                      ?.toDouble() ??
                  0.0;
          final worstRaster =
              (summaryJson['worst_frame_rasterizer_time_millis'] as num?)
                      ?.toDouble() ??
                  0.0;
          final missedRaster =
              (summaryJson['missed_frame_rasterizer_budget_count'] as num?)
                      ?.toInt() ??
                  0;

          totalMissedBuildBudgets += missedBuild;
          totalMissedRasterBudgets += missedRaster;

          // Realistic tiered performance budgets:
          // Build Budget: < 4.0ms (leaves ample headroom for 120Hz/60Hz frame budgets)
          // 120 FPS Target: P90 Raster <= 8.33ms and Worst Build <= 4.0ms
          // 60 FPS Target:  P90 Raster <= 16.67ms and Worst Build <= 8.0ms
          final String status;
          if (missedBuild > 0 ||
              worstBuild > 8.0 ||
              missedRaster > 1 ||
              p90Raster > 16.67) {
            status = 'FAIL [Jank]';
          } else if (worstRaster <= 8.33 && worstBuild <= 4.0) {
            status = 'PASS [120fps]';
          } else if (p90Raster <= 8.33 && worstBuild <= 4.0) {
            status = 'PASS [120fps*]';
          } else {
            status = 'PASS [60fps]';
          }

          summaryList.add({
            'scenario': entry.key,
            'avg_build_ms': avgBuild,
            'p90_build_ms': p90Build,
            'worst_build_ms': worstBuild,
            'missed_build_budget_count': missedBuild,
            'avg_raster_ms': avgRaster,
            'p90_raster_ms': p90Raster,
            'worst_raster_ms': worstRaster,
            'missed_raster_budget_count': missedRaster,
            'build_budget': '< 4.00ms',
            'raster_target': '< 8.33ms (120fps)',
            'status': status,
          });

          stdout.writeln(
            sprintfRow(
              entry.key,
              '${avgBuild.toStringAsFixed(2)}ms',
              '${worstBuild.toStringAsFixed(2)}ms',
              '${worstRaster.toStringAsFixed(2)}ms',
              '< 4.00ms',
              '< 8.33ms (120fps)',
              status,
            ),
          );
        }

        stdout.writeln(
            '===========================================================================================================================\n');

        // Write consolidated report to build/performance_summary.json
        final outputDir = Directory('build');
        if (!outputDir.existsSync()) {
          outputDir.createSync(recursive: true);
        }
        final reportFile = File('build/performance_summary.json');
        final reportData = {
          'timestamp': DateTime.now().toIso8601String(),
          'total_missed_build_budgets': totalMissedBuildBudgets,
          'total_missed_raster_budgets': totalMissedRasterBudgets,
          'scenarios': summaryList,
        };
        reportFile.writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert(reportData),
        );
        stdout.writeln('Performance summary written to ${reportFile.path}');

        final hasFailed = summaryList.any((s) => s['status'] == 'FAIL [Jank]');
        if (hasFailed || totalMissedBuildBudgets > 0) {
          stderr.writeln(
              'WARNING: Frame performance dropped below the acceptable budget.');
          exitCode = 1;
        } else {
          stdout.writeln(
              'SUCCESS: All scenarios stayed within the 60fps/120fps performance budget.');
        }
      },
    );

String sprintfHeader(
  String col1,
  String col2,
  String col3,
  String col4,
  String col5,
  String col6,
  String col7,
) {
  return '${col1.padRight(36)} '
      '${col2.padLeft(10)} '
      '${col3.padLeft(12)} '
      '${col4.padLeft(13)} '
      '${col5.padLeft(14)} '
      '${col6.padLeft(18)} '
      '${col7.padLeft(15)}';
}

String sprintfRow(
  String col1,
  String col2,
  String col3,
  String col4,
  String col5,
  String col6,
  String col7,
) {
  return '${col1.padRight(36)} '
      '${col2.padLeft(10)} '
      '${col3.padLeft(12)} '
      '${col4.padLeft(13)} '
      '${col5.padLeft(14)} '
      '${col6.padLeft(18)} '
      '${col7.padLeft(15)}';
}
