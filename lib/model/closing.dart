class Closing {
  final String id;
  final double total;
  final DateTime date;
  final int totalSales;
  final Map<String, dynamic> productDetails; 

  Closing({
    required this.id,
    required this.total,
    required this.date,
    required this.totalSales,
    required this.productDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'date': date.toIso8601String(),
      'totalSales': totalSales,
      'productDetails': productDetails,
    };
  }

  factory Closing.fromMap(String id, Map<String, dynamic> map) {
    return Closing(
      id: id,
      total: map['total'],
      date: DateTime.parse(map['date']),
      totalSales: map['totalSales'],
      productDetails: Map<String, dynamic>.from(map['productDetails'] ?? {}),
    );
  }
}