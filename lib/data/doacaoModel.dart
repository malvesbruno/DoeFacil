class Donation {
  final String? id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final DateTime expirationDate;

  Donation({this.id, required this.name, required this.category, required this.quantity, required this.unit, required this.expirationDate});

  // Converter para Map para salvar no Firestore
  Map<String, dynamic> toMap() => {
    'name': name,
    'category': category,
    'quantity': quantity,
    'unit': unit,
    'expirationDate': expirationDate.toIso8601String(),
  };
}