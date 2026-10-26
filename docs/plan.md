# Rencana Proyek Akhir: Strike Log

Platform pencatatan strike pancingan, pembuktian keaslian tangkapan berbasis Blockchain, ensiklopedia ikan cerdas bertenaga AI, dan komunitas angler.

---

## 1. Pemetaan Kriteria Penilaian

| No | Kriteria Tugas | Implementasi di Strike Log |
|---|---|---|
| 1 | Konsep Proyek Akhir | Strike Log: Smart Fishing Journal & Proof-of-Catch |
| 2 | Login Enkripsi & Session (Non-Firebase) | Supabase Auth (JWT Session) + `flutter_secure_storage` |
| 3 | Login Biometrik | `local_auth` (Fingerprint & Face Unlock) |
| 4 | Database Lokal & Online | Supabase PostgreSQL (Online) + `hive_flutter` (Offline Sync) |
| 5 | Web Service/API & LBS | `geolocator` GPS Tagging + Reverse Geocoding + Weather API |
| 6 | Menu Bottom Nav | Profil, Saran & Kesan Kuliah PAM, Logout |
| 7 | Konversi Mata Uang & Waktu | Kurs (IDR, USD, JPY, EUR) & Waktu (WIB, WITA, WIT, London GMT) |
| 8 | Minimal 2 Sensor | Accelerometer (Strike Jolt Detector) & Compass (Arah Angin) |
| 9 | Fitur AI & LLM | Gemini Vision (Auto Scan Foto Ikan) & StrikeBot Angler Assistant |
| 10 | Mini Game | "Reel The Fish" (Mini Game Tarik Joran) |
| 11 | Pencarian & Pemilihan | Search bar & Filter chips (Spesies, Bobot, Spot, Umpan) |
| 12 | Notifikasi Mobile | `flutter_local_notifications` (Pengingat Waktu Pasang/Mancing) |
| 13 | Blockchain Sederhana | SHA-256 Proof-of-Catch (Foto + GPS + Timestamp + User ID) |

---

## 2. Rencana Tahapan Eksekusi

### Fase 1: Keamanan, Biometrik & Dual Database (Offline + Online)
- Dependensi: `local_auth`, `flutter_secure_storage`, `hive_flutter`.
- Fitur biometric toggle & quick biometric authentication di Login.
- Hive Local Database untuk offline caching dan sinkronisasi log strike.
- Tampilan UI Glassmorphism & Translucent modern.

### Fase 2: Smart Log (AI Vision Scan, LBS GPS & Blockchain Proof-of-Catch)
- Kamera otomatis jepret hasil pancingan.
- LBS GPS auto-detect lokasi dan reverse geocoding.
- AI Vision Scan mengenali foto dan mengisi form secara otomatis.
- Blockchain Proof-of-Catch stamp generator (SHA-256 block ledger).

### Fase 3: Sensor Hardware & Mini Game
- Sensor Accelerometer untuk Strike Detector (getaran sentakan joran).
- Sensor Kompas Navigasi Nelayan.
- Mini Game interaktif "Reel The Fish".

### Fase 4: Konversi (Kurs & Waktu) & Notifikasi
- Fishing tools konverter mata uang (IDR, USD, JPY, EUR).
- Konverter waktu pasang global (WIB, WITA, WIT, London).
- Notifikasi lokal pengingat sesi mancing.

### Fase 5: AI Chatbot LLM, Pencarian & Kesan Pesan PAM
- Search bar dan filter chip interaktif.
- Chatbot LLM StrikeBot.
- Menu halaman Saran dan Kesan Kuliah Pemrograman Aplikasi Mobile (PAM).
