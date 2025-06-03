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
      title: json["title"] ?? "",
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
    final newItems = items.map((e) => e.copyWith(value: "")).toList(); 
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

enum ChecklistItemType { task, note }

class ChecklistItem {
  ChecklistItem({
    required this.title,
    required this.description,
    required this.value,
    required this.type,
  });

  final String title;
  final String description;
  final String value;
  final ChecklistItemType type;

  bool get isDone => value == "1";

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      title: json["title"] ?? "",
      description: json["des"] ?? "",
      value: json["value"] ?? "0",
      type: ChecklistItemType.values.firstWhere((e) => e.name == (json["type"] ?? "task")),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "des": description,
      "value": value,
      "type": type.name,
    };
  }

  ChecklistItem copyWith({
    String? title,
    String? description,
    String? value,
    ChecklistItemType? type,
  }) {
    return ChecklistItem(
      title: title ?? this.title,
      description: description ?? this.description,
      value: value ?? this.value,
      type: type ?? this.type,
    );
  }
}
