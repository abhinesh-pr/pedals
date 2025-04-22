class MyComplaint {
  final String id;
  final String category;
  final String service;
  final String type;
  final String complaintNumber;
  final double amount;
  final String complaintDate;
  final String complaintOffice;
  final String description;
  final String status;
  final String createdAt;
  final String updatedAt;

  MyComplaint({
    required this.id,
    required this.category,
    required this.service,
    required this.type,
    required this.complaintNumber,
    required this.amount,
    required this.complaintDate,
    required this.complaintOffice,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MyComplaint.fromJson(Map<String, dynamic> json) {
    return MyComplaint(
      id: json['_id'] ?? '',
      category: json['category'] ?? '',
      service: json['service'] ?? '',
      type: json['type'] ?? '',
      complaintNumber: json['complaintNumber'] ?? '',
      amount: json['amount']?.toDouble() ?? 0.0,
      complaintDate: json['complaintDate'] ?? '',
      complaintOffice: json['complaintOffice'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}