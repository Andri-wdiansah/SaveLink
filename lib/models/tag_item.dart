class TagItem {
  final int? id;
  final String name;
  final String createdAt;
  TagItem({this.id, required this.name, required this.createdAt});
  Map<String, dynamic> toMap() =>
      {'id': id, 'name': name, 'created_at': createdAt};
  factory TagItem.fromMap(Map<String, dynamic> m) => TagItem(
      id: m['id'] as int?,
      name: (m['name'] as String?) ?? '',
      createdAt: (m['created_at'] as String?) ?? '');
}
