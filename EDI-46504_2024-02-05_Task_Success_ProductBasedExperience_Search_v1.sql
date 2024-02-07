-- TASK SUCCESS METRIC: SEARCH CONVERSION
-- TRACK: FINDABILITY - PRODUCT-BASED EXPERIENCE
-- TOUCHPOINT: USING SEARCH ENGINE
-- AUTHOR: MAREK MLODOZENIEC

-- IMPORTANT: IF THIS SCRIPT IS TO BE CHANGED, THE TWIN SCRIPT [TRACK: FINDABILITY / TOUCHPOINT: USING SEARCH ENGINE] HAS TO BE CHANGED ACCORDINGLY

DECLARE start_date DATE DEFAULT '2023-01-01';
DECLARE end_date DATE DEFAULT '2024-01-31';

WITH

`raw` AS (
  SELECT
    DATE(lf._partitiontime) AS v_date,
    lf.search_id,
    sl.user.service_user_id AS user_id,
    CASE
      WHEN device_type = 'desktop' THEN 'Desktop'
      WHEN device_type = 'mobile_web' THEN 'Mobile Web'
      WHEN device_type = 'android_app' THEN 'Android App'
      WHEN device_type = 'ios_app' THEN 'iOS App'
      ELSE NULL
    END AS weight_value_group,
    CASE
      WHEN marketplace IS NULL OR marketplace = 'allegro-pl' THEN 'allegro-pl'
      WHEN marketplace = 'allegro-cz' THEN 'allegro-cz'
      ELSE NULL
    END AS marketplace,
    listing_type,
    CASE WHEN
      flag_show_item = true THEN 1
      ELSE 0
    END AS conversion
  FROM `sc-10067-search-analytics-prod.search_prod.all_listings_flags` lf
    LEFT JOIN `sc-9366-nga-prod.search_logs.search_logs` sl USING (search_id)
  WHERE
    DATE(lf._partitiontime) BETWEEN start_date AND end_date
    AND DATE(sl._partitiontime) BETWEEN start_date AND end_date
    AND listing_type = 'PRODUCT' -- touchpoint = Product-based experience
)

SELECT
  DATE_TRUNC(v_date, MONTH) AS dt_mth,
  marketplace,
  'Findability - Product-Based Experience' AS track,
  'Using search engine' AS touch_point,
  weight_value_group,
  SUM(conversion) AS numerator,
  COUNT(DISTINCT search_id) AS denominator,
  AVG(conversion) AS task_success
FROM `raw`
GROUP BY
  dt_mth,
  weight_value_group,
  marketplace
ORDER BY
  dt_mth,
  marketplace,
  weight_value_group
;
