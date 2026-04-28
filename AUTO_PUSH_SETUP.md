# Auto-Push Setup - Dokumentasi

## 📋 Ringkasan

Setup telah berhasil dikonfigurasi untuk melakukan auto-push ke GitHub secara realtime. Setiap perubahan file akan secara otomatis di-commit dan di-push ke repository GitHub.

## ✅ Apa yang Sudah Dilakukan

1. **Extract File ZIP**: Semua file dari `HamOS-main.zip` telah diekstrak ke workspace
2. **Git Configuration**: Git user telah dikonfigurasi untuk codespace
3. **Initial Commit & Push**: Semua file dari ekstraksi sudah di-push ke GitHub
4. **Auto-Push Service**: Service daemon telah dibuat untuk memantau perubahan file realtime

## 🚀 Auto-Push Service

### Cara Kerja

Service memantau perubahan file di direktori `/workspaces/hamos` dan secara otomatis:
1. Mendeteksi perubahan dengan `inotifywait` atau polling
2. Melakukan `git add -A` untuk stage semua perubahan
3. Membuat commit dengan timestamp otomatis
4. Melakukan `git push origin main`

### Direktori yang Dipantau

- ✓ Semua file dan folder kecuali:
  - `.git/`
  - `node_modules/`
  - `.vscode/`
  - `.next/`
  - `dist/`
  - `build/`

## 📝 Mengelola Service

### Status Service

```bash
./manage-autopush.sh status
```

### Memulai Service

```bash
./manage-autopush.sh start
```

### Menghentikan Service

```bash
./manage-autopush.sh stop
```

### Restart Service

```bash
./manage-autopush.sh restart
```

### Melihat Logs Realtime

```bash
./manage-autopush.sh logs
```

## 📊 Monitoring

### Melihat Status Proses

```bash
ps aux | grep auto-push | grep -v grep
```

### Log File

Semua aktivitas auto-push disimpan di: `.auto-push.log`

```bash
cat .auto-push.log
tail -f .auto-push.log
```

## ⚙️ File-File yang Dibuat

1. **auto-push.sh** - Script utama untuk memantau dan push file
2. **manage-autopush.sh** - Script untuk mengelola service
3. **AUTO_PUSH_SETUP.md** - Dokumentasi ini

## ⚠️ Catatan Penting

1. **Real-time Monitoring**: Menggunakan `inotifywait` untuk monitoring real-time. Jika tidak tersedia, akan fallback ke polling mode (5 detik per pemeriksaan)

2. **Perubahan Besar**: Jika melakukan perubahan dalam jumlah file yang sangat besar, service mungkin membutuhkan waktu untuk memproses

3. **Koneksi Internet**: Service memerlukan koneksi internet yang stabil untuk push ke GitHub

4. **Log File**: Log dapat menjadi besar seiring waktu, pertimbangkan untuk di-archive atau di-clear secara berkala

## 🔧 Troubleshooting

### Service Tidak Running

```bash
# Cek status
./manage-autopush.sh status

# Restart
./manage-autopush.sh restart

# Cek log untuk error
./manage-autopush.sh logs
```

### Push Gagal

Mungkin ada issue dengan:
- Koneksi internet
- GitHub authentication
- Branch protection rules

Cek log untuk detail error:
```bash
tail -50 .auto-push.log
```

### Terlalu Banyak Commits

Jika perlu mengurangi frequency commits, edit `auto-push.sh` dan ubah delay dalam fallback mode:
```bash
sleep 5  # Ubah menjadi sleep 30 atau lebih besar
```

## 📦 Struktur Project

Setelah ekstraksi, project memiliki struktur:

```
/workspaces/hamos/
├── HamOS-main.zip          # File asli (skip dari push jika diperlukan)
├── auto-push.sh            # Script auto-push
├── manage-autopush.sh      # Script manajemen
├── AUTO_PUSH_SETUP.md      # Dokumentasi (file ini)
├── .git/                   # Repository git
├── .gitignore              # Git ignore rules
├── app/                    # Application source
├── lib/                    # Library code
├── android/                # Android source
└── ... (file-file lainnya)
```

## ✨ Best Practices

1. **Commit Messages**: Service membuat commit dengan format: `Auto-commit: YYYY-MM-DD HH:MM:SS`
2. **Monitoring**: Secara berkala check logs untuk memastikan service berjalan dengan baik
3. **Backup**: Pastikan selalu ada backup sebelum membuat perubahan besar
4. **Testing**: Test secara manual sebelum mengandalkan auto-push untuk file penting

## 🔐 Keamanan

- Pastikan GitHub credentials sudah ter-setup dengan baik (SSH key atau token)
- Jangan share `.hamli-secrets.json` atau file sensitif lainnya
- Review `.gitignore` untuk memastikan file sensitif tidak ter-push

---

**Setup Date**: 2026-04-28  
**Service Status**: ✓ Active  
**Push Branch**: main  
**Repository**: https://github.com/hamai-one/hamos
