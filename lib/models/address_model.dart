class AddressModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String? notes;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.notes,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'address': address,
    'notes': notes,
    'isDefault': isDefault,
  };

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    id: json['id'],
    name: json['name'],
    phone: json['phone'],
    address: json['address'],
    notes: json['notes'],
    isDefault: json['isDefault'] ?? false,
  );

  AddressModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? notes,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
