import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:paybis_com_shifts/constants.dart';
import 'package:paybis_com_shifts/models/chart_data.dart';

class ProgressChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  ProgressChart(this.seriesList, {this.animate});

  /// Creates a stacked [BarChart] with data.
  factory ProgressChart.withData(List<SupportChartData> data) {
    data.sort((a, b) =>
        (DateTime(a.year, a.month)).compareTo(DateTime(b.year, b.month)));
    return new ProgressChart(
      _createData(data),
      // Disable animations for image tests.
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.NumericComboChart(
      seriesList,
      animate: animate,
      defaultRenderer: new charts.LineRendererConfig(),
      behaviors: [
        new charts.SeriesLegend(
          position: charts.BehaviorPosition.bottom,
        ),
      ],
    );
  }

  /// Create series list with multiple series
  static List<charts.Series<StatsForMonth, int>> _createData(
      List<SupportChartData> data) {
    int difference = 0;
    final List<StatsForMonth> transactionsMonthData = [];
    for (SupportChartData chartData in data) {
      difference = DateTime.now().year - chartData.year;
      if (chartData.year < DateTime.now().year) {
        chartData.month = chartData.month - (12 * (difference));
      }
      transactionsMonthData
          .add(new StatsForMonth(chartData.month, chartData.transactions));
    }

    final List<StatsForMonth> verificationsMonthData = [];
    for (SupportChartData chartData in data) {
      if ((chartData.year < DateTime.now().year)
//          ||chartData.year < dateTime.year && chartData.month >= dateTime.month
          ) {
        chartData.month = chartData.month - (12 * (difference));
      }
      verificationsMonthData
          .add(new StatsForMonth(chartData.month, chartData.verifications));
    }

    final List<StatsForMonth> chatsMonthData = [];
    for (SupportChartData chartData in data) {
      if (chartData.year < DateTime.now().year) {
        chartData.month = chartData.month - (12 * (difference));
      }
      chatsMonthData.add(new StatsForMonth(chartData.month, chartData.chats));
    }

    final List<StatsForMonth> averageMonthData = [];
    for (SupportChartData chartData in data) {
      if (chartData.year < DateTime.now().year) {
        chartData.month = chartData.month - (12 * difference);
      }
      averageMonthData.add(new StatsForMonth(
          chartData.month,
          ((chartData.chats +
                      chartData.verifications +
                      chartData.transactions) /
                  3)
              .round()));
    }

//    final List<StatsForMonth> totalMonthData = [];
//    for (SupportChartData chartData in data) {
//      if (chartData.year < dateTime.year && chartData.month >= dateTime.month) {
//        chartData.month = chartData.month - 12;
//      }
//      totalMonthData.add(new StatsForMonth(
//          chartData.month,
//          (chartData.chats +
//              chartData.transactions +
//              chartData.verifications)));
//    }

    return [
      new charts.Series<StatsForMonth, int>(
        id: kChats,
        displayName: kChats,
        domainFn: (StatsForMonth stats, _) => stats.month,
        measureFn: (StatsForMonth stats, _) => stats.productivity,
        data: chatsMonthData,
//        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault.lighter,
//        fillColorFn: (_, __) =>
//            charts.MaterialPalette.green.shadeDefault.lighter,
      ),
      new charts.Series<StatsForMonth, int>(
        id: kVerifications,
        displayName: 'Ver',
        domainFn: (StatsForMonth stats, _) => stats.month,
        measureFn: (StatsForMonth stats, _) => stats.productivity,
        data: verificationsMonthData,
//        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault.lighter,
//        fillColorFn: (_, __) =>
//            charts.MaterialPalette.blue.shadeDefault.lighter,
      ),
      new charts.Series<StatsForMonth, int>(
        id: kTransactions,
        displayName: "Trans",
        domainFn: (StatsForMonth stats, _) => stats.month,
        measureFn: (StatsForMonth stats, _) => stats.productivity,
        data: transactionsMonthData,
//        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault.lighter,
      ),
      new charts.Series<StatsForMonth, int>(
        id: 'Avg',
        displayName: 'Avg',
        domainFn: (StatsForMonth stats, _) => stats.month,
        measureFn: (StatsForMonth stats, _) => stats.productivity,
        data: averageMonthData,
//        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault.lighter,
      ),
//      new charts.Series<StatsForMonth, int>(
//        id: 'Total',
//        displayName: 'Ttl',
//        domainFn: (StatsForMonth stats, _) => stats.month,
//        measureFn: (StatsForMonth stats, _) => stats.productivity,
//        data: totalMonthData,
////        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault.lighter,
//      ),
    ];
  }
}

/// Sample ordinal data type.
class StatsForMonth {
  final int month;
  final int productivity;

  StatsForMonth(this.month, this.productivity);
}
