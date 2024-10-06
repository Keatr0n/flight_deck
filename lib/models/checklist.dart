class Checklist {
  Checklist({
    required this.title,
    required this.items,
    required this.tags,
  });

  final String title;
  final List<ChecklistItem> items;
  final List<String> tags;

  factory Checklist.fromJson(Map<String, dynamic> json) {
    return Checklist(
      title: json["title"],
      items: List.from(json["items"]).map<ChecklistItem>((e) => ChecklistItem.fromJson(e)).toList(),
      tags: List<String>.from(json["tags"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "items": items.map((e) => e.toJson()).toList(),
      "tags": tags,
    };
  }

  Checklist asReset() {
    final newItems = items.map((e) => e.copyWith(isDone: false)).toList();
    return Checklist(title: title, items: newItems, tags: tags);
  }

  Checklist copyWith({
    String? title,
    List<ChecklistItem>? items,
    List<String>? tags,
  }) {
    return Checklist(
      title: title ?? this.title,
      items: items ?? this.items,
      tags: tags ?? this.tags,
    );
  }
}

class ChecklistItem {
  ChecklistItem({
    required this.title,
    required this.description,
    required this.isDone,
  });

  final String title;
  final String description;
  final bool isDone;

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      title: json["title"],
      description: json["des"],
      isDone: json["done"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "des": description,
      "done": isDone,
    };
  }

  ChecklistItem copyWith({
    String? title,
    String? description,
    bool? isDone,
  }) {
    return ChecklistItem(
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
    );
  }
}
