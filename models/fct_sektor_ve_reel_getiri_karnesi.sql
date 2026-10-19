CREATE OR REPLACE VIEW `veri-muhendisligi-101-511413.borsa_analizi.fct_sektor_ve_reel_getiri_karnesi` AS
SELECT 
  sektor,
  hisse_kodu,
  sirket_adi,
  COUNT(islem_tarihi) AS toplam_islem_gunu,
  ROUND(AVG(kapanis_fiyati_tl), 2) AS ortalama_fiyat_tl,
  ROUND(AVG(kapanis_fiyati_usd), 2) AS ortalama_fiyat_usd,
  ROUND(SUM(gunluk_getiri_tl_yuzde), 2) AS kumulatif_getiri_tl_yuzde,
  ROUND(SUM(gunluk_getiri_usd_yuzde), 2) AS kumulatif_getiri_usd_yuzde,
  CASE 
    WHEN SUM(gunluk_getiri_usd_yuzde) > 0 THEN 'Reel Getiri Sağladı 🚀'
    ELSE 'Dolar/Kur Altında Kaldı ⚠️'
  END AS reel_kazanc_durumu
FROM `veri-muhendisligi-101-511413.borsa_analizi.stg_piyasa_birlesik`
GROUP BY sektor, hisse_kodu, sirket_adi
ORDER BY kumulatif_getiri_usd_yuzde DESC;
