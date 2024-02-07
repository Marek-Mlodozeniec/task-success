-- TASK SUCCESS METRIC: PURCHASE CONVERSION
-- TRACK: TRANSACTION
-- TOUCHPOINT: COMPLETING PURCHASE
-- AUTHOR: MAREK MLODOZENIEC

SELECT
  DATE_TRUNC(dt, MONTH) AS dt_mth,
  marketplace_id AS marketplace,
  'Transaction' AS track,
  'Completing Purchase' AS touch_point,
  /*
  CONCAT(
    CASE
      WHEN device_type = 'desktop' THEN 'Desktop'
      WHEN device_type = 'mobile_web' THEN 'Mobile Web'
      WHEN device_type = 'android-app' THEN 'Android App'
      WHEN device_type = 'ios-app' THEN 'iOS App'
    END,
    ' ',
    processentry
  ) AS weight_value_group,
  */
  CASE
      WHEN device_type = 'desktop' THEN 'Desktop'
      WHEN device_type = 'mobile_web' THEN 'Mobile Web'
      WHEN device_type = 'android-app' THEN 'Android App'
      WHEN device_type = 'ios-app' THEN 'iOS App'
  END AS weight_value_group,
  SUM(cnt_created) AS numerator,
  SUM(cnt_bought) AS denominator,
  IEEE_DIVIDE(SUM(cnt_bought), SUM(cnt_created)) AS purchase_conversion
FROM `sc-10230-checkout-prod.checkout_tableau.PAK_2635_backend_conversion_without_AP`
WHERE
  dt BETWEEN '2023-01-01' AND '2024-01-31'
  AND marketplace_id IN ('allegro-pl', 'allegro-cz')
  AND (marketplace_id = 'allegro-pl' OR dt >= '2023-05-01')
GROUP BY
  dt_mth,
  marketplace_id,
  device_type --,
  -- processentry
ORDER BY
  dt_mth,
  marketplace_id,
  device_type --,
  -- processentry
;
