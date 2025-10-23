[English](README.md)        [Русский](README_Russian.md)        [中文](README_Chinese.md)        [हिन्दी](README_Hindi.md)        [Español](README_Spanish.md)        [Français](README_French.md)        [Deutsch](README_German.md)        [Português](README_Portuguese.md)        [日本語](README_Japanese.md)        [Bahasa Indonesia](README_Indonesian.md)

# SuperWEIRD Game Kit

Hai! Di [Luden.io](https://luden.io?utm_source=superweirdgamekit&utm_medium=github) kami sedang mengembangkan [SuperWEIRD](https://superweird.shop?utm_source=superweirdgamekit&utm_medium=github) (lihat gimnya di [Steam](https://store.steampowered.com/app/3818770/SuperWEIRD/?utm_source=superweirdgamekit&utm_medium=github)). Ini adalah gim co-op tentang merancang dan mengotomatisasi sistem dengan robot mirip lemming, dibangun dengan mesin [Defold](https://defold.com).

Di awal pengembangan kami menjalankan banyak eksperimen dengan gaya visual dan gameplay. Kami pikir ini bisa berguna bagi pengembang lain dan memutuskan untuk merilis kode, tekstur, dan animasi dari eksperimen tersebut di bawah lisensi terbuka [CC0](LICENSE).

Di repositori ini Anda akan menemukan enam gaya visual yang berbeda ([video](https://youtu.be/RJwOEDY3MP4)) dan logika gameplay dari simulator toko/produksi. Pemain memenuhi pesanan pelanggan dan memperluas produksi. Anda dapat memainkan [demo on itch.io](https://ludenio.itch.io/superweird-game-kit?utm_source=superweirdgamekit&utm_medium=github).

[![Project Video](youtube_intro_cover.png)](https://youtu.be/PM8bngSynXQ)

Gabung ke [Discord](https://discord.gg/ludenio) untuk memberi tahu kami apa yang akan Anda bangun dengan prototipe ini. Atau kunjungi [YouTube channel](https://www.youtube.com/@ludenio) — ada banyak hal bagus, termasuk [SuperWEIRD dev diaries](https://www.youtube.com/@ludenio/videos).

Tautan:
- Discord (kami ada di sana setiap hari): https://discord.gg/ludenio
- YouTube: https://www.youtube.com/@ludenio
- Newsletter dengan pembaruan dan dev diary teks: https://ludenio.substack.com/
- Twitter (X): https://x.com/luden_io

# Mitra

[![Carina](carina_logo.png)](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun)

SuperWEIRD dibuat dengan dukungan dari [Carina Initiatives](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun), sebuah dana filantropi yang bekerja untuk memberi anak-anak dari berbagai komunitas akses ke sains dan teknologi. Mereka melihat matematika sebagai fondasi inovasi masa depan dan mendanai organisasi yang menginspirasi serta mengembangkan talenta matematika. Jika Anda tertarik pada proyek pendidikan lainnya, lihat para mitra Carina Initiatives:

[![NMS](nms_logo.png)](https://nationalmathstars.org/?utm_source=ludenio&utm_medium=superweirdwebsite)
[![Brilliant](brilliant_logo.png)](https://educator.brilliant.org/?utm_source=superweird&utm_medium=website&utm_campaign=carina_banner&utm_content=fun)
[![AoPS](aops_logo.png)](https://artofproblemsolving.com/alcumus?utm_source=superweird&utm_medium=display&utm_campaign=carina_alcumus_banner&utm_content=fun)

# Mulai Cepat

1. Instal Defold Editor: https://defold.com
2. Klon atau unduh repositori.
3. Buka folder proyek di Defold Editor.
4. Bangun dan jalankan proyek.

Catatan: Mengedit animasi Spine memerlukan Spine Editor.

# Struktur Proyek

1. Pemuatan
   - `loader` — dimulai bersama gim, tetap di memori, dan mengelola pemuatan/pelepasan koleksi melalui Collection Proxy; saat peluncuran menginisialisasi menu awal.
   - `menu` — menu awal yang ditampilkan saat gim dimulai.

2. Inti
   - `main` — kode gim bersama: skrip dan modul yang digunakan di seluruh dunia; berisi seluruh logika gim.
   - `assets` — aset gim: tekstur, model Spine, tilemap, dan atlas. Setiap dunia memiliki foldernya masing-masing `world_1`, `world_2`, dll., dengan visual unik.
   - `worlds` — pengaturan visual dunia: koleksi dan objek gim. Setiap dunia adalah koleksi terpisah di `world_1`, `world_2`, dll.

3. Tambahan
   - `SuperWEIRDGameKit_assets` — kumpulan grafis dan model Spine yang tertata, digunakan dalam proyek.

# Logika Manajemen Dunia

- Pergantian dunia ditangani melalui `loader`, yang memuat dan membongkar koleksi.
- Kustomisasi dunia: perbarui parameter visual dan objek gim di `worlds/world_X`, dan grafis di `assets/world_X`.

## Menambahkan Dunia Baru

1. Buat folder `assets/world_N` dan `worlds/world_N`.
2. Salin templat dari dunia yang sudah ada.
3. Daftarkan dunia baru di kode loader/menu (lihat logika di `main`).
4. Pastikan koleksi dan aset ditautkan dengan benar.
