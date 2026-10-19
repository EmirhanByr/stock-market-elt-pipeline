# Borsa İstanbul (BIST) Uçtan Uca ELT & In-Warehouse AI Veri Boru Hattı

Bu proje; Borsa İstanbul lokomotif hisseleri, piyasa döviz kurları (USD/TRY) ve şirket boyut verilerini API üzerinden toplayan, bellek içinde işleyerek Google Cloud BigQuery veri ambarına aktaran, ilişkisel Star Schema / Medallion Mimarisi ile modelleyen ve BigQuery ML (ARIMA_PLUS) algoritmasıyla fiyat tahminleri üreten uçtan uca bir veri mühendisliği boru hattıdır.

---

## Sistem Mimarisi

* **Extract & Ingestion (Python):** `yfinance` ile hisse fiyatları ve USD/TRY kuru toplanır.
* **Storage & Data Warehouse (Google Cloud BigQuery):**
  * **Bronze (Raw):** `raw_hisse_fiyatlari`, `raw_doviz_kurlari`, `dim_sirketler`
  * **Silver (Staging):** `stg_piyasa_birlesik` (JOIN ve LAG ile günlük TL/USD reel getiri hesabı)
  * **Gold (Marts & AI):** `fct_sektor_ve_reel_getiri_karnesi`, `fct_piyasa_hacim_sinyalleri`, `fct_ai_fiyat_tahminleri`
* **In-Warehouse AI (BigQuery ML):** Veri dışarı aktarılmadan SQL içinde `ARIMA_PLUS` ile 5 günlük fiyat projeksiyonu üretilir.

---

## Öne Çıkan Mühendislik Pratikleri

* **Idempotent Boru Hattı:** `WRITE_TRUNCATE` stratejisi ile tekrarlanan çalıştırmalarda veri çoğalması (duplicate) engellenir.
* **Bellek İçi Akış (In-Memory Load):** Veriler diske yazılmadan doğrudan Python RAM'inden BigQuery API'sine aktarılır.
* **İleri SQL Analitiği:** Window Functions (`LAG`, `ROWS BETWEEN`) kullanılarak hisse bazlı izolasyonla kayan hacim ortalamaları ve kur düzeltmeli reel getiriler hesaplanır.
* **In-Warehouse Machine Learning:** Tahminleme modeli doğrudan veri tabanında eğitilerek veri taşıma maliyeti ve güvenlik açıkları sıfıra indirilir.

---

## Veri Modelleri

* `stg_piyasa_birlesik.sql`: Şirket sektörü, Dolar kuru ve hisse verilerini birleştirip günlük reel getiriyi hesaplar.
* `fct_sektor_ve_reel_getiri_karnesi.sql`: Kümülatif getiriyi Dolar kuruyla karşılaştırarak reel kazanç durumunu etiketler.
* `fct_piyasa_hacim_sinyalleri.sql`: 10 günlük ortalama hacim üzerinden hacim patlamalarını ve yön baskısını tespit eder.
* `fct_ai_fiyat_tahminleri.sql`: BigQuery ML ile her hisse için 5 günlük alt ve üst fiyat beklenti koridorlarını listeler.

---

## Proje Dizin Yapısı

* `01_ingest_market_data.ipynb` - Veri çekme ve BigQuery otomatik yükleme scripti
* `models/` - Analitik dönüşüm ve makine öğrenmesi SQL modelleri
* `requirements.txt` - Python kütüphane bağımlılıkları
* `README.md` - Proje mimari dokümantasyonu

---

## Yerel Kurulum

Projeyi yerel ortamda çalıştırmak için:

1. Depoyu klonlayın:
   git clone https://github.com/KULLANICI_ADIN/borsa-elt-data-pipeline.git
2. Proje dizinine gidin:
   cd borsa-elt-data-pipeline
3. Gerekli kütüphaneleri yükleyin:
   pip install -r requirements.txt
