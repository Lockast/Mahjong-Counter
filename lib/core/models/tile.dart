import 'wind.dart';

enum TileFamily {
  bambou,
  caracteres,
  sapek,
  vent,
  dragon,
  fleur,
  saison;

  bool get isHonneur => this == vent || this == dragon;
  bool get isBonus => this == fleur || this == saison;
  bool get isNumbered => this == bambou || this == caracteres || this == sapek;
}

class Tile {
  final String id;
  final String label;
  final String assetFile;
  final TileFamily family;
  final int?
      number; // 1–9 for suites ; 1–4 for fleurs/saisons ; null for dragons
  final Wind? wind; // only for vent tiles

  const Tile({
    required this.id,
    required this.label,
    required this.assetFile,
    required this.family,
    this.number,
    this.wind,
  });

  bool get isMajeur => family.isNumbered && (number == 1 || number == 9);
  bool get isMineur =>
      family.isNumbered && number != null && number! >= 2 && number! <= 8;

  String get assetPath => 'assets/tiles/$assetFile';

  @override
  bool operator ==(Object other) => other is Tile && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => label;
}

class TileInstance {
  final Tile tile;
  final bool exposed; // true = exposé, false = caché

  const TileInstance({required this.tile, required this.exposed});

  TileInstance copyWith({bool? exposed}) =>
      TileInstance(tile: tile, exposed: exposed ?? this.exposed);
}

// ---------------------------------------------------------------------------
// Static tile catalog (loaded once from tile_catalog.json at runtime).
// This class also provides convenient tile lookup by id.
// ---------------------------------------------------------------------------

class TileCatalog {
  TileCatalog._();

  static final Map<String, Tile> _byId = {};
  static List<Tile> _all = [];

  static List<Tile> get all => List.unmodifiable(_all);

  static Tile? byId(String id) => _byId[id];

  /// Call once after loading tile_catalog.json.
  static void init(Map<String, dynamic> json) {
    _byId.clear();
    _all = [];

    void add(Tile t) {
      _byId[t.id] = t;
      _all.add(t);
    }

    for (final suit in (json['suits'] as List)) {
      final familyId = suit['id'] as String;
      final family = switch (familyId) {
        'bambou' => TileFamily.bambou,
        'caracteres' => TileFamily.caracteres,
        'sapek' => TileFamily.sapek,
        _ => TileFamily.bambou,
      };
      for (final t in (suit['tiles'] as List)) {
        add(Tile(
          id: t['id'] as String,
          label: t['label'] as String,
          assetFile: t['file'] as String,
          family: family,
          number: t['number'] as int?,
        ));
      }
    }

    final honours = json['honours'] as Map<String, dynamic>;

    for (final t in (honours['winds'] as List)) {
      add(Tile(
        id: t['id'] as String,
        label: t['label'] as String,
        assetFile: t['file'] as String,
        family: TileFamily.vent,
        wind: Wind.fromString(t['wind'] as String),
      ));
    }

    for (final t in (honours['dragons'] as List)) {
      add(Tile(
        id: t['id'] as String,
        label: t['label'] as String,
        assetFile: t['file'] as String,
        family: TileFamily.dragon,
      ));
    }

    final bonus = json['bonus'] as Map<String, dynamic>;

    for (final t in (bonus['flowers'] as List)) {
      add(Tile(
        id: t['id'] as String,
        label: t['label'] as String,
        assetFile: t['file'] as String,
        family: TileFamily.fleur,
        number: t['number'] as int?,
      ));
    }

    for (final t in (bonus['seasons'] as List)) {
      add(Tile(
        id: t['id'] as String,
        label: t['label'] as String,
        assetFile: t['file'] as String,
        family: TileFamily.saison,
        number: t['number'] as int?,
      ));
    }
  }
}
