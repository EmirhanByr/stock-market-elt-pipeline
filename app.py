import streamlit as st
from google.cloud import bigquery
import plotly.graph_objects as go
import pandas as pd
import os

st.set_page_config(page_title="BIST Analitik & AI Dashboard", page_icon="📈", layout="wide")

st.title("📈 Borsa İstanbul ELT & In-Warehouse AI Analitik Paneli")
st.caption("Google Cloud BigQuery & BigQuery ML (ARIMA_PLUS) Canlı Veri Ambarı Entegrasyonu")

PROJECT_ID = "veri-muhendisligi-101-511413"
DATASET_ID = "borsa_analizi"
KEY_PATH = "gcp-key.json"

@st.cache_resource
def get_bigquery_client():
    if os.path.exists(KEY_PATH):
        return bigquery.Client.from_service_account_json(KEY_PATH, project=PROJECT_ID)
    return bigquery.Client(project=PROJECT_ID)

@st.cache_data(ttl=600)
def run_query(query: str) -> pd.DataFrame:
    client = get_bigquery_client()
    return client.query(query).to_dataframe()

with st.sidebar:
    st.header("⚙️ Kontrol Paneli")
    try:
        hisse_df = run_query(f"SELECT DISTINCT hisse_kodu FROM `{PROJECT_ID}.{DATASET_ID}.dim_sirketler` ORDER BY hisse_kodu")
        hisseler = hisse_df["hisse_kodu"].tolist()
    except Exception:
        hisseler = ["THYAO.IS", "ASELS.IS", "KCHOL.IS", "BIMAS.IS", "TUPRS.IS"]
    
    secilen_hisse = st.selectbox("İncelenecek Hisse:", hisseler)
    st.info("Veriler doğrudan BigQuery Silver ve Gold modellerinden canlı çekilmektedir.")

try:
    karne = run_query(f"SELECT * FROM `{PROJECT_ID}.{DATASET_ID}.fct_sektor_ve_reel_getiri_karnesi` WHERE hisse_kodu = '{secilen_hisse}'")
    piyasa = run_query(f"SELECT * FROM `{PROJECT_ID}.{DATASET_ID}.stg_piyasa_birlesik` WHERE hisse_kodu = '{secilen_hisse}' ORDER BY islem_tarihi")
    ai_tahmin = run_query(f"SELECT * FROM `{PROJECT_ID}.{DATASET_ID}.fct_ai_fiyat_tahminleri` WHERE hisse_kodu = '{secilen_hisse}' ORDER BY tahmin_tarihi")
    sinyaller = run_query(f"SELECT * FROM `{PROJECT_ID}.{DATASET_ID}.fct_piyasa_hacim_sinyalleri` WHERE hisse_kodu = '{secilen_hisse}' ORDER BY islem_tarihi DESC LIMIT 10")

    if not karne.empty and not piyasa.empty:
        son_gun = piyasa.iloc[-1]
        c1, c2, c3, c4 = st.columns(4)
        c1.metric("Son Kapanış (TL)", f"{son_gun['kapanis_fiyati_tl']:.2f} ₺", f"{son_gun['gunluk_getiri_tl_yuzde']}%")
        c2.metric("Dolar Bazlı Fiyat", f"${son_gun['kapanis_fiyati_usd']:.2f}", f"{son_gun['gunluk_getiri_usd_yuzde']}%")
        c3.metric("Kümülatif USD Getiri", f"%{karne.iloc[0]['kumulatif_getiri_usd_yuzde']:.2f}")
        c4.metric("Reel Getiri Durumu", karne.iloc[0]["reel_kazanc_durumu"])

    st.markdown("---")
    st.subheader(f"🤖 {secilen_hisse} - Fiyat Geçmişi & 5 Günlük AI Tahmin Koridoru")

    fig = go.Figure()
    fig.add_trace(go.Scatter(x=piyasa["islem_tarihi"], y=piyasa["kapanis_fiyati_tl"], mode="lines+markers", name="Gerçekleşen Fiyat (TL)", line=dict(color="#29b5e8", width=2)))
    fig.add_trace(go.Scatter(x=ai_tahmin["tahmin_tarihi"], y=ai_tahmin["tahmini_kapanis_fiyati"], mode="lines+markers", name="AI Tahmini", line=dict(color="#00cc96", width=2.5, dash="dash")))
    fig.add_trace(go.Scatter(x=list(ai_tahmin["tahmin_tarihi"]) + list(ai_tahmin["tahmin_tarihi"])[::-1], y=list(ai_tahmin["tavan_beklenti_fiyat"]) + list(ai_tahmin["taban_beklenti_fiyat"])[::-1], fill="toself", fillcolor="rgba(0, 204, 150, 0.15)", line=dict(color="rgba(255,255,255,0)"), hoverinfo="skip", name="%90 Güven Aralığı Koridoru"))

    fig.update_layout(xaxis_title="Tarih", yaxis_title="Fiyat (TL)", hovermode="x unified", height=430)
    st.plotly_chart(fig, use_container_width=True)

    col1, col2 = st.columns(2)
    with col1:
        st.subheader("🚨 Son Hacim Anomalileri")
        st.dataframe(sinyaller[["islem_tarihi", "islem_hacmi", "hacim_patlama_orani", "piyasa_sinyali"]], use_container_width=True, hide_index=True)
    with col2:
        st.subheader("🎯 5 Günlük AI Tahmin Raporu")
        st.dataframe(ai_tahmin[["tahmin_tarihi", "tahmini_kapanis_fiyati", "taban_beklenti_fiyat", "tavan_beklenti_fiyat", "guven_orani"]], use_container_width=True, hide_index=True)

except Exception as e:
    st.error(f"BigQuery Bağlantı Hatası: {e}")
