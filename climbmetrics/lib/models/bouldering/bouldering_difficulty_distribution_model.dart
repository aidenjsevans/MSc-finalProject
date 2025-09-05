class BoulderingDifficultyDistributionModel {

  final int v0;
  final int v1;
  final int v2;
  final int v3;
  final int v4;
  final int v5;
  final int v6;
  final int v7;
  final int v8;
  final int v9;
  final int v10;
  final int v11;
  final int v12;
  final int v13;
  final int v14;
  final int v15;
  final int v16;
  final int v17;

  BoulderingDifficultyDistributionModel({
    this.v0 = 0,
    this.v1 = 0,
    this.v2 = 0,
    this.v3 = 0,
    this.v4 = 0,
    this.v5 = 0,
    this.v6 = 0,
    this.v7 = 0,
    this.v8 = 0,
    this.v9 = 0,
    this.v10 = 0,
    this.v11 = 0,
    this.v12 = 0, 
    this.v13 = 0,
    this.v14 = 0,
    this.v15 = 0,
    this.v16 = 0,
    this.v17 = 0
  });

  Map<int,dynamic> toIntKeyMap() {
      return {
      0: v0,
      1: v1,
      2: v2,
      3: v3,
      4: v4,
      5: v5,
      6: v6,
      7: v7,
      8: v8,
      9: v9,
      10: v10,
      11: v11,
      12: v12,
      13: v13,
      14: v14,
      15: v15,
      16: v16,
      17: v17,
    }; 
  }

  Map<String,dynamic> toStringKeyMap() {
      return {
      'v0': v0,
      'v1': v1,
      'v2': v2,
      'v3': v3,
      'v4': v4,
      'v5': v5,
      'v6': v6,
      'v7': v7,
      'v8': v8,
      'v9': v9,
      'v10': v10,
      'v11': v11,
      'v12': v12,
      'v13': v13,
      'v14': v14,
      'v15': v15,
      'v16': v16,
      'v17': v17,
    }; 
  }

  factory BoulderingDifficultyDistributionModel.fromMap(Map<String,dynamic> map) {
    return BoulderingDifficultyDistributionModel(
      v0: map['v0'],
      v1: map['v1'],
      v2: map['v2'],
      v3: map['v3'],
      v4: map['v4'],
      v5: map['v5'],
      v6: map['v6'],
      v7: map['v7'],
      v8: map['v8'],
      v9: map['v9'],
      v10: map['v10'],
      v11: map['v11'],
      v12: map['v12'],
      v13: map['v13'],
      v14: map['v14'],
      v15: map['v15'],
      v16: map['v16'],
      v17: map['v17'],
    );
  }
}