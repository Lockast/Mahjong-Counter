enum Wind {
  est,
  sud,
  ouest,
  nord;

  String get label => switch (this) {
        Wind.est => 'Est',
        Wind.sud => 'Sud',
        Wind.ouest => 'Ouest',
        Wind.nord => 'Nord',
      };

  String get symbol => switch (this) {
        Wind.est => '東',
        Wind.sud => '南',
        Wind.ouest => '西',
        Wind.nord => '北',
      };

  /// 1=Est, 2=Sud, 3=Ouest, 4=Nord — matches flower/season numbering.
  int get number => switch (this) {
        Wind.est => 1,
        Wind.sud => 2,
        Wind.ouest => 3,
        Wind.nord => 4,
      };

  /// After each turn: Est→Nord, Sud→Est, Ouest→Sud, Nord→Ouest.
  Wind get next => switch (this) {
        Wind.est => Wind.nord,
        Wind.sud => Wind.est,
        Wind.ouest => Wind.sud,
        Wind.nord => Wind.ouest,
      };

  static Wind fromNumber(int n) => switch (n) {
        1 => Wind.est,
        2 => Wind.sud,
        3 => Wind.ouest,
        4 => Wind.nord,
        _ => throw ArgumentError('Invalid wind number: $n'),
      };

  static Wind? fromString(String? s) => switch (s) {
        'est' => Wind.est,
        'sud' => Wind.sud,
        'ouest' => Wind.ouest,
        'nord' => Wind.nord,
        _ => null,
      };
}
