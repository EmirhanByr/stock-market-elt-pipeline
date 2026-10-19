SELECT 
  islem_tarihi,
  hisse_kodu,
  acilis_fiyati,
  kapanis_fiyati,
  gunluk_degisim_yuzdesi,
  islem_hacmi,
  -- STRATEJİK DOKUNUŞ 1: Her hissenin kendi içinde 5 günlük hareketli ortalaması (Window Function)
  ROUND(AVG(kapanis_fiyati) OVER (
    PARTITION BY hisse_kodu 
    ORDER BY islem_tarihi ASC 
    ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
  ), 2) AS hareketli_ortalama_5g,
  
  -- STRATEJİK DOKUNUŞ 2: Günün yönünü etiketleme
  CASE 
    WHEN gunluk_degisim_yuzdesi > 0 THEN 'Pozitif (Yükseliş)'
    WHEN gunluk_degisim_yuzdesi < 0 THEN 'Negatif (Düşüş)'
    ELSE 'Yatay'
  END AS gun_yonu,
  yuklenme_tarihi
FROM `veri-muhendisligi-101-511413.borsa_analizi.raw_hisse_fiyatlari`
ORDER BY hisse_kodu, islem_tarihi DESC;
