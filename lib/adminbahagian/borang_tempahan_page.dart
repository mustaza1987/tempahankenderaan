import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'tempahan_model.dart';
import 'tempahan_service.dart';

class BorangTempahanPageNew extends StatefulWidget {
  final Map<String, dynamic> userData;

  const BorangTempahanPageNew({Key? key, required this.userData})
    : super(key: key);

  @override
  State<BorangTempahanPageNew> createState() => _BorangTempahanPageNewState();
}

class _BorangTempahanPageNewState extends State<BorangTempahanPageNew> {
  final _formKey = GlobalKey<FormState>();
  final TempahanService _service = TempahanService();

  bool _isLoading = true;
  bool _isSubmitting = false;
  DropdownData? _dropdownData;
  MaklumatPemohon? _maklumatPemohon;

  // Controllers
  final TextEditingController _destinasiController = TextEditingController();
  final TextEditingController _tujuanController = TextEditingController();
  final TextEditingController _tempatLaporDiriController =
      TextEditingController();
  final TextEditingController _catatanPemohonController =
      TextEditingController();
  final TextEditingController _catatanAdminController = TextEditingController();
  final TextEditingController _jumOrangController = TextEditingController();
  final TextEditingController _tarikhBertolakController =
      TextEditingController();
  final TextEditingController _masaBertolakController = TextEditingController();
  final TextEditingController _tarikhBalikController = TextEditingController();
  final TextEditingController _masaBalikController = TextEditingController();

  // Selected values
  int? _selectedPemohon;
  int? _selectedJawatan;
  int? _selectedGred;
  int? _selectedSkim;
  int? _selectedBahagian;
  int? _selectedJenisAset;
  int? _selectedStatusTempahan;
  int? _selectedPemandu;
  int? _selectedKenderaan;

  // State variables
  bool _showPemanduKenderaan = false;
  int _idBahagian = 0;
  String _namaUser = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadInitialData();
  }

  void _loadUserData() {
    // Dapatkan maklumat user dari widget.userData
    setState(() {
      _idBahagian =
          int.tryParse(widget.userData['id_bahagian']?.toString() ?? '0') ?? 0;
      _namaUser = widget.userData['nama']?.toString() ?? 'Pengguna';
    });
  }

  Future<void> _loadInitialData() async {
    try {
      print('🔄 Loading dropdown data for id_bahagian: $_idBahagian');

      if (_idBahagian == 0) {
        throw Exception('ID Bahagian tidak valid: $_idBahagian');
      }

      _dropdownData = await _service.getDropdownData(_idBahagian);

      setState(() {
        _isLoading = false;
      });

      print('✅ Dropdown data loaded successfully');
      print('   - Pemohon: ${_dropdownData!.pemohon.length} items');
      print('   - Jenis Aset: ${_dropdownData!.jenisAset.length} items');
      print(
        '   - Status Tempahan: ${_dropdownData!.statusTempahan.length} items',
      );
    } catch (e) {
      print('❌ Error loading initial data: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onPemohonChanged(int? value) async {
    if (value == null) return;

    try {
      setState(() {
        _selectedPemohon = value;
      });

      print('🔍 Loading maklumat pemohon: $value');
      _maklumatPemohon = await _service.getMaklumatPemohon(value);

      setState(() {
        _selectedJawatan = _maklumatPemohon!.idJawatan;
        _selectedGred = _maklumatPemohon!.idGred;
        _selectedSkim = _maklumatPemohon!.idSkim;
        _selectedBahagian = _maklumatPemohon!.idBahagian;
      });

      print('✅ Maklumat pemohon loaded:');
      print('   - Nama: ${_maklumatPemohon!.nama}');
      print('   - Jawatan: ${_maklumatPemohon!.namaJawatan}');
      print('   - Bahagian: ${_maklumatPemohon!.namaBahagian}');
    } catch (e) {
      print('❌ Error loading pemohon data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat maklumat pemohon: $e')),
      );
    }
  }

  void _onStatusTempahanChanged(int? value) {
    setState(() {
      _selectedStatusTempahan = value;
      _showPemanduKenderaan =
          value == 2; // Tunjukkan pemandu & kenderaan jika status = 2 (Lulus)
    });

    print('🔄 Status tempahan changed: $value');
    print('   - Show pemandu & kenderaan: $_showPemanduKenderaan');
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sila isi semua ruangan yang diperlukan')),
      );
      return;
    }

    if (_maklumatPemohon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sila pilih pemohon terlebih dahulu')),
      );
      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      final request = TempahanRequest(
        namaPemohon: _maklumatPemohon!.nama,
        idJawatan: _selectedJawatan!,
        idGred: _selectedGred!,
        idSkim: _selectedSkim!,
        idBahagian: _selectedBahagian!,
        noTelefonPejabat: _maklumatPemohon!.noTelefonPejabat,
        emel: _maklumatPemohon!.emel,
        tarikhBertolak: _tarikhBertolakController.text,
        masaBertolak: _masaBertolakController.text,
        tarikhBalik: _tarikhBalikController.text,
        masaBalik: _masaBalikController.text,
        destinasi: _destinasiController.text,
        tujuan: _tujuanController.text,
        jumOrang: _jumOrangController.text,
        tempatLaporDiri: _tempatLaporDiriController.text,
        idJenisAset: _selectedJenisAset!,
        idPemandu: _selectedPemandu ?? 0,
        idKenderaan: _selectedKenderaan ?? 0,
        idStatusTempahan: _selectedStatusTempahan!,
        idPemohon: _selectedPemohon!,
        idPengguna:
            int.tryParse(widget.userData['id_pengguna']?.toString() ?? '0') ??
            0,
        catatanPemohon: _catatanPemohonController.text,
        catatanAdmin: _catatanAdminController.text,
        catatanAdminbkp: '',
        catatanPemandu: '',
        idPermohonanKhas: 1,
        idStatus: 1,
      );

      print('📤 Submitting tempahan request...');
      final response = await _service.simpanTempahan(request);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));

      if (response.success) {
        print('✅ Tempahan berjaya disimpan. ID: ${response.idTempahan}');
        _resetForm();
      } else {
        print('❌ Tempahan gagal disimpan: ${response.message}');
      }
    } catch (e) {
      print('❌ Error submitting form: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan tempahan: $e')));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _destinasiController.clear();
    _tujuanController.clear();
    _tempatLaporDiriController.clear();
    _catatanPemohonController.clear();
    _catatanAdminController.clear();
    _jumOrangController.clear();
    _tarikhBertolakController.clear();
    _masaBertolakController.clear();
    _tarikhBalikController.clear();
    _masaBalikController.clear();

    setState(() {
      _selectedPemohon = null;
      _selectedJawatan = null;
      _selectedGred = null;
      _selectedSkim = null;
      _selectedBahagian = null;
      _selectedJenisAset = null;
      _selectedStatusTempahan = null;
      _selectedPemandu = null;
      _selectedKenderaan = null;
      _showPemanduKenderaan = false;
      _maklumatPemohon = null;
    });

    print('🔄 Form telah direset');
  }

  Widget _buildDropdown({
    required String label,
    required List<DropdownItem> items,
    required int? value,
    required Function(int?) onChanged,
    bool isRequired = false,
    bool isDisabled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ${isRequired ? '*' : ''}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isRequired ? Colors.red : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<int>(
            value: value,
            items: [
              DropdownMenuItem<int>(
                value: null,
                child: Text('Sila Pilih', style: TextStyle(color: Colors.grey)),
              ),
              ...items.map((item) {
                return DropdownMenuItem<int>(
                  value: item.id,
                  child: Text(item.toString()),
                );
              }).toList(),
            ],
            onChanged: isDisabled ? null : onChanged,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              filled: isDisabled,
              fillColor: isDisabled ? Colors.grey[200] : null,
            ),
            validator: isRequired
                ? (value) => value == null ? 'Sila pilih $label' : null
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool isRequired = false,
    bool isReadOnly = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ${isRequired ? '*' : ''}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isRequired ? Colors.red : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: isReadOnly,
            onTap: onTap,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: hintText,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            validator: isRequired
                ? (value) =>
                      value == null || value.isEmpty ? 'Sila isi $label' : null
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text =
          "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BORANG TEMPAHAN KENDERAAN JABATAN'),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data...'),
                  SizedBox(height: 8),
                  Text('ID Bahagian: Loading...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Maklumat User
                    const SizedBox(height: 16),

                    // Warning message untuk bukan BKP
                    if (_idBahagian != 1) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Jika anda membuat tempahan kenderaan BKP, sila pastikan tempahan dibuat sebelum jam 4.00 petang sehari sebelum tarikh bertolak.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFF3db2e1),
                      child: const Text(
                        'BORANG TEMPAHAN KENDERAAN JABATAN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_dropdownData != null) ...[
                      // Pemohon
                      _buildDropdown(
                        label: 'Nama Pengguna',
                        items: _dropdownData!.pemohon,
                        value: _selectedPemohon,
                        onChanged: _onPemohonChanged,
                        isRequired: true,
                      ),

                      // Maklumat Pemohon (auto-filled)
                      if (_maklumatPemohon != null) ...[
                        _buildDropdown(
                          label: 'Jawatan',
                          items: _dropdownData!.jawatan,
                          value: _selectedJawatan,
                          onChanged: (value) =>
                              setState(() => _selectedJawatan = value),
                          isRequired: true,
                          isDisabled: true,
                        ),

                        _buildDropdown(
                          label: 'Gred',
                          items: _dropdownData!.gred,
                          value: _selectedGred,
                          onChanged: (value) =>
                              setState(() => _selectedGred = value),
                          isRequired: true,
                          isDisabled: true,
                        ),

                        _buildDropdown(
                          label: 'Skim Jawatan',
                          items: _dropdownData!.skim,
                          value: _selectedSkim,
                          onChanged: (value) =>
                              setState(() => _selectedSkim = value),
                          isRequired: true,
                          isDisabled: true,
                        ),

                        _buildDropdown(
                          label: 'Bahagian',
                          items: _dropdownData!.bahagian,
                          value: _selectedBahagian,
                          onChanged: (value) =>
                              setState(() => _selectedBahagian = value),
                          isRequired: true,
                          isDisabled: true,
                        ),

                        _buildTextField(
                          label: 'No. Telefon Pejabat',
                          controller: TextEditingController(
                            text: _maklumatPemohon!.noTelefonPejabat,
                          ),
                          hintText: 'No. telefon pejabat',
                          isRequired: true,
                          isReadOnly: true,
                        ),

                        _buildTextField(
                          label: 'Emel',
                          controller: TextEditingController(
                            text: _maklumatPemohon!.emel,
                          ),
                          hintText: 'Emel pemohon',
                          isRequired: true,
                          isReadOnly: true,
                        ),
                      ],

                      // Tarikh & Masa
                      _buildTextField(
                        label: 'Tarikh Bertolak',
                        controller: _tarikhBertolakController,
                        hintText: 'Sila klik untuk pilih tarikh',
                        isRequired: true,
                        isReadOnly: true,
                        onTap: () =>
                            _selectDate(context, _tarikhBertolakController),
                      ),

                      _buildTextField(
                        label: 'Masa Bertolak',
                        controller: _masaBertolakController,
                        hintText: 'Sila masukkan masa bertolak. Contoh: 08:00',
                        isRequired: true,
                        isReadOnly: true,
                        onTap: () =>
                            _selectTime(context, _masaBertolakController),
                      ),

                      _buildTextField(
                        label: 'Tarikh Balik',
                        controller: _tarikhBalikController,
                        hintText: 'Sila klik untuk pilih tarikh',
                        isRequired: true,
                        isReadOnly: true,
                        onTap: () =>
                            _selectDate(context, _tarikhBalikController),
                      ),

                      _buildTextField(
                        label: 'Masa Balik',
                        controller: _masaBalikController,
                        hintText: 'Sila masukkan masa balik. Contoh: 17:00',
                        isRequired: true,
                        isReadOnly: true,
                        onTap: () => _selectTime(context, _masaBalikController),
                      ),

                      _buildTextField(
                        label: 'Bilangan Penumpang',
                        controller: _jumOrangController,
                        hintText: 'Sila masukkan bilangan penumpang',
                        isRequired: true,
                       
                      ),

                      _buildDropdown(
                        label: 'Jenis Kenderaan',
                        items: _dropdownData!.jenisAset,
                        value: _selectedJenisAset,
                        onChanged: (value) =>
                            setState(() => _selectedJenisAset = value),
                        isRequired: true,
                      ),

                      _buildTextField(
                        label: 'Destinasi',
                        controller: _destinasiController,
                        hintText: 'Sila masukkan destinasi',
                        isRequired: true,
                      ),

                      _buildTextField(
                        label: 'Tujuan',
                        controller: _tujuanController,
                        hintText: 'Sila masukkan tujuan',
                        isRequired: true,
                      ),

                      _buildTextField(
                        label: 'Tempat Lapor Diri',
                        controller: _tempatLaporDiriController,
                        hintText: 'Sila masukkan tempat lapor diri',
                        isRequired: true,
                      ),

                      _buildTextField(
                        label: 'Catatan',
                        controller: _catatanPemohonController,
                        hintText: 'Catatan pemohon',
                        isRequired: false,
                      ),

                      // Section Kelulusan
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: const Color(0xFF3db2e1),
                        child: const Text(
                          'KELULUSAN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildDropdown(
                        label: 'Status Permohonan',
                        items: _dropdownData!.statusTempahan,
                        value: _selectedStatusTempahan,
                        onChanged: _onStatusTempahanChanged,
                        isRequired: true,
                      ),

                      // Pemandu & Kenderaan (jika status = Lulus)
                      if (_showPemanduKenderaan) ...[
                        _buildDropdown(
                          label: 'Nama Pemandu',
                          items: _dropdownData!.pemandu,
                          value: _selectedPemandu,
                          onChanged: (value) =>
                              setState(() => _selectedPemandu = value),
                          isRequired: true,
                        ),

                        _buildDropdown(
                          label: 'No. Kenderaan',
                          items: _dropdownData!.kenderaan,
                          value: _selectedKenderaan,
                          onChanged: (value) =>
                              setState(() => _selectedKenderaan = value),
                          isRequired: true,
                        ),
                      ],

                      // Catatan Admin
                      _buildTextField(
                        label: 'Catatan',
                        controller: _catatanAdminController,
                        hintText: 'Catatan admin',
                        isRequired: false,
                      ),

                      // Info text
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: const Text(
                          'Perhatian : Sila pastikan ruangan bertanda * diisi.',
                          style: TextStyle(
                            color: Colors.red,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                      // Buttons
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Simpan',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton(
                            onPressed: _isSubmitting ? null : _resetForm,
                            child: const Text('Batal'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
