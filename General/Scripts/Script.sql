select id, 
	full_name,
	country
from public.customers c;

select * from public.customers c;

select * from public.customers c 
where c.country = "US";

select * from public.customers c 
order by split_part(full_name, ' ', 2) asc;


select full_name as "full name"
from public.customers c 

select
	full_name as "full name"
	split_part(full_name, ' ', 1) as "first_name"
	split_part(full_name, ' ', 2) as "last_name"
from public.customers c;


SELECT
    full_name AS "full_name",
    SPLIT_PART(full_name, ' ', 1) AS "first_name",
    SPLIT_PART(full_name, ' ', 2) AS "last_name",
    UPPER(email) AS "email_upper"
FROM
    public.customers;

SELECT 
    c.id AS "customer_id",
    c.full_name,
    a.id AS "account_id",
    a.*,
    t.id AS "transaction_id",
    t.*,
    sum(t.amount) as total_amount,
    avg(t.amount) as "averadge_transaction_amount",
    count(t.id) as "total_transactions_number",
    min(t.created_at ) as "first_transaction_date"
FROM 
    public.customers c
JOIN 
    accounts a ON c.id = a.customer_id
JOIN 
    transactions t ON a.id = t.account_id
group by 
	c.id,
	c.full_name;

select
	id as "transaction_id",
	amount,
	case
		when amount < 50 then 'small'
		when amount between 50 and 200 then 'medium'
		else 'large'
	end as amount_category
from public.transactions;

select 
	id as "user_balance",
	balance,
	case
		when balance > 1000 then 'premium'
		when balance between 100 and 1000 then 'standart'
		else 'low'
	end as account_status
from public.accounts;

SELECT 
    id,
    COALESCE(email, 'no_email@example.com') AS "email",
    full_name
FROM 
    public.customers c;
	
WITH transactions_amount AS (
    SELECT 
        account_id,
        SUM(t.amount) AS total_amount,
        COUNT(id) AS transactions_count
    FROM 
        public.transactions t 
    GROUP BY 
        account_id
)
SELECT 
    a.balance AS "account_balance",
    stats.account_id,
    stats.total_amount,
    stats.transactions_count
FROM 
    transactions_amount stats
JOIN 
    public.accounts a ON stats.account_id = a.id
ORDER BY 
    stats.total_amount DESC;

WITH customer_accounts AS (

    SELECT 
        c.id AS customer_id,
        c.full_name,
        a.id AS account_id,
        a.balance
    FROM 
        public.customers c 
    JOIN 
        public.accounts a ON c.id = a.customer_id
),
account_transactions AS (

    SELECT 
        account_id,
        SUM(amount) AS total_amount,
        COUNT(id) AS transactions_count,
        AVG(amount) AS average_amount
    FROM 
        public.transactions  
    GROUP BY 
        account_id
),
account_analysis AS (

    SELECT
        ca.customer_id,
        ca.full_name,
        ca.account_id,
        ca.balance,

        COALESCE(at.total_amount, 0) AS total_amount,
        COALESCE(at.transactions_count, 0) AS transactions_count,
        COALESCE(at.average_amount, 0) AS average_amount,
        
        CASE 
            when transactions_count > 4 THEN 'High'
            WHEN transactions_count BETWEEN 2 AND 3 THEN 'Medium'
            ELSE 'Low'
        END AS activity_level,
        
        RANK() OVER (ORDER BY COALESCE(at.total_amount, 0) DESC) AS rank
        
    FROM 
        customer_accounts ca
    JOIN 
        account_transactions at ON ca.account_id = at.account_id
)

SELECT * FROM account_analysis;

	