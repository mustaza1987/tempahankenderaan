class DropdownData {
  final List<DropdownItem> pemohon;
  final List<DropdownItem> jawatan;
  final List<DropdownItem> gred;
  final List<DropdownItem> skim;
  final List<DropdownItem> bahagian;
  final List<DropdownItem> jenisAset;
  final List<DropdownItem> statusTempahan;
  final List<DropdownItem> pemandu;
  final List<DropdownItem> kenderaan;
  final int idBahagian;

  DropdownData({
    required this.pemohon,
    required this.jawatan,
    required this.gred,
    required this.skim,
    required this.bahagian,
    required this.jenisAset,
    required this.statusTempahan,
    required this.pemandu,
    required this.kenderaan,
    required this.idBahagian,
  });

  factory DropdownData.fromJson(Map<String, dynamic> json) {
    return DropdownData(
      pemohon: _parseDropdownList(json['pemohon']),
      jawatan: _parseDropdownList(json['jawatan']),
      gred: _parseDropdownList(json['gred']),
      skim: _parseDropdownList(json['skim']),
      bahagian: _parseDropdownList(json['bahagian']),
      jenisAset: _parseDropdownList(json['jenis_aset']),
      statusTempahan: _parseDropdownList(json['status_tempahan']),
      pemandu: _parseDropdownList(json['pemandu']),
      kenderaan: _parseDropdownList(json['kenderaan']),
      idBahagian: _parseInt(json['id_bahagian']),
    );
  }

  static List<DropdownItem> _parseDropdownList(dynamic data) {
    if (data is List) {
      return data.map((item) => DropdownItem.fromJson(item)).toList();
    }
    return [];
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class DropdownItem {
  final int id;
  final String name;
  final String? additionalInfo;

  DropdownItem({required this.id, required this.name, this.additionalInfo});

  factory DropdownItem.fromJson(Map<String, dynamic> json) {
    // Handle different field names and types
    String name =
        json['nama_pemohon'] ??
        json['jawatan'] ??
        json['gred'] ??
        json['skim'] ??
        json['bahagian'] ??
        json['jenis_aset'] ??
        json['status_tempahan'] ??
        json['nama_pemandu'] ??
        json['nama'] ??
        'Unknown';

    // Handle ID conversion from different field names and types
    int id = _parseIdFromJson(json);

    // Untuk kenderaan, gabungkan jenis aset dan no siri
    String? additionalInfo;
    if (json['no_siri_pendaftaran'] != null) {
      additionalInfo = '${json['jenis_aset']} : ${json['no_siri_pendaftaran']}';
    } else if (json['additionalInfo'] != null) {
      additionalInfo = json['additionalInfo'].toString();
    }

    return DropdownItem(id: id, name: name, additionalInfo: additionalInfo);
  }

  static int _parseIdFromJson(Map<String, dynamic> json) {
    // Try different field names
    dynamic idValue =
        json['id_pemohon'] ??
        json['id_jawatan'] ??
        json['id_gred'] ??
        json['id_skim'] ??
        json['id_bahagian'] ??
        json['id_jenis_aset'] ??
        json['id_status_tempahan'] ??
        json['id_pemandu'] ??
        json['id_kenderaan'] ??
        json['id'] ??
        0;

    // Convert to int
    if (idValue is int) return idValue;
    if (idValue is String) return int.tryParse(idValue) ?? 0;
    if (idValue is double) return idValue.toInt();

    return 0;
  }

  @override
  String toString() {
    return additionalInfo ?? name;
  }
}

class MaklumatPemohon {
  final String nama;
  final int idJawatan;
  final int idGred;
  final int idSkim;
  final int idBahagian;
  final String noTelefonPejabat;
  final String emel;
  final String namaJawatan;
  final String namaGred;
  final String namaSkim;
  final String namaBahagian;

  MaklumatPemohon({
    required this.nama,
    required this.idJawatan,
    required this.idGred,
    required this.idSkim,
    required this.idBahagian,
    required this.noTelefonPejabat,
    required this.emel,
    required this.namaJawatan,
    required this.namaGred,
    required this.namaSkim,
    required this.namaBahagian,
  });

  factory MaklumatPemohon.fromJson(Map<String, dynamic> json) {
    return MaklumatPemohon(
      nama: json['nama']?.toString() ?? '',
      idJawatan: _safeParseInt(json['id_jawatan']),
      idGred: _safeParseInt(json['id_gred']),
      idSkim: _safeParseInt(json['id_skim']),
      idBahagian: _safeParseInt(json['id_bahagian']),
      noTelefonPejabat: json['no_telefon_pejabat']?.toString() ?? '',
      emel: json['emel']?.toString() ?? '',
      namaJawatan: json['nama_jawatan']?.toString() ?? '',
      namaGred: json['nama_gred']?.toString() ?? '',
      namaSkim: json['nama_skim']?.toString() ?? '',
      namaBahagian: json['nama_bahagian']?.toString() ?? '',
    );
  }

  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }
}

class TempahanRequest {
  String namaPemohon;
  int idJawatan;
  int idGred;
  int idSkim;
  int idBahagian;
  String noTelefonPejabat;
  String emel;
  String tarikhBertolak;
  String masaBertolak;
  String tarikhBalik;
  String masaBalik;
  String destinasi;
  String tujuan;
  String jumOrang;
  String tempatLaporDiri;
  int idJenisAset;
  int idPemandu;
  int idKenderaan;
  int idStatusTempahan;
  int idPemohon;
  int idPengguna;
  String catatanPemohon;
  String catatanAdmin;
  String catatanAdminbkp;
  String catatanPemandu;
  int idPermohonanKhas;
  int idStatus;

  TempahanRequest({
    required this.namaPemohon,
    required this.idJawatan,
    required this.idGred,
    required this.idSkim,
    required this.idBahagian,
    required this.noTelefonPejabat,
    required this.emel,
    required this.tarikhBertolak,
    required this.masaBertolak,
    required this.tarikhBalik,
    required this.masaBalik,
    required this.destinasi,
    required this.tujuan,
    required this.jumOrang,
    required this.tempatLaporDiri,
    required this.idJenisAset,
    required this.idPemandu,
    required this.idKenderaan,
    required this.idStatusTempahan,
    required this.idPemohon,
    required this.idPengguna,
    required this.catatanPemohon,
    required this.catatanAdmin,
    required this.catatanAdminbkp,
    required this.catatanPemandu,
    required this.idPermohonanKhas,
    required this.idStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'action': 'simpan_tempahan',
      'nama_pemohon': namaPemohon,
      'id_jawatan': idJawatan,
      'id_gred': idGred,
      'id_skim': idSkim,
      'id_bahagian': idBahagian,
      'no_telefon_pejabat': noTelefonPejabat,
      'emel': emel,
      'tarikh_bertolak': tarikhBertolak,
      'masa_bertolak': masaBertolak,
      'tarikh_balik': tarikhBalik,
      'masa_balik': masaBalik,
      'destinasi': destinasi,
      'tujuan': tujuan,
      'jum_orang': jumOrang,
      'tempat_lapor_diri': tempatLaporDiri,
      'id_jenis_aset': idJenisAset,
      'id_pemandu': idPemandu,
      'id_kenderaan': idKenderaan,
      'id_status_tempahan': idStatusTempahan,
      'id_pemohon': idPemohon,
      'id_pengguna': idPengguna,
      'catatan_pemohon': catatanPemohon,
      'catatan_admin': catatanAdmin,
      'catatan_adminbkp': catatanAdminbkp,
      'catatan_pemandu': catatanPemandu,
      'id_permohonan_khas': idPermohonanKhas,
      'id_status': idStatus,
    };
  }
}

class ApiResponse {
  final bool success;
  final String message;
  final int? idTempahan;

  ApiResponse({required this.success, required this.message, this.idTempahan});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['status'] == 'success',
      message: json['message']?.toString() ?? 'Unknown error',
      idTempahan: _safeParseInt(json['id_tempahan']),
    );
  }

  static int? _safeParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }
}
