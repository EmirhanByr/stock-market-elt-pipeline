SELECT 
  hisse_kodu,
  COUNT(islem_tarihi) AS islem_gunu_sayisi,
  MIN(en_dusuk) AS ayin_en_dusugu,
  MAX(en_yuksek) AS ayin_en_yuksegi,
  ROUND(AVG(kapanis_fiyati), 2) AS ortalama_fiyat,
  ROUND(AVG(gunluk_degisim_yuzdesi), 2) AS ort_gunluk_getiri_yuzdesi,
  -- RİSK METRİĞİ: Standart Sapma ile hissenin oynaklığını (Volatility) ölçüyoruz
  ROUND(STDDEV(gunluk_degisim_yuzdesi), 2) AS oynaklik_risk_skoru,
  SUM(islem_hacmi) AS toplam_islem_hacmi
FROM `veri-muhendisligi-101-511413.borsa_analizi.raw_hisse_fiyatlari`
GROUP BY hisse_kodu
ORDER BY ort_gunluk_getiri_yuzdesi DESC;
