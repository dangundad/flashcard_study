import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:flashcard_study/app/controllers/stats_controller.dart';

class StatsPage extends GetView<StatsController> {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.surface,
                cs.surfaceContainerLowest.withValues(alpha: 0.94),
                cs.surfaceContainerLow.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 14.w, 10.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'stats'.tr,
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => controller.refresh(),
                      tooltip: 'refresh'.tr,
                      icon: Icon(
                        Icons.refresh,
                        size: 20.r,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.refresh(),
                  color: cs.primary,
                  child: Obx(
                    () => ListView(
                      padding:
                          EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 24.h),
                      children: [
                        // ── Today Stats ──────────────────────────
                        _SectionTitle(cs: cs, title: 'stats_today'.tr),
                        SizedBox(height: 8.h),
                        _TodayCard(cs: cs, controller: controller),
                        SizedBox(height: 20.h),

                        // ── Streak ───────────────────────────────
                        _SectionTitle(cs: cs, title: 'stats_streak'.tr),
                        SizedBox(height: 8.h),
                        _StreakCard(cs: cs, controller: controller),
                        SizedBox(height: 20.h),

                        // ── Overall ──────────────────────────────
                        _SectionTitle(cs: cs, title: 'stats_overall'.tr),
                        SizedBox(height: 8.h),
                        _OverallCard(cs: cs, controller: controller),
                        SizedBox(height: 20.h),

                        // ── Weekly Chart ─────────────────────────
                        _SectionTitle(cs: cs, title: 'stats_weekly_chart'.tr),
                        SizedBox(height: 8.h),
                        _WeeklyChart(cs: cs, controller: controller),
                        SizedBox(height: 20.h),

                        // ── Deck Proficiency ─────────────────────
                        if (controller.deckStats.isNotEmpty) ...[
                          _SectionTitle(
                              cs: cs, title: 'stats_deck_mastery'.tr),
                          SizedBox(height: 8.h),
                          _DeckMasteryList(cs: cs, controller: controller),
                        ],
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section Title
// ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final ColorScheme cs;
  final String title;
  const _SectionTitle({required this.cs, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: cs.onSurfaceVariant,
        letterSpacing: 0.4,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Today Card
// ─────────────────────────────────────────────────────────────

class _TodayCard extends StatelessWidget {
  final ColorScheme cs;
  final StatsController controller;
  const _TodayCard({required this.cs, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(cs),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              cs: cs,
              icon: LucideIcons.bookOpen,
              value: '${controller.todayStudied.value}',
              label: 'stats_today_cards'.tr,
              color: cs.primary,
            ),
          ),
          Container(
            width: 1.w,
            height: 48.h,
            color: cs.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _StatItem(
              cs: cs,
              icon: LucideIcons.target,
              value: controller.deckStats.isEmpty
                  ? '-'
                  : '${(controller.masteredCards.value / (controller.totalCards.value == 0 ? 1 : controller.totalCards.value) * 100).round()}%',
              label: 'stats_mastery_rate'.tr,
              color: cs.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Streak Card
// ─────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final ColorScheme cs;
  final StatsController controller;
  const _StreakCard({required this.cs, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(cs),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              cs: cs,
              icon: LucideIcons.flame,
              value: '${controller.currentStreak.value}',
              label: 'stats_current_streak'.tr,
              color: Colors.orange,
            ),
          ),
          Container(
            width: 1.w,
            height: 48.h,
            color: cs.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _StatItem(
              cs: cs,
              icon: LucideIcons.trophy,
              value: '${controller.longestStreak.value}',
              label: 'stats_longest_streak'.tr,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Overall Card
// ─────────────────────────────────────────────────────────────

class _OverallCard extends StatelessWidget {
  final ColorScheme cs;
  final StatsController controller;
  const _OverallCard({required this.cs, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(cs),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              cs: cs,
              icon: LucideIcons.layers,
              value: '${controller.totalDecks.value}',
              label: 'stats_total_decks'.tr,
              color: cs.tertiary,
            ),
          ),
          Container(
            width: 1.w,
            height: 48.h,
            color: cs.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _StatItem(
              cs: cs,
              icon: LucideIcons.creditCard,
              value: '${controller.totalCards.value}',
              label: 'stats_total_cards'.tr,
              color: cs.primary,
            ),
          ),
          Container(
            width: 1.w,
            height: 48.h,
            color: cs.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _StatItem(
              cs: cs,
              icon: LucideIcons.circleCheck,
              value: '${controller.masteredCards.value}',
              label: 'mastered'.tr,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Weekly Chart
// ─────────────────────────────────────────────────────────────

class _WeeklyChart extends StatelessWidget {
  final ColorScheme cs;
  final StatsController controller;
  const _WeeklyChart({required this.cs, required this.controller});

  static const _days = ['6d', '5d', '4d', '3d', '2d', 'Yst', 'Today'];

  @override
  Widget build(BuildContext context) {
    final data = controller.weeklyData;
    final maxVal = data.fold(0, (prev, e) => e > prev ? e : prev);
    final chartMax = maxVal < 5 ? 5.0 : (maxVal * 1.2);

    return Container(
      height: 180.h,
      padding: EdgeInsets.fromLTRB(8.w, 16.h, 16.w, 8.h),
      decoration: _cardDecoration(cs),
      child: BarChart(
        BarChartData(
          maxY: chartMax,
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: chartMax / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: cs.outline.withValues(alpha: 0.15),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24.h,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= _days.length) {
                    return const SizedBox.shrink();
                  }
                  final isToday = idx == 6;
                  return Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      _days[idx],
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: isToday
                            ? cs.primary
                            : cs.onSurfaceVariant,
                        fontWeight: isToday
                            ? FontWeight.w700
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(7, (i) {
            final isToday = i == 6;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].toDouble(),
                  color: isToday
                      ? cs.primary
                      : cs.primary.withValues(alpha: 0.35),
                  width: 18.w,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(4.r),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Deck Mastery List
// ─────────────────────────────────────────────────────────────

class _DeckMasteryList extends StatelessWidget {
  final ColorScheme cs;
  final StatsController controller;
  const _DeckMasteryList({required this.cs, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(cs),
      child: Column(
        children: controller.deckStats.asMap().entries.map((entry) {
          final i = entry.key;
          final stat = entry.value;
          final isLast = i == controller.deckStats.length - 1;

          return Column(
            children: [
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat.deck.title,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${stat.mastered}/${stat.total} ${'mastered'.tr} · ${stat.due} ${'due'.tr}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: stat.progress,
                              minHeight: 6.h,
                              backgroundColor:
                                  cs.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                stat.progress >= 0.8
                                    ? Colors.green
                                    : stat.progress >= 0.5
                                        ? cs.primary
                                        : cs.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      '${(stat.progress * 100).round()}%',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: cs.outline.withValues(alpha: 0.15),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final ColorScheme cs;
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.cs,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20.r, color: color),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: cs.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

BoxDecoration _cardDecoration(ColorScheme cs) => BoxDecoration(
      color: cs.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
      boxShadow: [
        BoxShadow(
          color: cs.shadow.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
