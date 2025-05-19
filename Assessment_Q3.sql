-- Task 3: Find all active plans (savings or investments) with no transactions in the last 365 days

WITH latest_transactions AS (
  /*
    I found the most recent transaction date For each plan using MAX function and I put them
    in a CTE for further analysis
  */
  
  SELECT
    plan_id,
    MAX(transaction_date) AS last_transaction_date
  FROM savings_savingsaccount
  GROUP BY plan_id
)

SELECT
  p.id AS plan_id,
  p.owner_id,
  /*
    I created the type column using CASE WHEN. I labeled the values Savings if is_regular_savings = 1 and
    investment if is_a_fund = 1
  */
  
  CASE 
    WHEN p.is_regular_savings = 1 THEN 'Savings'
    WHEN p.is_a_fund = 1 THEN 'Investment'
    ELSE 'Unknown'
  END AS type,
  lt.last_transaction_date,
  /*
    I found the number of inactive days by subtracting the most recent transaction date from
    current date.
  */
  
  DATEDIFF(CURDATE(), lt.last_transaction_date) AS inactivity_days
FROM plans_plan AS p
JOIN latest_transactions AS lt ON p.id = lt.plan_id

-- I filtered by status_id, is_deleted and is_archived to only include active plans
WHERE p.status_id = 1 AND 
  is_deleted = 0 AND 
  is_archived = 0

-- And filtered to only show plans with no activity in the past 365 days
  AND DATEDIFF(CURDATE(), lt.last_transaction_date) > 365
HAVING type <> 'Unknown'
ORDER BY inactivity_days DESC;
