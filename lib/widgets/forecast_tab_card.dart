import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import 'hourly_card.dart';
import 'forecast_card.dart';

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
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.black54,
            tabs: const [
              Tab(text: 'Hourly'),
              Tab(text: 'Weekly'),
            ],
          ),
          SizedBox(
            height: 200,
            child: TabBarView(
              controller: _tabController,
              children: [
                _hourlyView(),
                _weeklyView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hourlyView() {
    final hourly = widget.weather.hourly;
    if (hourly.isEmpty) {
      return const Center(child: Text('No hourly data'));
    }
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: hourly.length,
      itemBuilder: (context, index) => HourlyCard(hour: hourly[index]),
    );
  }

  Widget _weeklyView() {
    final forecast = widget.weather.forecast;
    if (forecast.isEmpty) {
      return const Center(child: Text('No forecast data'));
    }
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: forecast.length,
      itemBuilder: (context, index) => ForecastCard(day: forecast[index]),
    );
  }
}
