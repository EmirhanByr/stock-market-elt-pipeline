CREATE OR REPLACE VIEW `veri-muhendisligi-101-511413.borsa_analizi.fct_ai_fiyat_tahminleri` AS
SELECT
  hisse_kodu,
  DATE(forecast_timestamp) AS tahmin_tarihi,
  ROUND(forecast_value, 2) AS tahmini_kapanis_fiyati,
  ROUND(prediction_interval_lower_bound, 2) AS taban_beklenti_fiyat,
  ROUND(prediction_interval_upper_bound, 2) AS tavan_beklenti_fiyat,
  ROUND(confidence_level, 2) AS guven_orani
FROM
  ML.FORECAST(
    MODEL `veri-muhendisligi-101-511413.borsa_analizi.ml_hisse_fiyat_tahmini`,
    STRUCT(5 AS horizon, 0.90 AS confidence_level) -- Gelecek 5 gün, %90 güven aralığı
  )
ORDER BY hisse_kodu, tahmin_tarihi;
