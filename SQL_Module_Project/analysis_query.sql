Big Query SQL Code


/*
  Підсумкове завдання: Аналіз динаміки емейлів та підписників.
  Логіка:
  1. CTE `account_data`: збирає дані про реєстрації акаунтів (дата створення).
  2. CTE `email_data`: збирає дані про активність листів (дата відправки).
  3. Об'єднуємо все через UNION ALL у довгий формат (Long Format).
  4. Використовуємо віконні функції для розрахунку загальних сум по країні та рангів.
  5. Фільтруємо ТОП-10 країн за кількістю підписників або листів.
*/


WITH account_data AS (
  -- 1. Збираємо метрики по АКАУНТАХ (реєстрації)
  SELECT
    s.date AS date, -- Дата створення акаунта
    sp.country,
    a.send_interval,
    a.is_verified,
    a.is_unsubscribed,
    COUNT(DISTINCT a.id) AS account_cnt, -- Рахуємо кількість акаунтів
    0 AS sent_msg,    -- Для цієї частини ці метрики дорівнюють 0
    0 AS open_msg,
    0 AS visit_msg
  FROM
    `DA.account` a
  JOIN
    `DA.account_session` acs ON a.id = acs.account_id
  JOIN
    `DA.session` s ON acs.ga_session_id = s.ga_session_id
  JOIN
    `DA.session_params` sp ON acs.ga_session_id = sp.ga_session_id
  GROUP BY
    1, 2, 3, 4, 5
),


email_data AS (
  -- 2. Збираємо метрики по ЕМЕЙЛАХ (відправка, відкриття, кліки)
  SELECT
    DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS date, -- Розраховуємо реальну дату відправки
    sp.country,
    a.send_interval,
    a.is_verified,
    a.is_unsubscribed,
    0 AS account_cnt, -- Тут акаунти не рахуємо
    COUNT(DISTINCT es.id_message) AS sent_msg,
    COUNT(DISTINCT eo.id_message) AS open_msg,
    COUNT(DISTINCT ev.id_message) AS visit_msg
  FROM
    `DA.email_sent` es
  JOIN
    `DA.account` a ON es.id_account = a.id
  JOIN
    `DA.account_session` acs ON a.id = acs.account_id
  JOIN
    `DA.session` s ON acs.ga_session_id = s.ga_session_id
  JOIN
    `DA.session_params` sp ON acs.ga_session_id = sp.ga_session_id
  LEFT JOIN
    `DA.email_open` eo ON es.id_message = eo.id_message
  LEFT JOIN
    `DA.email_visit` ev ON es.id_message = ev.id_message
  GROUP BY
    1, 2, 3, 4, 5
),


combined_data AS (
  -- 3. Об'єднуємо дані через UNION ALL
  SELECT * FROM account_data
  UNION ALL
  SELECT * FROM email_data
),


aggregated_final AS (
  -- 4. Агрегуємо дані після об'єднання
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    SUM(account_cnt) AS account_cnt,
    SUM(sent_msg) AS sent_msg,
    SUM(open_msg) AS open_msg,
    SUM(visit_msg) AS visit_msg
  FROM
    combined_data
  GROUP BY
    1, 2, 3, 4, 5
),


window_calculations AS (
  -- 5. Рахуємо загальні суми по країні та Ранги (Window Functions)
  SELECT
    *,
    SUM(account_cnt) OVER(PARTITION BY country) AS total_country_account_cnt,
    SUM(sent_msg) OVER(PARTITION BY country) AS total_country_sent_cnt
  FROM
    aggregated_final
),


ranked_data AS (
  -- 6. Присвоюємо ранги
  SELECT
    *,
    DENSE_RANK() OVER(ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt,
    DENSE_RANK() OVER(ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt
  FROM
    window_calculations
)


-- 7. Фінальна вибірка ТОП-10
SELECT
  *
FROM
  ranked_data
WHERE
  rank_total_country_account_cnt <= 10 
  OR rank_total_country_sent_cnt <= 10
ORDER BY
  rank_total_country_account_cnt, date;
