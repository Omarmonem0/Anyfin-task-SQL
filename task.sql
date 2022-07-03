--  Which person has the greatest total expense amount?
SELECT persons.id, persons.name , greatest_total_exp.total_exp
FROM (
    select SUM(expenses.amount) as total_exp, person_id
    from expenses
    group by person_id
    order by total_exp DESC
    LIMIT 1) as greatest_total_exp
LEFT JOIN persons
ON persons.id = greatest_total_exp.person_id

-- Which person has the greatest total end balance considering all incomes and expenses
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

--List the name, date and balance of the three persons with the highest peak balance
SELECT name, peak_date , peak as balance
FROM (SELECT person_id , (array_agg(date ORDER BY balance DESC))[1] as peak_date, MAX(balance) as peak
FROM (
    SELECT exp.person_id , COALESCE(exp.date ,inc.date) as date,
    SUM (COALESCE(total_inc,0) -  COALESCE(total_exp,0)) OVER(PARTITION BY exp.person_id order by exp.date, inc.date) as balance
    FROM(
    (select SUM(expenses.amount) as total_exp, person_id, date from expenses group by person_id,date) as exp
    LEFT JOIN (select SUM (incomes.amount) as total_inc, person_id, date from incomes group by person_id, date) as inc
    ON exp.person_id = inc.person_id AND exp.date = inc.date
    )
) as accumlative_balance
GROUP BY person_id
ORDER BY peak DESC
LIMIT 3) as top_peak
LEFT JOIN persons
ON persons.id = top_peak.person_id