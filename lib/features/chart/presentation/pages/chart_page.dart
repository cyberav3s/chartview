import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chart_bloc.dart';
import 'detail_page.dart';

class ChartPage extends StatelessWidget {
  final String symbol;
  final String name;
  final double price;
  final double changePercent;

  const ChartPage({
    super.key, required this.symbol, required this.name,
    required this.price, required this.changePercent,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChartBloc(),
      child: ChartDetailPage(
        symbol: symbol, name: name, price: price, changePercent: changePercent,
      ),
    );
  }
}