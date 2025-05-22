class RiwayatItem {
  final String Nama_Aset;
  final String Serial_Number;
  final String Lokasi_Peminjaman;
  final String Tanggal_Peminjaman;
  final String? Lokasi_Pengembalian;
  final String? Tanggal_Pengembalian;
  final String? dokumentasi_barang;

  final String Status;
  

  RiwayatItem({
    required this.Nama_Aset,
    required this.Serial_Number,
    required this.Lokasi_Peminjaman,
    required this.Tanggal_Peminjaman,
    this.Lokasi_Pengembalian,
    this.Tanggal_Pengembalian,
    required this.Status,
    this.dokumentasi_barang,
  });

  factory RiwayatItem.fromJson(Map<String, dynamic> json) {
    return RiwayatItem(
      Nama_Aset: json['Nama_Aset'] ?? '',
      Serial_Number: json['Serial_Number'] ?? '',
      Lokasi_Peminjaman: json['Lokasi_Peminjaman'] ?? '',
      Tanggal_Peminjaman: json['Tanggal_Peminjaman'] ?? '',
      Lokasi_Pengembalian: json['Lokasi_Pengembalian'],
      Tanggal_Pengembalian: json['Tanggal_Pengembalian'],
      Status: json['Status'] ?? '',
      dokumentasi_barang: json['dokumentasi_barang'],

    );
  }
}
