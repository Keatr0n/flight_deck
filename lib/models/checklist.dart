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

enum ChecklistItemType { task, note, calculated }

class ChecklistItem {
  ChecklistItem({
    required this.title,
    required this.description,
    required this.value,
    required this.type,
    required this.operation,
  });

  final String title;
  final String description;
  final String value;
  final ChecklistItemType type;
  final ChecklistItemOperation? operation;

  bool get isDone => value == "1";

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      title: json["title"] ?? "",
      description: json["des"] ?? "",
      value: json["value"] ?? "0",
      type: ChecklistItemType.values.firstWhere((e) => e.name == (json["type"] ?? "task")),
      operation: json["operation"] == null ? null : ChecklistItemOperation.fromJson(json["operation"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "des": description,
      "value": value,
      "type": type.name,
      "operation": operation?.toJson(),
    };
  }

  ChecklistItem copyWith({
    String? title,
    String? description,
    String? value,
    ChecklistItemType? type,
    ChecklistItemOperation? operation,
  }) {
    return ChecklistItem(
      title: title ?? this.title,
      description: description ?? this.description,
      value: value ?? this.value,
      type: type ?? this.type,
      operation: operation ?? this.operation,
    );
  }
}

enum ChecklistItemOperationType {
  add,
  subtract,
  multiply,
  divide,
  equal,
  notEqual,
  greaterThan,
  lessThan,
  greaterThanOrEqual,
  lessThanOrEqual
}

class ChecklistItemOperation {
  ChecklistItemOperation(this.indexes, this.type);

  final List<int> indexes;
  final ChecklistItemOperationType type;

  factory ChecklistItemOperation.fromJson(Map<String, dynamic> json) {
    return ChecklistItemOperation(
      List<int>.from(json["indexes"]),
      ChecklistItemOperationType.values.firstWhere((e) => e.name == (json["type"] ?? "add")),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "indexes": indexes,
      "type": type.name,
    };
  }

  ChecklistItemOperation copyWith({
    List<int>? indexes,
    ChecklistItemOperationType? type,
  }) {
    return ChecklistItemOperation(
      indexes ?? this.indexes,
      type ?? this.type,
    );
  }

  dynamic _tryParseValue(String value) {
    dynamic output;

    if (value.contains(".")) {
      output = double.tryParse(value);
    } else {
      output = int.tryParse(value);
    }

    if (output == null) {
      return value;
    }
    return output;
  }

  String runCalculation(Checklist checklist) {
    final itemsToOperateOn = indexes.map((e) => checklist.items[e].value).toList();

    switch (type) {
      case ChecklistItemOperationType.add:
        return itemsToOperateOn.reduce((value, element) {
          var v1 = _tryParseValue(value);
          var v2 = _tryParseValue(element);
          if (v1 is String && (v2 is int || v2 is double)) return v1 + v2.toString();
          if ((v1 is int || v1 is double) && v2 is String) return v1.toString() + v2;

          return (v1 + v2).toString();
        }).toString();
      case ChecklistItemOperationType.subtract:
        return itemsToOperateOn.reduce((value, element) {
          var v1 = _tryParseValue(value);
          var v2 = _tryParseValue(element);
          if (v1 is String && v2 is String) return v1.replaceAll(v2, '');
          if (v1 is String && (v2 is int || v2 is double)) {
            return v1.replaceRange(0, v1.length > v2.toInt() ? v2.toInt() : v1.length, '');
          }

          if (v2 is String) v2 = v2.length;

          return (v1 - v2) is double ? ((((v1 - v2) * 10000).round()) / 10000).toString() : (v1 - v2).toString();
        }).toString();
      case ChecklistItemOperationType.multiply:
        return itemsToOperateOn.reduce((value, element) {
          var v1 = _tryParseValue(value);
          var v2 = _tryParseValue(element);
          if (v1 is String && (v2 is int || v2 is double)) return (v1 * v2.toInt()).toString();
          if (v2 is String) v2 = v2.length;

          return (v1 * v2).toString();
        }).toString();
      case ChecklistItemOperationType.divide:
        return itemsToOperateOn.reduce((value, element) {
          var v1 = _tryParseValue(value);
          var v2 = _tryParseValue(element);
          if (v1 is String && (v2 is int || v2 is double)) return v1.replaceRange(0, (v1.length / v2).toInt(), '');
          if (v2 is String) v2 = v2.length;

          return (v1 / v2).toString();
        }).toString();
      case ChecklistItemOperationType.equal:
        return itemsToOperateOn.every((element) => element == itemsToOperateOn.first).toString();
      case ChecklistItemOperationType.notEqual:
        return itemsToOperateOn.any((element) => element != itemsToOperateOn.first).toString();
      case ChecklistItemOperationType.greaterThan:
        return itemsToOperateOn.reduce((value, element) {
          var v1 = _tryParseValue(value);
          var v2 = _tryParseValue(element);
          if (v1 is String) v1 = v1.length;
          if (v2 is String) v2 = v2.length;

          return v1 > v2 ? "true" : "false";
        }).toString();
      case ChecklistItemOperationType.lessThan:
        return itemsToOperateOn.reduce((value, element) {
          var v1 = _tryParseValue(value);
          var v2 = _tryParseValue(element);
          if (v1 is String) v1 = v1.length;
          if (v2 is String) v2 = v2.length;

          return v1 < v2 ? "true" : "false";
        }).toString();
      case ChecklistItemOperationType.greaterThanOrEqual:
        return itemsToOperateOn.reduce((value, element) {
          var v1 = _tryParseValue(value);
          var v2 = _tryParseValue(element);
          if (v1 is String) v1 = v1.length;
          if (v2 is String) v2 = v2.length;

          return v1 >= v2 ? "true" : "false";
        }).toString();
      case ChecklistItemOperationType.lessThanOrEqual:
        return itemsToOperateOn.reduce((value, element) {
          var v1 = _tryParseValue(value);
          var v2 = _tryParseValue(element);
          if (v1 is String) v1 = v1.length;
          if (v2 is String) v2 = v2.length;

          return v1 <= v2 ? "true" : "false";
        }).toString();
    }
  }
}
