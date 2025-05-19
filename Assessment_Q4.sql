/*
Task: For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
Account tenure (months since signup)
Total transactions
Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
Order by estimated CLV from highest to lowest
*/

WITH customer_activity AS (
  /*
    I calculated the total number of savings transactions per customer
    and retrieved their signup date (date_joined) for tenure months.
  */
  SELECT 
    u.id AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    u.date_joined,
    COUNT(s.id) AS total_transactions
  FROM users_customuser AS u
  LEFT JOIN savings_savingsaccount AS s 
    ON u.id = s.owner_id
  GROUP BY u.id
),

customer_tenure_clv AS (
  /*
    I calculated tenure in months using PERIOD_DIFF, ensuring it's at least 1 
    to avoid division by zero, and I applied the CLV formula:
    CLV = (total_transactions / tenure_months) * 12 * 0.001
  */
  SELECT
    customer_id,
    name,
    GREATEST(PERIOD_DIFF(DATE_FORMAT(CURDATE(), '%Y%m'), DATE_FORMAT(date_joined, '%Y%m')), 1) AS tenure_months,
    total_transactions,
    ROUND((total_transactions / GREATEST(PERIOD_DIFF(DATE_FORMAT(CURDATE(), '%Y%m'), DATE_FORMAT(date_joined, '%Y%m')), 1)) * 12 * 0.001, 2) AS estimated_clv
  FROM customer_activity
)

-- I displayed the result ordered by estimated CLV in descending order
SELECT
  customer_id,
  name,
  tenure_months,
  total_transactions,
  estimated_clv
FROM customer_tenure_clv
ORDER BY estimated_clv DESC;
