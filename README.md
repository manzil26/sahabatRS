# SahabatRS 🏥👴👵

**Solusi Pendampingan Medis & Layanan Kesehatan Digital untuk Lansia**

SahabatRS adalah aplikasi *mobile* berbasis Flutter yang dirancang untuk membantu lansia mengakses fasilitas kesehatan dengan lebih mudah, aman, dan nyaman. Aplikasi ini menghubungkan pasien dengan pendamping terlatih untuk menemani proses berobat, mulai dari penjemputan, administrasi, hingga pengantaran kembali ke rumah.

Project ini dikembangkan sebagai **Final Project Mata Kuliah Teknologi Berkembang - Kelas B (Kelompok 6)** di Institut Teknologi Sepuluh Nopember (ITS).

---

## 📱 Fitur Utama

Aplikasi ini memiliki berbagai fitur yang disesuaikan dengan kebutuhan lansia dan keluarganya:

* **Pesan Pendamping (Booking):** Memesan jasa pendamping medis untuk rawat jalan dengan pilihan moda transportasi (motor/mobil).
* **Live Tracking:** Keluarga dapat memantau lokasi pasien dan pendamping secara *real-time* demi keamanan dan transparansi.
* **Reminder Jadwal Obat:** Pengingat otomatis untuk minum obat agar pasien disiplin dalam pengobatan (Medication Adherence).
* **Chat:** Komunikasi langsung antara pengguna/keluarga dengan pendamping (driver) di dalam aplikasi.
* **Tombol Darurat (Emergency):** Akses cepat untuk kondisi medis mendesak yang langsung terhubung ke layanan respons.
* **Pembayaran Digital:** Kemudahan transaksi *cashless* (e-wallet, transfer bank) untuk mengurangi penggunaan uang tunai.
* **Manajemen Profil:** Menyimpan data kesehatan penting (kondisi medis, asuransi, kontak darurat).

---

## 🛠️ Tech Stack

Project ini dibangun menggunakan teknologi modern berikut:

### Frontend
* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **SDK Version:** `^3.9.2`

### Backend (BaaS)
* **Platform:** [Supabase](https://supabase.com/)
* **Database:** PostgreSQL
* **Fitur:** Authentication, Realtime Subscription, Storage, Row Level Security (RLS)

### Dependencies Utama
* `supabase_flutter: ^2.10.3`
* `google_fonts` (untuk tipografi)
* `intl` (untuk format tanggal/waktu)

---

## 📂 Struktur Database
<img width="2454" height="1415" alt="supabase-schema-ppvjjumolctwzrednvul (2)" src="https://github.com/user-attachments/assets/5b5652fc-9208-46c2-ba02-af25a9459fb9" />

Detail link supabase 
https://supabase.com/dashboard/project/ppvjjumolctwzrednvul/database/schemas
https://supabase.com/dashboard/project/ppvjjumolctwzrednvul/database/tables
---
## 📂 Asset 
🔗 **[Lihat Desain Figma SahabatRS]([https://www.figma.com/design/RSRvSbYlpjCLZefnMFbZXk/MobileApp----SahabatRS--Copy-?node-id=2-2&t=XdKx4AX45IYXwlxd-1](https://www.figma.com/design/RSRvSbYlpjCLZefnMFbZXk/MobileApp----SahabatRS--Copy-?node-id=2-3&t=ZJVZkgQB83cn7sWW-1))**


## 🚀 Cara Menjalankan Project (Installation)

Ikuti langkah-langkah berikut untuk menjalankan aplikasi di lingkungan lokal Anda:

### 1. Prasyarat
Pastikan Anda telah menginstal:
* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* Visual Studio Code atau Android Studio
* Git

### 2. Clone Repository
Salin repositori ini ke komputer lokal Anda:

```bash
git clone https://github.com/manzil26/sahabatRS.git
cd sahabat-rs
````

### 3\. Instal Dependencies

Unduh semua paket Dart yang diperlukan:

```bash
flutter pub get
```

### 4\. Konfigurasi Environment (Supabase)

Buat file `.env` di root folder atau sesuaikan konfigurasi di `lib/main.dart` dengan kredensial Supabase Anda.

```dart
// Contoh di lib/main.dart
await Supabase.initialize(
    url: "https://ppvjjumolctwzrednvul.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBwdmpqdW1vbGN0d3pyZWRudnVsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxMjU3NDksImV4cCI6MjA3OTcwMTc0OX0.62vU78949hwLBnNzuPq_hrGMwPY5aH7jFRzRbmvIJJc",
  );
```

### 5\. Jalankan Aplikasi

Hubungkan device fisik atau emulator, lalu jalankan perintah:

```bash
flutter run
```

-----

## 🎨 Desain UI/UX

Desain antarmuka aplikasi ini dirancang menggunakan Figma. Anda dapat melihat *High-Fidelity Prototype* kami melalui tautan di bawah ini:

🔗 **[Lihat Desain Figma SahabatRS]([https://www.figma.com/design/RSRvSbYlpjCLZefnMFbZXk/MobileApp----SahabatRS--Copy-?node-id=2-2&t=XdKx4AX45IYXwlxd-1](https://www.figma.com/design/RSRvSbYlpjCLZefnMFbZXk/MobileApp----SahabatRS--Copy-?node-id=2-3&t=ZJVZkgQB83cn7sWW-1))**

-----

## 👥 Tim Pengembang (Kelompok 6)

Berikut adalah anggota tim yang berkontribusi dalam pengembangan aplikasi SahabatRS:

| NRP | Nama Anggota |
| :--- | :--- |
| **5026231036** | **Shafly Hidayatullah** |
| **5026231037** | **Al-Khiqmah Manzilatul M.** |
| **5026231038** | **Nabila Shinta Luthfia** |
| **5026231128** | **Fadhiil Akmal Hamizan** |
| **5026231196** | **Ni Kadek Adelia Paramita P.** |
| **5026231139** | **Amandea Chandiki L.** |
| **5026231176** | **Harya Raditya Handoyo** |

-----

## 📄 Lisensi

Hak Cipta © 2025 **SahabatRS Team** - Institut Teknologi Sepuluh Nopember (ITS).
Disusun untuk tujuan pendidikan dan pengembangan teknologi kesehatan masyarakat.
