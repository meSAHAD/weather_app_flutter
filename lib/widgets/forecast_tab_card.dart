import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'hourly_forecast_section.dart';
import 'weekly_forecast_section.dart';

class ForecastTabCard extends StatefulWidget {
  final Weather weather;

  const ForecastTabCard({super.key, required this.weather});

  @override
  State<ForecastTabCard> createState() => _ForecastTabCardState();
}

class _ForecastTabCardState extends State<ForecastTabCard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.zero,
            indicator: BoxDecoration(
              color: Colors.teal.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            tabs: const [
              Tab(text: 'Hourly'),
              Tab(text: '7 Days'),
            ],
          ),
        ),
        SizedBox(
          // Adjust height to fit the new list view style
          height: MediaQuery.of(context).size.height * 0.4,
          child: TabBarView(
            controller: _tabController,
            children: [
              HourlyForecastTab(
                hourly: widget.weather.hourly,
                isTransparent: true,
              ),
              WeeklyForecastTab(
                forecast: widget.weather.forecast,
                isTransparent: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
