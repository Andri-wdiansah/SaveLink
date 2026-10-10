class NoteItem {
  final int? id;
  final String title;
  final String content;
  final String tags;
  final int? collectionId;
  final bool favorite;
  final bool pinned;
  final bool archived;
  final String createdAt;
  final String updatedAt;

  NoteItem(
      {this.id,
      required this.title,
      required this.content,
      this.tags = '',
      this.collectionId,
      this.favorite = false,
      this.pinned = false,
      this.archived = false,
      required this.createdAt,
      required this.updatedAt});
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'tags': tags,
        'collection_id': collectionId,
        'favorite': favorite ? 1 : 0,
        'pinned': pinned ? 1 : 0,
        'archived': archived ? 1 : 0,
        'created_at': createdAt,
        'updated_at': updatedAt
      };
  factory NoteItem.fromMap(Map<String, dynamic> m) => NoteItem(
      id: m['id'] as int?,
      title: (m['title'] as String?) ?? '',
      content: (m['content'] as String?) ?? '',
      tags: (m['tags'] as String?) ?? '',
      collectionId: m['collection_id'] as int?,
      favorite: (m['favorite'] as int?) == 1,
      pinned: (m['pinned'] as int?) == 1,
      archived: (m['archived'] as int?) == 1,
      createdAt: (m['created_at'] as String?) ?? '',
      updatedAt: (m['updated_at'] as String?) ?? '');
  NoteItem copyWith(
          {bool? favorite,
          bool? pinned,
          bool? archived,
          String? title,
          String? content,
          String? tags,
          int? collectionId,
          String? updatedAt}) =>
      NoteItem(
          id: id,
          title: title ?? this.title,
          content: content ?? this.content,
          tags: tags ?? this.tags,
          collectionId: collectionId ?? this.collectionId,
          favorite: favorite ?? this.favorite,
          pinned: pinned ?? this.pinned,
          archived: archived ?? this.archived,
          createdAt: createdAt,
          updatedAt: updatedAt ?? this.updatedAt);
}
