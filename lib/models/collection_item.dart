class CollectionItem {
  final int? id;
  final String name;
  final String description;
  final String createdAt;
  final String updatedAt;

  CollectionItem({
    this.id,
    required this.name,
    this.description = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  factory CollectionItem.fromMap(Map<String, dynamic> m) => CollectionItem(
        id: m['id'] as int?,
        name: (m['name'] as String?) ?? '',
        description: (m['description'] as String?) ?? '',
        createdAt: (m['created_at'] as String?) ?? '',
        updatedAt: (m['updated_at'] as String?) ?? '',
      );
}
