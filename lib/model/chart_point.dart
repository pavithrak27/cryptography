import 'coin.dart';

class ChartPoint {
  final double time; 
  final double price;
  ChartPoint(this.time, this.price);

  factory ChartPoint.fromJson(Map<String, dynamic> j) => ChartPoint(toD(j['t']), toD(j['price']));
}