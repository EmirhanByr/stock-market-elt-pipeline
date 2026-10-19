# 📈 Borsa İstanbul ELT Pipeline & In-Warehouse AI Dashboard

Google Cloud BigQuery üzerinde modern ELT mimarisi ve BigQuery ML kullanılarak geliştirilmiş uçtan uca veri mühendisliği ve finansal analitik projesi.

Bu proje; Borsa İstanbul verilerini çekip **Bronze**, **Silver** ve **Gold** katmanlarında modelledikten sonra, BigQuery ML (`ARIMA_PLUS`) ile fiyat tahminleri üretir ve sonuçları **Streamlit** dashboard üzerinde görselleştirir.

---

## 🏗️ Mimari & Katmanlar

- **ELT Pipeline:** Python ve Pandas ile çekilen piyasa verileri doğrudan BigQuery ambarına yüklenir.
- **Medallion Architecture:**
  - **Bronze:** Ham piyasa ve döviz verileri.
  - **Silver (`stg_piyasa_birlesik`):** Temizlenmiş, günlük getiri ve USD bazlı reel kazanç metrikleri eklenmiş model.
  - **Gold (`fct_ai_fiyat_tahminleri`, `fct_piyasa_hacim_sinyalleri`):** Sektör karneleri, hacim anomalisi alarmları ve ML tahminleri.
- **In-Warehouse AI:** BigQuery ML `ARIMA_PLUS` zaman serisi modeli ile %90 güven aralıklı 5 günlük gelecek fiyat koridoru.
- **Presentation Layer:** Streamlit ve Plotly destekli interaktif analitik paneli.

---

## 🖥️ İnteraktif Dashboard (Streamlit)

Dashboard üzerinden:
- Seçilen hisseye özel son kapanış, dolar bazlı getiri ve kümülatif reel kazanç KPI kartları,
- Geçmiş fiyat hareketi ile geleceğe dönük AI tahmin güven koridoru,
- Anomali hacim sinyalleri (Alım/Satım baskısı alarmları),
- Gelecek 5 günün taban/tavan fiyat tahmin dökümleri canlı olarak incelenebilir.

---

## 🚀 Projeyi Yerel Ortamda Çalıştırma Rehberi

Projeyi kendi bilgisayarınızda klonlayıp çalıştırmak için aşağıdaki adımları izleyin:

### 1. Depoyu Klonlayın
```bash
git clone [https://github.com/EmirhanByr/stock-market-elt-pipeline.git](https://github.com/EmirhanByr/stock-market-elt-pipeline.git)
cd stock-market-elt-pipeline
2. Sanal Ortamı Kurun ve Aktifleştirin
Bash
# Windows
python -m venv .venv
source .venv/Scripts/activate

# macOS / Linux
python3 -m venv .venv
source .venv/bin/activate
3. Bağımlılıkları Yükleyin
Bash
pip install -r requirements.txt
4. Google Cloud Yetkilendirmesi
Proje BigQuery veri ambarına bağlandığı için GCP erişimi gerektirir:

BigQuery okuma yetkisine sahip Service Account anahtarını proje ana dizinine gcp-key.json adıyla ekleyin.
(Alternatif olarak terminalde gcloud auth application-default login komutunu çalıştırabilirsiniz).

5. Web Panelini Başlatın
Bash
streamlit run app.py
Tarayıcınızda otomatik olarak http://localhost:8501 adresi açılacaktır.

🛠️ Kullanılan Teknolojiler
Cloud & DWH: Google Cloud BigQuery, BigQuery ML

Language & Libraries: Python, Pandas, Streamlit, Plotly, db-dtypes

Version Control: Git, GitHub