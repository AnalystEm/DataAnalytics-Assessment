-- Task 1: Write a query to find customers with at least one funded savings plan AND one funded investment plan, 
-- sorted by total deposits. 

SELECT
	S.owner_id, 
    CONCAT(U.first_name,' ',U.last_name) AS name,
    
    /* 
  I'm using CASE WHEN inside COUNT to separately count savings and investment plans.
  I cannot filter three columns in the WHERE clause (e.g., confirmed_amount > 0 AND is_regular_savings = 1 AND
  is_a_fund = 1) on MySQL. Using CASE WHEN allows me to use the HAVING CLAUSE to filter
  the savings and investment plans together using the AND operator.
*/
    COUNT(CASE WHEN P.is_regular_savings = 1 THEN 1 END) AS savings_count,
    COUNT(CASE WHEN P.is_a_fund = 1 THEN 1 END) AS investment_count,
    
-- I converted total confirmed deposits from kobo to naira and rounded to 2 decimal places
    ROUND(SUM(S.confirmed_amount) / 100, 2) AS total_deposits
FROM 
	users_customuser AS U JOIN savings_savingsaccount AS S
	ON U.id = S.owner_id
    JOIN plans_plan AS P
    ON S.plan_id = P.id
WHERE
	S.confirmed_amount > 0
GROUP BY 
	S.owner_id
HAVING
	savings_count > 0 AND
    investment_count > 0
ORDER BY 
	total_deposits;
