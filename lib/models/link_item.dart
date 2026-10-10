class LinkItem {
  final int? id;
  final String title;
  final String url;
  final String description;
  final String tags;
  final int? collectionId;
  final bool favorite;
  final bool pinned;
  final bool archived;
  final String createdAt;
  final String updatedAt;

  LinkItem({
    this.id,
    required this.title,
    required this.url,
    this.description = '',
    this.tags = '',
    this.collectionId,
    this.favorite = false,
    this.pinned = false,
    this.archived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'url': url,
    'description': description,
    'tags': tags,
    'collection_id': collectionId,
    'favorite': favorite ? 1 : 0,
    'pinned': pinned ? 1 : 0,
    'archived': archived ? 1 : 0,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  factory LinkItem.fromMap(Map<String, dynamic> m) => LinkItem(
    id: m['id'] as int?,
    title: m['title'] as String,
    url: m['url'] as String,
    description: m['description'] as String,
    tags: m['tags'] as String,
    collectionId: m['collection_id'] as int?,
    favorite: (m['favorite'] as int?) == 1,
    pinned: (m['pinned'] as int?) == 1,
    archived: (m['archived'] as int?) == 1,
    createdAt: m['created_at'] as String,
    updatedAt: m['updated_at'] as String,
  );

  LinkItem copyWith({bool? archived, bool? favorite, bool? pinned, String? title, String? url, String? description, String? tags, int? collectionId, String? updatedAt}) => LinkItem(
    id: id,
    title: title ?? this.title,
    url: url ?? this.url,
    description: description ?? this.description,
    tags: tags ?? this.tags,
    collectionId: collectionId ?? this.collectionId,
    favorite: favorite ?? this.favorite,
    pinned: pinned ?? this.pinned,
    archived: archived ?? this.archived,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
    id: id,
    title: title ?? this.title,
    url: url ?? this.url,
    description: description ?? this.description,
    tags: tags ?? this.tags,
    collectionId: collectionId ?? this.collectionId,
    favorite: favorite ?? this.favorite,
    pinned: pinned ?? this.pinned,
    archived: archived ?? this.archived,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
