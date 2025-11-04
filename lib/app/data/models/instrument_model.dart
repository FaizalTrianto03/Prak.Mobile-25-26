class InstrumentModel {
  final int? id;
  final String name;
  final String? description;
  final DateTime? createdAt;

  InstrumentModel({
    this.id,
    required this.name,
    this.description,
    this.createdAt,
  });

  // From JSON
  factory InstrumentModel.fromJson(Map<String, dynamic> json) {
    return InstrumentModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  // To JSON (for reading data)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  // To JSON for insert/update (exclude id and created_at - they're auto-generated)
  Map<String, dynamic> toJsonForInsert() {
    return {
      'name': name,
      if (description != null && description!.isNotEmpty) 
        'description': description,
    };
  }

  // CopyWith
  InstrumentModel copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return InstrumentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
