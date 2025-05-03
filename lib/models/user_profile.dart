class UserProfile {
  final String nama;
  final String nip;
  final String jabatan;
  final String unit;
  final String telp;
  final String email;
  final String atasan;
  final String nipAtasan;
  final String unitAtasan;

  UserProfile({
    required this.nama,
    required this.nip,
    required this.jabatan,
    required this.unit,
    required this.telp,
    required this.email,
    required this.atasan,
    required this.nipAtasan,
    required this.unitAtasan,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nama: json['nama'],
      nip: json['nip'],
      jabatan: json['jabatan'],
      unit: json['unit'],
      telp: json['telp'],
      email: json['email'],
      atasan: json['atasan'],
      nipAtasan: json['nip_atasan'],
      unitAtasan: json['unit_atasan'],
    );
  }
}
