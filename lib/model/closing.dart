class Closing {
  final String id;
  final double total;
  final DateTime date;
  final int totalSales;
  final Map<String, dynamic> productDetails; 
   // New fields
  final double totalExpenses;
  final Map<String, dynamic> expensesDetails;
  final double netProfit;

  Closing({
    required this.id,
    required this.total,
    required this.date,
    required this.totalSales,
    required this.productDetails,
        required this.totalExpenses,
    required this.expensesDetails,
    required this.netProfit,
  });

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'date': date.toIso8601String(),
      'totalSales': totalSales,
      'productDetails': productDetails,
        'totalExpenses': totalExpenses,
      'expensesDetails': expensesDetails,
      'netProfit': netProfit,
    };
  }

  factory Closing.fromMap(String id, Map<String, dynamic> map) {
    return Closing(
      id: id,
      total: map['total'],
      date: DateTime.parse(map['date']),
      totalSales: map['totalSales'],
      productDetails: Map<String, dynamic>.from(map['productDetails'] ?? {}),
        totalExpenses: map['totalExpenses'] ?? 0.0,
      expensesDetails: Map<String, dynamic>.from(map['expensesDetails'] ?? {}),
      netProfit: map['netProfit'] ?? 0.0,
    );
  }
}