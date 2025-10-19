// Model untuk data negara dari REST Countries API
// Perhatikan struktur JSON-nya: ada field 'name' yang berisi common, official, dan nativeName
class Country {
  final String commonName;
  final String officialName;
  final Map<String, NativeName>? nativeNames;

  Country({
    required this.commonName,
    required this.officialName,
    this.nativeNames,
  });

  // Factory constructor ini untuk parsing JSON ke object Country
  // Kalian bisa lihat struktur JSON di dokumentasi API
  factory Country.fromJson(Map<String, dynamic> json) {
    final nameData = json['name'] as Map<String, dynamic>;
    
    // Kita parse native names kalau ada, soalnya ini optional
    Map<String, NativeName>? nativeNamesMap;
    if (nameData['nativeName'] != null) {
      final nativeNameData = nameData['nativeName'] as Map<String, dynamic>;
      nativeNamesMap = nativeNameData.map(
        (key, value) => MapEntry(
          key,
          NativeName.fromJson(value as Map<String, dynamic>),
        ),
      );
    }

    return Country(
      commonName: nameData['common'] as String,
      officialName: nameData['official'] as String,
      nativeNames: nativeNamesMap,
    );
  }

  // Method untuk convert balik ke JSON (kalau nanti perlu kirim data ke API)
  Map<String, dynamic> toJson() {
    return {
      'name': {
        'common': commonName,
        'official': officialName,
        'nativeName': nativeNames?.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
      },
    };
  }
}

// Model untuk nama asli negara dalam bahasa lokal
class NativeName {
  final String official;
  final String common;

  NativeName({
    required this.official,
    required this.common,
  });

  factory NativeName.fromJson(Map<String, dynamic> json) {
    return NativeName(
      official: json['official'] as String,
      common: json['common'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'official': official,
      'common': common,
    };
  }
}
