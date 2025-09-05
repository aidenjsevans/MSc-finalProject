import 'dart:convert';

class BoulderingStylesModel {

  bool isCrimpy;
  bool isSlabby;
  bool isOverhung;
  bool isCompression;
  bool isDyno;
  bool isTechy;
  bool isMantle;

  BoulderingStylesModel({
    this.isCrimpy = false,
    this.isSlabby = false,
    this.isOverhung = false,
    this.isCompression = false,
    this.isDyno = false,
    this.isTechy = false,
    this.isMantle = false
  });

  Map<String,dynamic> toMap() {
    return {
      'is_crimpy': isCrimpy,
      'is_slabby': isSlabby,
      'is_overhung': isOverhung,
      'is_compression': isCompression,
      'is_dyno': isDyno,
      'is_techy': isTechy,
      'is_mantle': isMantle
    };
  }

  factory BoulderingStylesModel.fromMap(Map<String,dynamic> map) {
    final bool isCrimpy = map['is_crimpy'];
    final bool isSlabby = map['is_slabby'];
    final bool isOverhung = map['is_overhung'];
    final bool isCompression = map['is_compression'];
    final bool isDyno = map['is_dyno'];
    final bool isTechy = map['is_techy'];
    final bool isMantle = map['is_mantle'];
    return BoulderingStylesModel(
      isCrimpy: isCrimpy,
      isSlabby: isSlabby,
      isOverhung: isOverhung,
      isCompression: isCompression,
      isDyno: isDyno,
      isTechy: isTechy,
      isMantle: isMantle
    );
  }

  @override
  String toString() {
    return toMap().toString();
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}