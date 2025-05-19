/* Task 2: Calculate the average number of transactions per customer per month and categorize them:
"High Frequency" (≥10 transactions/month)
"Medium Frequency" (3-9 transactions/month)
"Low Frequency" (≤2 transactions/month)
*/

WITH customer_monthly_avg AS (
  /*
    I created the first CTE to calculate:
    - total number of transactions for each customer (total_transactions)
    - the total number of months a customer had a transaction (active_months). And I used these to find 
    - the average transaction per customer per month (avg_transactions_per_month) by dividing 
    total_transactions by active months (rounded to 2 decimal places)
  */
  
  SELECT
    u.id AS customer_id,
    COUNT(s.id) AS total_transactions,
    COUNT(DISTINCT DATE_FORMAT(s.transaction_date, '%Y-%m')) AS active_months,
    ROUND(COUNT(s.id) / COUNT(DISTINCT DATE_FORMAT(s.transaction_date, '%Y-%m')), 2) AS avg_transactions_per_month
  FROM users_customuser AS u JOIN savings_savingsaccount AS s 
  ON u.id = s.owner_id
  WHERE s.transaction_date IS NOT NULL
  GROUP BY u.id
),

categorized_customers AS (
  /*
    I created the second CTE to assign each customer to a frequency category based on their
    average number of monthly transactions:
    - High Frequency: ≥ 10
    - Medium Frequency: 3–9
    - Low Frequency: ≤ 2
    using the CASE WHEN statement.
  */
  
  SELECT
    CASE
      WHEN avg_transactions_per_month <= 2 THEN 'Low Frequency'
      WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
      ELSE 'High Frequency'
    END AS frequency_category,
    avg_transactions_per_month
  FROM customer_monthly_avg
)

-- In the final aggregation, I counted customers based on frequency category and computed their average

SELECT
  frequency_category,
  COUNT(*) AS customer_count,
  ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM categorized_customers
GROUP BY frequency_category
ORDER BY 
  FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
