-- 1.Which person has the greatest total expense amount?
SELECT persons.id, persons.name , greatest_total_exp.total_exp
FROM (
    select SUM(expenses.amount) as total_exp, person_id
    from expenses
    group by person_id
    order by total_exp DESC
    LIMIT 1) as greatest_total_exp
LEFT JOIN persons
ON persons.id = greatest_total_exp.person_id


-- 2.Which person has the greatest total end balance considering all incomes and expenses
SELECT person_id , name , balance
FROM (
    SELECT exp.person_id, COALESCE(total_inc,0) - COALESCE(total_exp,0) as balance
    FROM (select SUM(expenses.amount) as total_exp, person_id from expenses group by person_id) as exp
    LEFT JOIN (select SUM (incomes.amount) as total_inc, person_id from incomes group by person_id) as inc
    ON exp.person_id = inc.person_id
    ORDER BY balance DESC 
    LIMIT 1) as heighest_balance
LEFT JOIN persons
ON persons.id = heighest_balance.person_id


-- 3.List the name, date and balance of the three persons with the highest peak balance
SELECT name, peak_date , peak as balance
FROM (SELECT person_id , (array_agg(date ORDER BY running_balance DESC))[1] as peak_date, MAX(running_balance) as peak
FROM (
     SELECT *, SUM(income - expense) OVER (PARTITION BY person_id order by date) as running_balance
     FROM (SELECT 
     COALESCE(exp.person_id, inc.person_id) as person_id,
     COALESCE(inc.amount, 0) as income,
     COALESCE(exp.amount, 0) as expense,
     COALESCE(exp.date ,inc.date) as date
     FROM (Select SUM(amount) as amount, date, person_id from expenses group by date,person_id) as exp
     FULL JOIN (Select SUM(amount) as amount, date, person_id from incomes group by date,person_id) as inc
     ON exp.person_id = inc.person_id AND exp.date = inc.date) as grouped_exp_and_inc
) as accumlative_balance
GROUP BY person_id
ORDER BY peak DESC
LIMIT 3) as top_peak
LEFT JOIN persons
ON persons.id = top_peak.person_id
ORDER BY balance DESC