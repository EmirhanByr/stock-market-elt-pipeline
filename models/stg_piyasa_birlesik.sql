CREATE OR REPLACE VIEW `veri-muhendisligi-101-511413.borsa_analizi.stg_piyasa_birlesik` AS
SELECT 
  h.islem_tarihi,
  h.hisse_kodu,
  s.sirket_adi,
  s.sektor,
  h.kapanis_fiyati AS kapanis_fiyati_tl,
  d.usd_try_kapanis,
  
  -- Dolar Bazlı Fiyat
  ROUND(h.kapanis_fiyati / d.usd_try_kapanis, 2) AS kapanis_fiyati_usd,
  h.islem_hacmi,

  -- TL Bazında Günlük Getiri (Önceki güne göre)
  ROUND(
    (h.kapanis_fiyati - LAG(h.kapanis_fiyati) OVER(PARTITION BY h.hisse_kodu ORDER BY h.islem_tarihi)) 
    / LAG(h.kapanis_fiyati) OVER(PARTITION BY h.hisse_kodu ORDER BY h.islem_tarihi) * 100, 
    2
  ) AS gunluk_getiri_tl_yuzde,

  -- USD Bazında Günlük Reel Getiri
  ROUND(
    ((h.kapanis_fiyati / d.usd_try_kapanis) - LAG(h.kapanis_fiyati / d.usd_try_kapanis) OVER(PARTITION BY h.hisse_kodu ORDER BY h.islem_tarihi)) 
    / LAG(h.kapanis_fiyati / d.usd_try_kapanis) OVER(PARTITION BY h.hisse_kodu ORDER BY h.islem_tarihi) * 100, 
    2
  ) AS gunluk_getiri_usd_yuzde

FROM `veri-muhendisligi-101-511413.borsa_analizi.raw_hisse_fiyatlari` h
INNER JOIN `veri-muhendisligi-101-511413.borsa_analizi.dim_sirketler` s 
  ON h.hisse_kodu = s.hisse_kodu
LEFT JOIN `veri-muhendisligi-101-511413.borsa_analizi.raw_doviz_kurlari` d 
  ON h.islem_tarihi = d.islem_tarihi
WHERE d.usd_try_kapanis IS NOT NULL;
