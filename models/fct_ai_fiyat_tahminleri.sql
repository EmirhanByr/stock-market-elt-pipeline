CREATE OR REPLACE VIEW `veri-muhendisligi-101-511413.borsa_analizi.fct_piyasa_hacim_sinyalleri` AS
WITH hacim_trend AS (
  SELECT 
    islem_tarihi,
    hisse_kodu,
    kapanis_fiyati_tl,
    gunluk_getiri_tl_yuzde,
    islem_hacmi,
    ROUND(AVG(islem_hacmi) OVER (
      PARTITION BY hisse_kodu 
      ORDER BY islem_tarihi 
      ROWS BETWEEN 9 PRECEDING AND CURRENT ROW
    ), 0) AS hareketli_ortalama_hacim_10g
  FROM `veri-muhendisligi-101-511413.borsa_analizi.stg_piyasa_birlesik`
)
SELECT 
  islem_tarihi,
  hisse_kodu,
  kapanis_fiyati_tl,
  gunluk_getiri_tl_yuzde,
  islem_hacmi,
  hareketli_ortalama_hacim_10g,
  ROUND((islem_hacmi / NULLIF(hareketli_ortalama_hacim_10g, 0)), 2) AS hacim_patlama_orani,
  CASE 
    WHEN islem_hacmi > (hareketli_ortalama_hacim_10g * 1.5) AND gunluk_getiri_tl_yuzde > 0 THEN 'Güçlü Alış Baskısı 🟢'
    WHEN islem_hacmi > (hareketli_ortalama_hacim_10g * 1.5) AND gunluk_getiri_tl_yuzde < 0 THEN 'Güçlü Satış Baskısı 🔴'
    ELSE 'Normal Seyir'
  END AS piyasa_sinyali
FROM hacim_trend
ORDER BY islem_tarihi DESC, hisse_kodu;
