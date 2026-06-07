/// Domain model for an external link attached to a goal (marketplace/product
/// URL with an optional short title).
class GoalLink {
  const GoalLink({
    required this.id,
    required this.goalId,
    required this.url,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.title,
    this.deletedAt,
  });

  final String id;
  final String goalId;
  final String url;
  final String? title;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  GoalLink copyWith({
    String? id,
    String? goalId,
    String? url,
    String? title,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return GoalLink(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      url: url ?? this.url,
      title: title ?? this.title,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
