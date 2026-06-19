
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

-- задание 1:
SELECT 
    ID_client,
    COUNT(Id_check) AS total_operations,               
    ROUND(AVG(Sum_payment), 2) AS avg_check,           
    ROUND(SUM(Sum_payment) / 12, 2) AS avg_monthly_amount 
FROM transactions_info
WHERE STR_TO_DATE(date_new, '%d/%m/%Y') >= '2015-06-01' 
  AND STR_TO_DATE(date_new, '%d/%m/%Y') <= '2016-06-01'
GROUP BY ID_client
HAVING COUNT(DISTINCT RIGHT(date_new, 7)) = 12;

-- задание 2:
SELECT 
    RIGHT(t.date_new, 7) AS month_period,                  
    ROUND(AVG(t.Sum_payment), 2) AS monthly_avg_check,
    COUNT(t.Id_check) AS monthly_operations_count,
    COUNT(DISTINCT t.ID_client) AS active_customers,
    
    ROUND((COUNT(t.Id_check) / 419122.0) * 100, 2) AS share_of_year_operations_pct,
    ROUND((SUM(t.Sum_payment) / (SELECT SUM(Sum_payment) FROM transactions_info)) * 100, 2) AS share_of_year_amount_pct,
    
    ROUND((COUNT(CASE WHEN c.Gender = 'M' THEN 1 END) / COUNT(t.Id_check)) * 100, 2) AS male_pct,
    ROUND((COUNT(CASE WHEN c.Gender = 'F' THEN 1 END) / COUNT(t.Id_check)) * 100, 2) AS female_pct,
    ROUND((COUNT(CASE WHEN c.Gender IS NULL OR c.Gender = '' THEN 1 END) / COUNT(t.Id_check)) * 100, 2) AS na_gender_pct,

    ROUND((SUM(CASE WHEN c.Gender = 'M' THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment)) * 100, 2) AS male_spend_share_pct,
    ROUND((SUM(CASE WHEN c.Gender = 'F' THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment)) * 100, 2) AS female_spend_share_pct,
    ROUND((SUM(CASE WHEN c.Gender IS NULL OR c.Gender = '' THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment)) * 100, 2) AS na_spend_share_pct

FROM transactions_info t
LEFT JOIN customer_info c ON t.ID_client = c.Id_client
GROUP BY RIGHT(t.date_new, 7)
ORDER BY RIGHT(month_period, 4), LEFT(month_period, 2);

-- задание 3:
SELECT 
    CASE 
        WHEN c.Age IS NULL THEN 'Данные отсутствуют'
        WHEN c.Age < 20 THEN 'До 20 лет'
        WHEN c.Age BETWEEN 20 AND 29 THEN '20-29 лет'
        WHEN c.Age BETWEEN 30 AND 39 THEN '30-39 лет'
        WHEN c.Age BETWEEN 40 AND 49 THEN '40-49 лет'
        WHEN c.Age BETWEEN 50 AND 59 THEN '50-59 лет'
        ELSE '60 лет и старше'
    END AS age_group,

    CASE 
        WHEN SUBSTRING(t.date_new, 4, 2) IN ('01', '02', '03') THEN 'Квартал 1'
        WHEN SUBSTRING(t.date_new, 4, 2) IN ('04', '05', '06') THEN 'Квартал 2'
        WHEN SUBSTRING(t.date_new, 4, 2) IN ('07', '08', '09') THEN 'Квартал 3'
        ELSE 'Квартал 4'
    END AS quarter_period,

    ROUND(SUM(t.Sum_payment), 2) AS total_spend,
    COUNT(t.Id_check) AS total_operations,
    ROUND(AVG(t.Sum_payment), 2) AS avg_check,
    
    ROUND((COUNT(t.Id_check) / 419122.0) * 100, 2) AS share_of_total_operations_pct

FROM transactions_info t
LEFT JOIN customer_info c ON t.ID_client = c.Id_client
GROUP BY 1, 2
ORDER BY age_group, quarter_period;
