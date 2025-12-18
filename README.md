# SahabatRS 🏥👴👵

**Solusi Pendampingan Medis & Layanan Kesehatan Digital untuk Lansia**

SahabatRS adalah aplikasi *mobile* berbasis Flutter yang dirancang untuk membantu lansia mengakses fasilitas kesehatan dengan lebih mudah, aman, dan nyaman. Aplikasi ini menghubungkan pasien dengan pendamping terlatih untuk menemani proses berobat, mulai dari penjemputan, administrasi, hingga pengantaran kembali ke rumah.

Project ini dikembangkan sebagai **Final Project Mata Kuliah Teknologi Berkembang - Kelas B (Kelompok 6)** di Institut Teknologi Sepuluh Nopember (ITS).

---

## 📱 Fitur Utama

Aplikasi ini memiliki berbagai fitur yang disesuaikan dengan kebutuhan lansia dan keluarganya:

* **Pesan Pendamping (Booking):** Memesan jasa pendamping medis untuk rawat jalan dengan pilihan moda transportasi (motor/mobil).
* **Live Tracking:** Keluarga dapat memantau lokasi pasien dan pendamping secara *real-time* demi keamanan dan transparansi.
* **Penjadwalan:**untuk membuat, melihat, mengedit  jadwal reminder obat dan pengantaran checkup.
* **Chat:** Komunikasi langsung antara pengguna/keluarga dengan pendamping (driver) di dalam aplikasi.
* **Pengantaran darurat:** fitur ini dirancang untuk keadaan urgent seperti kecelakaan yang langsung kendaraannya mobil
* **Pembayaran Digital:** Kemudahan transaksi *cashless* (e-wallet, transfer bank) untuk mengurangi penggunaan uang tunai.
* **Profil:** Menyimpan data kesehatan penting (kondisi medis, kontak darurat).
* **Autentikasi** Fitur login dan register. 

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
Storages avatar untuk gambar profile 
<img width="2266" height="731" alt="image" src="https://github.com/user-attachments/assets/755c662b-49ce-4e0b-8066-88e8d96c88e4" />

🔗 **[Lihat Desain Figma SahabatRS]([https://www.figma.com/design/RSRvSbYlpjCLZefnMFbZXk/MobileApp----SahabatRS--Copy-?node-id=2-2&t=XdKx4AX45IYXwlxd-1](https://www.figma.com/design/RSRvSbYlpjCLZefnMFbZXk/MobileApp----SahabatRS--Copy-?node-id=2-3&t=ZJVZkgQB83cn7sWW-1))**

## 📂 Struktur Folder Fitur 
<img width="599" height="1283" alt="Screenshot 2025-12-18 082125" src="https://github.com/user-attachments/assets/0c768f8f-2c88-4064-8b9d-6e1a74225693" />

## 📂 Struktur Folder Fitur integrasi 
<img width="567" height="408" alt="Screenshot 2025-12-18 083301" src="https://github.com/user-attachments/assets/1c735907-d69f-4bad-ab57-8d9c3dec821f" />

## 📂 Backlog 
<img width="2877" height="1122" alt="image" src="https://github.com/user-attachments/assets/07810cb1-cb6f-459f-9c6b-6e042e60a203" />

https://github.com/users/manzil26/projects/3

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

### 3. Instal Dependencies

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
