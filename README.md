#  Borsa İstanbul (BIST) Uçtan Uca ELT Veri Boru Hattı

Bu proje, Borsa İstanbul (BIST 100) lokomotif hisselerine ait günlük piyasa verilerini canlı API üzerinden çeken, **Apache Parquet** formatında serileştiren ve **Google Cloud BigQuery** veri ambarında katmanlı mimari (**Medallion / dbt yaklaşımı**) ile analize hazır hale getiren uçtan uca bir veri mühendisliği (ELT) projesidir.

---

##  Mimari Akış (Architecture)

```text
[Yahoo Finance API] 
       │
       ▼  (Extract & Ön İşleme - Python / Pandas)
[Apache Parquet] ──► (Tip Korumalı & Sıkıştırılmış Çıktı)
       │
       ▼  (Load - Google Cloud BigQuery)
[raw_hisse_fiyatlari] ──► Ham Veri Katmanı (Raw Layer)
       │
       ├──► [stg_gunluk_teknik_analiz] ──► 5 Günlük Hareketli Ortalama (Window Functions)
       │
       └──► [fct_hisse_performans_ozeti] ──► Aylık Getiri & Oynaklık/Risk Karnesi (Mart Layer)
```

---

##  Kullanılan Teknolojiler ve Mühendislik Kararları

* **Veri Çekme (Extract):** `Python` & `yfinance` kütüphanesi ile BIST hisselerinin (`THYAO`, `ASELS`, `TUPRS`, `GARAN`, `EREGL`) günlük Açılış, Kapanış, Hacim ve En Yüksek/Düşük verileri çekilmiştir.
* **Depolama Optimizasyonu (Parquet):** CSV formatının veri tipi kaybı ve yüksek boyut dezavantajlarını önlemek adına veriler `pyarrow` motoruyla sütun bazlı (columnar) **Apache Parquet** formatına dönüştürülmüştür.
* **Veri Soyu (Data Lineage):** Boru hattının çalışma zamanını izlemek için her kayda `yuklenme_tarihi` zaman damgası eklenmiş ve `index=False` standardı ile şema kirliliği önlenmiştir.
* **Bulut Veri Ambarı (OLAP):** Google Cloud **BigQuery** üzerinde maliyet optimizasyonu gözetilerek analitik dönüşümler fiziksel tablo kopyaları yerine sıfır depolama maliyeti sunan **SQL View** katmanlarıyla kurgulanmıştır.

---

##  Veri Modelleri (SQL Transformations)

### 1. `stg_gunluk_teknik_analiz` (Staging Katmanı)
SQL **Window Functions (`OVER PARTITION BY`)** kullanılarak her hissenin kendi zaman serisi içinde **5 Günlük Hareketli Ortalaması (5-Day Moving Average)** ve günlük trend yönü (`Pozitif`, `Negatif`, `Yatay`) hesaplanmıştır.

### 2. `fct_hisse_performans_ozeti` (Fact / Mart Katmanı)
Karar vericiler için her hissenin aylık en düşük/en yüksek fiyatları, ortalama günlük getiri yüzdesi, toplam işlem hacmi ve standart sapma (`STDDEV`) bazlı **Oynaklık (Volatility / Risk) Skoru** modellenmiştir.

---

##  Proje Klasör Yapısı

```text
├── 01_extract_borsa_verileri.ipynb   # API'den veri çekme, temizleme ve Parquet üretimi
├── models/
│   ├── stg_gunluk_teknik_analiz.sql  # Hareketli ortalama ve trend modeli (BigQuery View)
│   └── fct_hisse_performans_ozeti.sql# Risk ve getiri özet modeli (BigQuery View)
├── requirements.txt                  # Python kütüphane bağımlılıkları
└── README.md                         # Proje dokümantasyonu
```

