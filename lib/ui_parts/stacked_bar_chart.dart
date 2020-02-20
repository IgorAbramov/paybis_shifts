import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/models/chart_data.dart';

class StackedBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  StackedBarChart(this.seriesList, {this.animate});

  /// Creates a stacked [BarChart] with data.
  factory StackedBarChart.withData(List<SupportChartData> data) {
    data.sort((a, b) => (a.transactions + a.verifications + a.chats)
        .compareTo(b.transactions + b.verifications + b.chats));
    return new StackedBarChart(
      _createData(data),
      // Disable animations for image tests.
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      barGroupingType: charts.BarGroupingType.stacked,
      behaviors: [
        new charts.SeriesLegend(
          position: charts.BehaviorPosition.bottom,
        ),
      ],
    );
  }

  /// Create series list with multiple series
  static List<charts.Series<StatsForMonth, String>> _createData(
      List<SupportChartData> data) {
    final List<StatsForMonth> transactionsMonthData = [];
    for (SupportChartData chartData in data) {
      transactionsMonthData
          .add(new StatsForMonth(chartData.initial, chartData.transactions));
    }

    final List<StatsForMonth> verificationsMonthData = [];
    for (SupportChartData chartData in data) {
      verificationsMonthData
          .add(new StatsForMonth(chartData.initial, chartData.verifications));
    }

    final List<StatsForMonth> chatsMonthData = [];
    for (SupportChartData chartData in data) {
      chatsMonthData.add(new StatsForMonth(chartData.initial, chartData.chats));
    }

    return [
      new charts.Series<StatsForMonth, String>(
        id: kChats,
        displayName: kChats,
        domainFn: (StatsForMonth stats, _) => stats.empName,
        measureFn: (StatsForMonth stats, _) => stats.productivity,
        data: chatsMonthData,
//        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault.lighter,
//        fillColorFn: (_, __) =>
//            charts.MaterialPalette.green.shadeDefault.lighter,
      ),
      new charts.Series<StatsForMonth, String>(
        id: kVerifications,
        displayName: kVerifications,
        domainFn: (StatsForMonth stats, _) => stats.empName,
        measureFn: (StatsForMonth stats, _) => stats.productivity,
        data: verificationsMonthData,
//        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault.lighter,
//        fillColorFn: (_, __) =>
//            charts.MaterialPalette.blue.shadeDefault.lighter,
      ),
      new charts.Series<StatsForMonth, String>(
        id: kTransactions,
        displayName: kTransactions,
        domainFn: (StatsForMonth stats, _) => stats.empName,
        measureFn: (StatsForMonth stats, _) => stats.productivity,
        data: transactionsMonthData,
//        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault.lighter,
      ),
    ];
  }
}

/// Sample ordinal data type.
class StatsForMonth {
  final String empName;
  final int productivity;

  StatsForMonth(this.empName, this.productivity);
}
