
Question 1 Explanation

Task:
Write a query to find customers who have at least one funded savings plan and at least one funded investment plan, sorted by their total deposits in naira (descending).

My Approach:
I joined the three tables:

* users_customuser for customer info
* savings_savingsaccount for transactions
* plans_plan for plan type and ownership

I used S.plan_id = P.id to connect each transaction to its related plan.
I filtered out transactions where confirmed_amount is zero or NULL, so I only worked with funded transactions.
Since a single plan can't be both a savings and an investment plan, I couldn’t apply both filters in the WHERE clause.
Instead, I used CASE WHEN inside COUNT() to separately count:

* savings plans (is_regular_savings = 1)
* investment plans (is_a_fund = 1)

I grouped the data by each customer (S.owner_id) to get per-customer totals.
In the HAVING clause, I ensured each customer had:

* At least one savings plan (savings_count > 0)
* At least one investment plan (investment_count > 0)

I calculated total deposits by summing confirmed_amount, dividing by 100 (to convert from kobo to naira), and rounding to 2 decimal places.

Challenges:
None. The query was straightforward once I realized I needed to use CASE WHEN with HAVING instead of trying to combine the conditions directly in the WHERE clause.




Question 2 Explanation

Task:
Calculate the average number of transactions per customer per month and categorize them as High Frequency (≥10), Medium Frequency (3–9), or Low Frequency (≤2).

My Approach:
I created a common table expression (CTE) called customer_monthly_avg where I calculated:

The total number of transactions for each customer (total_transactions)

The total number of months the customer made at least one transaction (active_months)

Then I calculated the average number of transactions per month by dividing total_transactions by active_months. I used ROUND to keep the result to 2 decimal places.

In the second CTE named categorized_customers, I used a CASE WHEN block to assign each customer to a frequency category based on their average:

Low Frequency if avg ≤ 2

Medium Frequency if avg is between 3 and 9

High Frequency if avg ≥ 10

Finally, I selected the frequency category, counted how many customers were in each group, and calculated the average transactions per month for each group. I ordered the results so High Frequency appears first, followed by Medium and Low.

Challenges:
At first, I had to be careful not to count multiple months for the same customer, which would have led to duplicate rows. To solve this, I used COUNT(DISTINCT DATE_FORMAT(transaction_date, '%Y-%m')) to count unique months only. I also made sure my groupings were clean so each customer appeared only once.




Question 3 Explanation

Task:
Find all active plans (savings or investments) with no transactions in the last 365 days.

My Approach:

* I created a common table expression (CTE) named latest_transactions to get the most recent transaction date for each plan using the MAX function from the savings_savingsaccount table.
* I joined this CTE with the plans_plan table using plan_id to match each plan with its last known transaction date.
* I calculated the number of inactivity days by subtracting the last_transaction_date from the current date using DATEDIFF.
* I used a CASE WHEN block to assign a label to each plan: "Savings" for is_regular_savings = 1 and "Investment" for is_a_fund = 1.
* I filtered to include only plans that are active by checking that status_id = 1, is_deleted = 0, and is_archived = 0.
* I excluded any plan where the type was not savings or investment, and limited the results to only those with no transactions in the last 365 days.

Challenges:
The main challenge was that there was no column in the plans\_plan table that directly states whether a plan is active. I resolved this by analyzing how status_id, is_deleted, and is_archived behave. After checking their values across different plans, I concluded that a combination of status_id = 1, is_deleted = 0, and is_archived = 0 is a reliable way to identify active plans.




Question 4 Explanation

Task:
For each customer, assuming the profit per transaction is 0.1% of the transaction value, calculate account tenure (months since signup), total transactions, and estimated CLV. The CLV formula is (total\_transactions / tenure) \* 12 \* 0.001. Results should be ordered by estimated CLV from highest to lowest.

My Approach:

* I created a CTE named customer\_activity where I calculated the total number of savings transactions for each customer using COUNT, and retrieved their signup date (date\_joined) from the users\_customuser table.
* In a second CTE called customer\_tenure\_clv, I calculated tenure in months using PERIOD\_DIFF between the current date and the customer’s date\_joined.
* To avoid division by zero for new accounts, I wrapped the tenure calculation in GREATEST(..., 1) to ensure a minimum of 1 month.
* I then applied the given CLV formula: (total\_transactions / tenure\_months) \* 12 \* 0.001, where 0.001 represents 0.1% profit per transaction.
* I rounded the final CLV to two decimal places for better readability.
* In the final SELECT, I displayed customer ID, full name, tenure in months, total transactions, and the estimated CLV. I ordered the result in descending order of CLV.

Challenges:
There was no direct way to compute tenure in months using a built-in column, so I used PERIOD\_DIFF with DATE\_FORMAT to compare the year-month values of the current date and the signup date. I also made sure to avoid division errors by making tenure at least 1.
