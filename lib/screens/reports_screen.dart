import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/report_service.dart';
import '../utils/app_utils.dart';
import '../widgets/m3_components.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo'),
      ),
      body: Consumer<ReportService>(
        builder: (context, service, _) {
          if (service.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final report = service.currentReport;
          if (report == null) {
            return const Center(child: Text('Chưa có dữ liệu'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildPeriodSelector(service),
              const SizedBox(height: 16),
              _buildOverviewCard(report),
              const SizedBox(height: 16),
              _buildInsights(report),
              const SizedBox(height: 16),
              _buildLineChart(report),
              const SizedBox(height: 16),
              _buildCategoryBreakdown(report),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector(ReportService service) {
    return SegmentedButton<ReportPeriod>(
      segments: const [
        ButtonSegment(
          value: ReportPeriod.week,
          label: Text('7 ngày'),
          icon: Icon(Icons.view_week_outlined, size: 18),
        ),
        ButtonSegment(
          value: ReportPeriod.month,
          label: Text('30 ngày'),
          icon: Icon(Icons.calendar_month_outlined, size: 18),
        ),
      ],
      selected: {service.selectedPeriod},
      onSelectionChanged: (selection) {
        service.generateReport(selection.first);
      },
    );
  }

  Widget _buildOverviewCard(ReportData report) {
    return M3Card(
      color: AppColors.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: AppColors.onPrimaryContainer),
              const SizedBox(width: 8),
              const Text(
                'Tổng quan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onPrimaryContainer,
                ),
              ),
              const Spacer(),
              if (report.changeFromPrevious != 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: report.changeFromPrevious > 0
                        ? AppColors.success.withValues(alpha: 0.2)
                        : AppColors.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        report.changeFromPrevious > 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 14,
                        color: report.changeFromPrevious > 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${report.changeFromPrevious > 0 ? '+' : ''}${report.changeFromPrevious.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: report.changeFromPrevious > 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _bigStat('Đã làm', report.totalCompleted)),
              Expanded(child: _bigStat('Đã tạo', report.totalCreated)),
              Expanded(
                  child: _bigStat(
                      'Pomodoro', '${(report.totalPomodoroMinutes / 60).toStringAsFixed(1)}h')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bigStat(String label, dynamic value) {
    return Builder(builder: (context) {
      return Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: AppColors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onPrimaryContainer.withValues(alpha: 0.8),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildInsights(ReportData report) {
    if (report.insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Nhận xét',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
        ...report.insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: M3Card(
                padding: const EdgeInsets.all(14),
                child: Text(
                  insight,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary(context),
                    height: 1.4,
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildLineChart(ReportData report) {
    final maxY = report.dailyStats
        .map((s) => s.completed)
        .fold<int>(0, (a, b) => a > b ? a : b)
        .toDouble();

    return M3Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Số công việc hoàn thành theo ngày',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? (maxY / 4).ceilToDouble() : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.outline(context).withValues(alpha: 0.2),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: maxY > 0 ? (maxY / 4).ceilToDouble() : 1,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: report.period == ReportPeriod.week ? 1 : 5,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= report.dailyStats.length) {
                          return const SizedBox.shrink();
                        }
                        final date = report.dailyStats[value.toInt()].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${date.day}/${date.month}',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      report.dailyStats.length,
                      (i) => FlSpot(
                          i.toDouble(),
                          report.dailyStats[i].completed.toDouble()),
                    ),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: AppColors.surface(context),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: AppColors.surfaceContainerHigh(context),
                    tooltipBorder: BorderSide(color: AppColors.outline(context)),
                    getTooltipItems: (spots) => spots
                        .map((spot) => LineTooltipItem(
                              '${spot.y.toInt()} việc',
                              TextStyle(
                                color: AppColors.textPrimary(context),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ))
                        .toList(),
                  ),
                ),
                minY: 0,
                maxY: maxY < 3 ? 3 : maxY + 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(ReportData report) {
    final total = report.categoryBreakdown.values
        .fold<int>(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    return M3Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân bố theo danh mục',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          ...Category.values.map((cat) {
            final count = report.categoryBreakdown[cat] ?? 0;
            if (count == 0) return const SizedBox.shrink();
            final percent = (count / total * 100).toStringAsFixed(0);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                cat.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                            ),
                            Text(
                              '$count • $percent%',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: count / total,
                            backgroundColor:
                                AppColors.outline(context).withValues(alpha: 0.2),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(cat.color),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}